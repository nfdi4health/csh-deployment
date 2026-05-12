curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCitedBy","inverseName":"Cites"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsSupplementTo","inverseName":"IsSupplementedBy"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsContinuedBy","inverseName":"Continues"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDescribedBy","inverseName":"Describes"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasMetadata","inverseName":"IsMetadataFor"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasVersion","inverseName":"IsVersionOf"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsNewVersionOf","inverseName":"IsPreviousVersionOf"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPartOf","inverseName":"HasPart"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPublishedIn"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReferencedBy","inverseName":"References"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDocumentedBy","inverseName":"Documents"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCompiledBy","inverseName":"Compiles"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsVariantFormOf","inverseName":"IsOriginalFormOf"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsIdenticalTo","inverseName":"IsIdenticalTo"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReviewedBy","inverseName":"Reviews"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDerivedFrom","inverseName":"IsSourceOf"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsRequiredBy","inverseName":"Requires"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsObsoletedBy","inverseName":"Obsoletes"}' $DATAVERSE_URL/api/datasets/relationTypes