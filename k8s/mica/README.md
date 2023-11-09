
# Install mica

`helm install my-test ./mica`


# Add Custom Templates
This creates a volume `{{ .Release.Name }}-template-container-mica` where one can store custom 
templates. Just copy the freemaker files into the running pod.

`kubcetl cp ~/PycharmProjects/mica-templates/ {{ .Release.Name }}-mica-0:/usr/share/mica2/webapp/WEB-INF/classes/`


`k cp _templates/ mica-mica-0:/usr/share/mica2/webapp/WEB-INF/classes/templates/`

# Expose mica behind an ingress
Somehow the CRSF configuration does not work as expected.

`k exec -it  {{ .Release.Name }}-mica-0 -c backup -- /bin/sh`          
`/ #` vi /srv/conf/application.yml`
And add the following lines to the top of the file:
```
csrf:
  allowed: {{ .Values.ingress.dns }}
```

# Load a backup 
A backup consists of two parts, a mongodb backup and the contents of `MICA_HOME`.
The latter does not only contain configuration files and caches but also the revision history.
Within the helm chart the `MICA_HOME` is stored within a volume `{{ .Release.Name }}-data-container-mica`.
If configured copies of `MICA_HOME` and the mongodb are regularly stored within the configured s3 location. 

To import a backup into a fresh installation follow the following steps:
1) Start/Install a fresh instance with this chart.
2) Load the backup of `MICA_HOME` into the new volume.
   1) Copy the backup archive into the pod  `{{ .Release.Name }}-mica-0`
      For example: `k cp  mica-src.tar.gz {{ .Release.Name }}-mica-0:/tmp/mica-src.tar.gz   `
   2) Extract the files into the right location 
      1) Attach to the running pod e.g. `k exec -it {{ .Release.Name }}-mica-0  -- /bin/bash` 
      2) Extract the archive within the pod e.g. `tar -xvzf /tmp/mica-src.tar.gz -C /srv`
      3) Remove the `/srv/work` directory, since the backup was likely generated of a running instance, which results in invalid stated.  e.g. `rm -rf  /srv/wrok`
3) Load the mongodb backup into the new instance
   1) Copy the backup archive into the pod  `{{ .Release.Name }}-mongo-0`
      For example: `k cp mica_2023-11-03.archive.gz {{ .Release.Name }}-mica-0:/tmp/mica_2023-11-03.archive.gz`
   2) Obtain the mongodb credentials. 
      1) `k get secrets/{{ .Release.Name }}-mongo-secret  -o=jsonpath="{.data.username}"| base64 --decode`
      2) `k get secrets/{{ .Release.Name }}-mongo-secret  -o=jsonpath="{.data.password}"| base64 --decode`
   3) Load the backup archive. 
      1) Attach to the running pod e.g. `k exec -it {{ .Release.Name }}-mongo-0  -- /bin/bash` 
      2) Restore the mongodb (Replace $USERNAME and $PW with the mongodb credentials)
         e.g. `mongorestore  --username=$USERNAME --password=$PW --authenticationDatabase=admin --gzip --drop --archive=/tmp/mica_2023-11-03.archive.gz`
   4) Update mongodb secrets
      We just exchanged the authenticationDatabase of the current mongodb with the ones from the backup. Therefore, we need to update the secrets.
      e.g. via `k edit secret/{{ .Release.Name }}-mongo-secret`, keep in mind the values are base64 encoded.
   5) Update mica secrets
      The configured mica secrets are also invalid and must also be updated with the values valid with the backup.
      e.g. via `k edit secret/{{ .Release.Name }}-mica-secret`, keep in mind the values are base64 encoded.
4) If not automatically triggered by k8s. Enforce a restart of mica by deleting the pod `{{ .Release.Name }}-mica-0`
   e.g. via `k delete pods/{{ .Release.Name }}-mica-0`
5) Login to mica2 admin UI and drop all caches and reindex everything
