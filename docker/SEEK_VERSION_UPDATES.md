# Update December 2021
 WARNING SOME STEPS PRIO the version upgrade! 
1. Mitigate bug with SEEK cutom metadata handling
   - `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rails c`  
    `CustomMetadataType.all.map(&:title)`
   - output of above should only contain NFDI4Health custom metadate
    ```
    disable_authorization_checks { CustomMetadataType.where(title: 'MIAPPE metadata v1.1').destroy_all}
    disable_authorization_checks { CustomMetadataAttribute.where(custom_metadata_type_id: nil ).destroy_all}
    ```
2. Upgrade SEEK  version
   - `docker-compose -f SEEK-docker-compose.yaml exec seek docker/upgrade.sh` 
3. Update MDS data model 
   - `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health:update_attribute_types`

# Update March 2022
1. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health:update_studyhub_resource_seeds`
2. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health:update_resource_json`


# Update October 2023
1. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health:update_language_attribute_types`

# Update November 2023
1. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health_update_to_MDS_v2_1:update_sample_controlled_vocab_terms`
2. `docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rake seek_dev_nfdi4health_update_to_MDS_v2_1:data_migration_to_MDS_2_1`


# Update Rights.
Open the shell can execute the loop below.
`docker-compose -f SEEK-docker-compose.yaml exec seek bundle exec rails c`
```
StudyhubResource.all.map(&:id).each do |id|
  permission =  StudyhubResource.find(id).policy.permissions.where(contributor_type: "Person", contributor_id: 46).first_or_initialize
   permission.update_attributes(access_type:4)
end
```