# Install Postgres Operator
## add repo for postgres-operator
```
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
```
## install the postgres-operator
```
helm upgrade postgres-operator postgres-operator-charts/postgres-operator  -f ./values_postgres_operator.yaml --version=1.8.2
```
# Documentation

https://github.com/zalando/postgres-operator