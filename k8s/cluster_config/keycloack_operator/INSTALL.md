#Keycloak Deployment with PostgreSQL Operator and Backup Restore

This guide explains how to deploy **Keycloak using the Keycloak Operator**, back it with a PostgreSQL cluster managed by the **Zalando Postgres Operator**, and securely **restore a realm backup** while avoiding exposure of the master realm.

---

## ✅ Prerequisites

- A Kubernetes cluster with:
  - [Keycloak Operator](https://www.keycloak.org/operator/installation) installed manually (without OLM)
  - [Zalando Postgres Operator](https://github.com/zalando/postgres-operator) installed
- Access to `kubectl`

---

## 🚀 Step-by-Step Deployment

### 1. Deploy the PostgreSQL Cluster

Apply the Zalando PostgreSQL CR:

```bash
kubectl apply -f postgres-keycloak.yaml
```

**`postgres-keycloak.yaml`:**

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: keycloak-example-postgres
spec:
  teamId: "keycloak"
  volume:
    size: 1Gi
  numberOfInstances: 2
  enableLogicalBackup: true
  enableConnectionPooler: true
  connectionPooler:
    mode: session
  users:
    keycloak:
      - superuser
      - createdb
  databases:
    keycloak: keycloak
  postgresql:
    version: "17"
```

✅ Creates a database `keycloak` owned by user `keycloak`, credentials stored in a Zalando-managed secret.

---

### 2. Deploy Keycloak

Apply your Keycloak custom resource:

```bash
kubectl apply -f keycloak-instance.yaml
```

**`keycloak.yaml`:**

```yaml
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: keycloak-example
spec:
  image: quay.io/keycloak/keycloak:26.2.5
  instances: 2
  db:
    vendor: postgres
    host: keycloak-example-postgres-pooler
    database: keycloak
    usernameSecret:
      name: keycloak.keycloak-example-postgres.credentials.postgresql.acid.zalan.do
      key: username
    passwordSecret:
      name: keycloak.keycloak-example-postgres.credentials.postgresql.acid.zalan.do
      key: password
  ingress:
    enabled: false
  proxy:
    headers: xforwarded
  http:
    httpEnabled: true
  hostname:
    strict: false
    strictBackchannel: true
```

✅ Deploys a Keycloak instance backed by the PostgreSQL cluster. Ingress is disabled to allow custom Ingress configuration.


---

### 3. Configure Secure Ingress (Expose Only Non-Master Realms)

Apply your custom Ingress:

```bash
kubectl apply -f keycloak-ingress.yaml
```

**`keycloak-ingress.yaml`:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-example-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: "nginx"
  rules:
    - host: keycloak-example.qa.km.k8s.zbmed.de
      http:
        paths: 
          - path: /realms/nfdi4health # adapt this name, and copy the section
            pathType: Prefix
            backend:
              service:
                name: keycloak-example-service
                port:
                  number: 8080
          - path: /resources/
            pathType: Prefix
            backend:
              service:
                name: keycloak-example-service
                port:
                  number: 8080
```

✅ This setup only exposes realm `nfdi4health`. The `master` realm is not exposed externally.

---

### 4. Create Keycloak Backup

Only postgres data need to be kept, other information encoded in yaml files stored in repoistory.
See postgres_operator/DOCUMENTATION.md for more details.

### 5. Restore Keycloak Backup

Use the provided `import_backup.sh` script to restore your `.sql.gz` dump:

```bash
./import_backup.sh
```

Update these variables in the script before running:

```bash
KUBE_CONTEXT=""
NAMESPACE="default"
KEYCLOAK_CR_NAME="keycloak-example"

CLUSTER_NAME="keycloak-example-postgres"
BACKUP_FILE=""
```

✅ The script will:

1. Scale down the Keycloak CR.
2. Drop and recreate the Postgres database.
3. Restore the backup using `psql`.
4. Scale Keycloak back up.

---

### 6. Access the Admin Console (`master` Realm)

To access the admin UI (not exposed via Ingress), use port forwarding:

```bash
kubectl port-forward svc/keycloak-example 8080:8080
```

Then visit [http://localhost:8080](http://localhost:8080).

#### Admin Credentials

- If using default setup, see:  
  [Accessing the Admin Console](https://www.keycloak.org/operator/basic-deployment#_accessing_the_admin_console)
- If your backup includes admin users, use those credentials instead.

#### Undeploy

If you're using the default Zalando Postgres + Keycloak Operator setup, this is all you need:
This deletes all the data! Run this only if you're sure you no longer need the data.

```bash
kubectl delete ingress keycloak-example-ingress
kubectl delete keycloak keycloak-example
kubectl delete postgresql keycloak-example-postgres
```