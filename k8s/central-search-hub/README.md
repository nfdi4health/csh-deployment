
# Installs the central search hub

## Load a backup

### SEEK
0) Find a SEEK backend pod
`kubectl get pods/{{. Release.Name }}-seek-backend-`
1) Copy the filestore backup into the volume into the path `/seek/backup/`
`kubectl cp ~/2022-12-01_SEEK-filestore.tar  $POD:/seek/backup/2022-12-01_SEEK-filestore.tar`
2) Login into the container and extract the tar file
`kubectl exec -it $POD -- /bin/sh -c "tar xfv backup/2022-12-01_SEEK-filestore.tar`
3) Connect with the msql server and execute the 

## Fill the search index
Forward `localhost:9200` connections to the elastic search instance of a specific release
`kubectl port-forward svc/{{. Release.Name }}-elastic  9200:9200` 
Configure the ETL-pipline to use that connection.
Execute the pipeline locally. For more information see https://github.com/nfdi4health/csh-etl-pipeline

