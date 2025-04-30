
### Fix your manually triggered deployment from github actions

```sh
helm get values csh-fairagro-service-search > override-values.yaml
```

now in the override-values.yaml change the dataverse-svc to point your current api instance by updating the value for dataverse_host. e.g 

```
dataverse_host: http://ata-dv3-dataverse-svc:8080
```

find out your chart name and deployment names and run the following command
```
helm upgrade deplyment_name path_to_the_chart_for_this_deployment -f override-values.yaml
```


example
```sh
helm upgrade csh-fairagro-service-search central-search-hub -f override-values.yaml
```