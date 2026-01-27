#  PostgreSQL Backup, Restoration & Operator Management Documentation
## 1. PostgreSQL Backup System

### 1.1 Overview

All PostgreSQL databases are backed up **hourly** using the **Zalando Postgres Operator**, which provides **fully
automated, policy-driven backup functionality**. These backups are securely stored in **S3-compatible object storage**,
managed by the `QB-IT` team. This setup ensures disaster recovery capability and compliance with data protection
standards.

### 1.2 Backup Details

| Parameter             | Description                                                               |
|-----------------------|---------------------------------------------------------------------------|
| **Frequency**         | Hourly                                                                    |
| **Automation**        | Fully automated by Zalando Postgres Operator                              |
| **Storage**           | S3-compatible object storage                                              |
| **Encryption**        | Server-side (AES-256)                                                     |
| **Retention**         | 1 month (rolling)                                                         |
| **Access Control**    | AWS IAM policies maintained by the `QB-IT` team                           |
| **Audit Logging**     | All access to backup objects is logged and maintained by the `QB-IT` team |
| **Storage Ownership** | Fully operated and secured by the `QB-IT` team                            |

> The `QB-IT` team is responsible for managing the S3 storage system and all associated audit logging. They ensure
> compliance with internal IT security policies and regulatory frameworks.

Backups use the Zalando Operator’s logical-backup feature and are executed automatically through configured
Kubernetes `postgresql` custom resources (CRDs).

---

## 2. Backup Monitoring & Compliance

### 2.1 Automation and Ownership

- **Backup Execution**: Fully automated and triggered by the **Zalando Postgres Operator**
- **Monitoring & Manual Review**: Conducted weekly by the **application development team**

#### Review Checklist:

- Confirm success of recent backup jobs
- Check for missing or unusually sized backup objects
- Review logs and alerts for anomalies

---

## 3. Restore Procedure

### 3.1 Restoration Overview

Restore operations are **manually triggered by the application development team** using a set of **version-controlled Bash
script**. The script is stored in a secure Git repository with access controls and full change history.

### 3.2 Script Functionality

- Authenticates to object storage
- Downloads the relevant backup data
- Executes restoration via PostgreSQL tools (`psql`, etc.)
- Logs are generated for traceability

---

## 4. Restoration Testing

### 4.1 Quarterly Restore Validations

The **application development team** performs quarterly tests in **isolated staging environments** to validate:

| Validation Type           | Description                                   |
|---------------------------|-----------------------------------------------|
| **Completeness**          | Schema and full data verification             |
| **Integrity**             | Referential and application-level consistency |
| **Time-To-Restore (TTR)** | Measured and logged for reporting             |

All test outcomes are archived for internal audit use.

---

## 5. Zalando Postgres Operator Installation

### 5.1 Helm-Based Installation

#### Add Helm Repository

```bash
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
```

#### Install/Upgrade the Operator

```bash
helm upgrade postgres-operator postgres-operator-charts/postgres-operator \
  -f ./values_postgres_operator.yaml \
  --version=1.10.1
```

- Backup policy is defined via the `./values_postgres_operator.yaml` globally for the cluster.
- A backup is enabled at the `postgresql` CRD using `enableLogicalBackup: true`
- No manual scheduling is required after configuration

### 5.2 Documentation

Official Operator documentation:  
🔗 [https://github.com/zalando/postgres-operator](https://github.com/zalando/postgres-operator)
