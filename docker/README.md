This README describes how to administrate a CSH instance.

# Domain and SSL
Done by ZB MED. Configuration of HAproxy.

## Subcomponents

## SEEK 
### Create a new instance
1. with existing data
   1. Follow the Load SEEK Backup process but do not start the instance
   2. Continue with step 5 of the update SEEK instance guide
2. blank instance
   1. `docker-compose -f SEEK-docker-compose.yaml up`

### Load a SEEK backup
#### Stop the instance
1. `docker-compose -f SEEK-docker-compose.yaml down`
2. `docker-compose -f SEEK-docker-compose.yaml up --no-start  seek db solr`
#### Load/Overwrite filesystem
Requires a backup of the filesystem  and a backup of the database. In case of strange errors, create new volumes!
1. Load mysql
   1. Adapt the file mount (`-v $(pwd)/$(date +"%Y-%m-%d")_SEEK-mysql-fs.tar:/backup/seek-mysql-db.tar`)
      - e.g `export FP=/home/darms/2022-03-10_SEEK-mysql-fs.tar:/backup/seek-mysql-db.tar`
   2. Adapt the volumes-from (`--volumes-from `)
      - e.g. `export VF=seek-mysql`
      1. `docker run --rm --volumes-from $VF  -v $FP alpine sh -c "tar xfv /backup/seek-mysql-db.tar"`
      - or load an mysql dump
         `docker-compose  -f SEEK-docker-compose.yaml exec -T db /usr/bin/mysql -u root --password=seek_root seek_docker < 2022-03-10_SEEK_mysql-dump.sql`
2. Load file store
   1. Adapt the file mount (`$(pwd)/$(date +"%Y-%m-%d")_SEEK-filestore.tar:/backup/seek-filestore.tar`)
      - e.g `export FP=/home/darms/2022-03-10SEEK-filestore.tar:/backup/seek-filestore.tar`
   2. Adapt the volumes-from (`--volumes-from`)
      - e.g. `export VF=seek`
   3. `docker run --rm --volumes-from $VF -v $FP alpine sh -c "tar xfv /backup/seek-filestore.tar"` 
   
#### Start the instances
1. `docker-compose -f SEEK-docker-compose.yaml down`
2. `docker-compose -f SEEK-docker-compose.yaml up -d`
   - Start up takes a long time ca. 5 minutes. Assets need to be compiled on each startup, since they are relative to
     the URL which is configured via an ENV property.

### Create a SEEK backup
1. Create a backup of the filesystem (i.e. user uploads)
   1. `docker run --rm --volumes-from seek -v $(pwd):/backup ubuntu tar cvf backup/$(date +"%Y-%m-%d")_SEEK-filestore.tar /seek/filestore`
2. Create a copy of the database
   1. The SEEK documentation recommends copying the file systeme
      - `docker run --rm --volumes-from seek-mysql -v $(pwd):/backup ubuntu tar -cvf /backup/$(date +"%Y-%m-%d")_SEEK-mysql-fs.tar /var/lib/mysql`
   2. Alternatively one can dump the DB
      - `docker-compose  -f SEEK-docker-compose.yaml exec db /usr/bin/mysqldump -u root --password=seek_root seek_docker > $(date +"%Y-%m-%d")_SEEK_mysql-dump.sql`

### Update the SEEK instance
1. Create a backup just to be safe.
3. Stop the instances
   1. `docker-compose -f SEEK-docker-compose.yaml down`
4. Update the docker-compose-file
   1. Update image version
      1. Line 15 and 41
5. Pull new images   
   1. `docker-compose -f SEEK-docker-compose.yaml pull`
6. Start needed container
   1. `docker-compose -f SEEK-docker-compose.yaml up -d seek db solr`
7. Update the SEEK process 
   1. `docker-compose -f SEEK-docker-compose.yaml exec seek docker/upgrade.sh`
   2. Sometimes specific commands are needed to upgrade/update versions. They need to be called after the `upgrade.sh` and prior `rake tmp:clear` call.
      Take a look into the SEEk_VERSION_UPDATES.md file
      1. e.g. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake tmp:clear`
   4. Clear the cache
      1. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake tmp:clear`
8. Stop the instances
   1. `docker-compose -f SEEK-docker-compose.yaml down`
9. Start the instances
   1. `docker-compose -f SEEK-docker-compose.yaml up -d`

### Delete an instance
with `rmi` also the images are removed. Hence, this argument can be omitted. 
1. `docker-compose -f SEEK-docker-compose.yaml down -v   --remove-orphans  --rmi all`

## MICA
### Update the  instance
1. Create template volume
   - `docker volume create data-mica-template`
2. Create helper to copy template to volume
   - `docker run -v data-mica-template:/data --name helper busybox tr`
3. copy all templates to dir 
   - `docker cp ~/PycharmProjects/mica-templates/. helper:/data`
4. COPY DEFAULT CONFIG!!!
5. Remove helper 
   - `docker rm helper`
### After start of opal
login into UI and configure a Data database 
http://localhost:8880/ui/index.html#!admin/!databases


## UI
### Update the  instances
1. Stop the instances
   1. `docker-compose -f UI-docker-compose.yaml down`
2. Update the docker-compose-file
   1. Update image version
      1. Line 21 and 21
3. Pull new images   
   1. `docker-compose -f UI-docker-compose.yaml pull`
4. Start the instances
   - `docker-compose -f UI-docker-compose.yaml up -d`
5. Reindex the data (cf. etl-pipeline)