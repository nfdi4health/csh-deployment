# Deployment of the German Central Health Study Hub

A blue-green deployment process is followed. All components can be installed twice via HELM, once with the suffix "green" and once with the suffix "blue".
once with the 'blue' suffix. All components are installed without an active ingress (emtpy ingress in values.yaml). 
The ingress object is manually configured to update and redirect traffic to either the blue or green instance.
For the `mica` and `dataverse` components, only manual updates are forseen. For the `csh-ui` component, 
component, which is under active development, (semi-)automatic upgrades are planned and implemented.
The github action must specify the target of the automatic (upgrade) process. 
You can also specify which image version to use (by default, the latest commit from the main branch is used).
The upgrade job can be found here: https://github.com/nfdi4health/csh-ui/actions/workflows/deployment_production.yml 

As the configuration of `csh-ui` depends on the instances used (either "blue" or "green"), some constants are encoded in the automatic process.
This means that `csh-prod-ui-green` will always connect to `keycloack-prod`, `csh-prod-mica-prod` and `csh-prod-dv-green`. Analogue,
`csh-ui-blue` will always connect to `keycloack-prod`, `csh-prod-mica-prod` and `csh-prod-dv-blue`. 
As for `keycloak` and `mica`, only a single instance is configured as changes/upgrades occur infrequently.

However, switching between blue/green cannot be done without manual intervention! 
Firstly, the ingress object must be updated to disconnect both instances from customer traffic. 
Secondly, the standby dataverse must be reconfigured to use the production storage and the database content must be moved from production to standby.
Thirdly, the csh-ui search index must be rebuilt to synchronise with the production database. 
Fourthly, the ingress object must be updated to connect customer traffic to the previous standby instance. 
(and with this change, the production instance). 

The following figures show the state of a green and a blue live environment. It also shows the in-between state
with any components that need to be reconfigured in purple and components where data needs to be updated in red.
![BG_GCSH.drawio(2).png](fig%2FBG_GCSH.drawio%282%29.png)

## Upgrades to the `csh-ui`
The CSH-UI does not store any customer data. It is therefore easy to upgrade. If major changes have been made concerning 
the data structure or index structure, the search index be must be recreated. Otherwise, it is sufficient to run the CI/CD Github action.

If the configured dataverse backend is upgraded and the data model or content ist changed the index must also be regenerated.
The script to repopulate the index is available here:

## Upgrades to `dataverse`
The Dataverse instance stores customer data, data loss is unacceptable, so every upgrade/update must be tested.
Therefore, no (semi-)automatic processes are configured. Use a copy of the production data to test the new version of the upgrade!

A detailed guide to loading a backup and performing a dataverse upgrade is available here.
After the upgrade, the `csh-ui` index needs to be rebuilt, see the documentation above.
As soon as there are no bugs in the new version. The step-by-step migration guide can be followed.

## Step-by-step switch over guide

- **Assumption 1**: `green` is the current production environment, and `blue` the stand-by.
- **Assumption 2**: `green` is  accessible to customers!
- Step 1: Reconfigure the k8s ingress object to serve a 503. (https://github.com/nfdi4health/csh-ui/actions/workflows/change_ingress.yml)
- Step 2: Create a backup of `green` postgres db.
- Step 3: Remove all S3 demo data, then copy S3 prod-data into S3 demo-data.
- **Remark**: Step 1-3 can be performed in parallel. 
- Step 4: Load the backup into `blue` postgres db. Follow [this guide](https://github.com/nfdi4health/csh-deployment/tree/main/k8s/dataverse#loading-a-backup).
- **Assumption 3**: `blue` and `green` are now identical copies!
- Step 5: Perform the dataverse upgrade on instance `blue`.
  - Can an upgrade have effects on the data stored in S3????
- Step 6: Recreate csh-ui Elasticsearch index on `blue`
- Step 7: Test upgrade. No data loss & all functions work as expected.
- Check at least for:
    - Double check correct configuration for `csh-ui` and `dataverse`.
    - Check if count of datasets, dataset versions, and dataverses are equal.
    - Randomly select and compare 4 datasets. Is the data equal or in case of schema update correctly migrated?
    - Does the OIDC Authentication work with dataverse and csh-ui?
    - Create a new dataset with `csh-ui`
      - Can I upload and download a file?
      - Can I request the publication?
      - Can I decline the publication?
      - Can I delete the resource?
- **Assumption 4**: `blue` is now upgraded! This must be checked! 
- Step 8: Create a backup of `blue` postgres db
- Step 9: Create a backup of S3 demo-data data???
- Step 10: Reconfigure the k8s ingress object to forward traffic to `blue` (https://github.com/nfdi4health/csh-ui/actions/workflows/change_ingress.yml)
- **Remark**: Step 8-10 can be performed in parallel. 
- **Assumption 5**: `blue` is now accessible to customer!
- **Assumption 6**: `blue` is the current production environment, and `green` the stand-by.
- Step 11: Verify that the automatic backup jobs are executed as planned.


**Fallback procedure:** If something does not work between Step 2-9:

- Step 1: Reconfigure the k8s ingress object to forward traffic to `green`
Rationale: Production environment to not altered yet! It only does not server customer, so we can have a clean db state!

**Fallback procedure**:  If something does not work between step 1 or step 10:

- Step 1: Rollback the changes to the k8s ingress object! 

