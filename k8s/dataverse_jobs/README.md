# K8s Dataverse Jobs

## Publish Job

The publish job publishes all datasets in the given Dataverse collection(s). To run the job, run the following command:

```shell
chmod +x publish_job/run.sh
export DATAVERSE_NAME=my-dataverse
export DATAVERSE_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export DATAVERSE_PUBLISH_TYPE=updatecurrent
export DATAVERSE_COLLECTIONS="my-collection-1 my-collection-2"

./publish_job/run.sh
```

(Substitute the environment variables with your own values. Valid values for `DATAVERSE_PUBLISH_TYPE` are `major`,
`minor` and `updatecurrent` (see [Dataverse API docs](https://guides.dataverse.org/en/latest/api/native-api.html#publish-a-dataset)).)