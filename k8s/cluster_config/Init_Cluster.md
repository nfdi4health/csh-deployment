# Setup k8s cluster for our usage

## Verknüpfung von GitHub und Kubernets
Annahme es existiert ein Nutzeraccount in Github und kubernetes soll in die Lage gebracht werden alle Images, auf die Nutzer zugreifen kann,
zuzugreifen. 
1. Create Personal Access Token (PAT) with GitHub

2. Username und Token als base64 kodieren. 

   `echo -n "$USERNAME:$TOKEN" | base64 `

3. dockerconfig Erstellen

    ```
    {
        "auths": {
            "ghcr.io": {
                "auth": "$TOKEN"
            }
        }
    }
    ```

4. Kubernetes Secret erstellen

    ```
    kubectl create secret generic regcred \                                                                            
    --from-file=.dockerconfigjson=.dockerconfig.json \
    --type=kubernetes.io/dockerconfigjson
    ```
   
5. Secret als default setzten

   `kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'`

## Verknüpfung von GitLab und Kubernets
Annahme es existiert eine Gruppe in Gitlab und kubernetes soll in die Lage gebracht werden
alle Images im Scope der Gruppe zu lesen. Beispiel: k8s soll alle container images der Gruppe `km` lesen können.

1. Auf  https://gitlab.zbmed.de/groups/km/-/settings/repository einen `Deploy Token` mit `read_registry` Rechten erstellen.
2. Username und Token als base64 kodieren. 

   `echo -n "$USERNAME:$TOKEN" | base64 `
3. dockerconfig Erstellen

    ```
    {
        "auths": {
            "gitlab.zbmed.de:5050": {
                "auth": "$TOKEN"
            }
        }
    }
    ```

4. Kubernetes Secret erstellen

    ```
    kubectl create secret generic regcred \                                                                            
    --from-file=.dockerconfigjson=.dockerconfig.json \
    --type=kubernetes.io/dockerconfigjson
    ```
   
5. Secret als default setzten

   `kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'`

## Betrieb von gleichzeitigem Zugriff auf GitHub und Gitlab
Vorgehen wie bei einzelnem nur in Schritt 3 (Erstellen der docker config) beide Section erstellen.
Beispiel:
```
     {
        "auths": {
            "ghcr.io": {
                "auth": ""
            },
            "gitlab.zbmed.de:5050": {
                "auth": ""
            }
        }
    }
     
```

# Konfiguration ingress controller (Zugriff auf Dienste via Domain)
https://kubernetes.github.io/ingress-nginx/
1. Installation ingress-nginx
``` 
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```
2. Obtain IP

`kubectl get service ingress-nginx-controller --namespace=ingress-nginx`

3. Ask IT to create a DSN A record that points to the `EXTERNAL-IP`.
   Next to specific public DNS record, I suggest to configure a wildcard e.g. `*.qa.km.zbmed.de`.
   That allows to quickly expose services without another contact with IT. (Alternatively, to strip manually step the IT department we could allow the clustermanager (gardner) to manage a DNS Zone :)
4. Check that IP points to correct IP
`dig $DOMAN`

# Konfiguration Zertifikatsmanagement 
https://cert-manager.io 
1. Install cert-manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm install certmgr jetstack/cert-manager \                 
    --namespace cert-manager \
    --create-namespace
```

2. Configure cert-manage

```
kubectl apply -f config/Issuer.yaml  
```

```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: km-bonn@zbmed.de
    privateKeySecretRef:
      name: account-key-prod
    solvers:
    - http01:
       ingress:
         class: nginx
```

# Configure an Ingress

Requires setup of ingress-controller and cert-manager and that the DNS (either exact or wildcard) used points to the external IP of the ingress-controller.

```kubernetes
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    # Configure Ingress (c.f. configuration ingress-controller)
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # Issuser to use (c.f. configuration cert-manager)
    cert-manager.io/issuer: "letsencrypt-prod"
spec:
  tls:
    - hosts:
        - example.qa.km.k8s.zbmed.de
      # Secret to store private-key for this domain
      secretName: csh-key-staging 
  rules:
    - host: "example.qa.km.k8s.zbmed.de"
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: frontend
              port:
                number: 4000
```