curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCitedBy","displayName":"Is cited by","description":"Indicates that B includes A in a citation.","inverse":{"name":"Cites","displayName":"Cites","description":"Indicates that A includes B in a citation."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsSupplementTo","displayName":"Is supplement to","description":"Indicates that A is a supplement to B.","inverse":{"name":"IsSupplementedBy","displayName":"Is supplemented by","description":"Indicates that B is a supplement to A."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsContinuedBy","displayName":"Is continued by","description":"Indicates that A is continued by the work B.","inverse":{"name":"Continues","displayName":"Continues","description":"Indicates that A is a continuation of the work B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDescribedBy","displayName":"Is described by","description":"Indicates that A is described by B.","inverse":{"name":"Describes","displayName":"Describes","description":"Indicates that A describes B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasMetadata","displayName":"Has metadata","description":"Indicates that A has additional metadata B.","inverse":{"name":"IsMetadataFor","displayName":"Is metadata for","description":"Indicates that A is additional metadata for B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasVersion","displayName":"Has version","description":"Indicates that A has a version B.","inverse":{"name":"IsVersionOf","displayName":"Is version of","description":"Indicates that A is a version of B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsNewVersionOf","displayName":"Is new version of","description":"Indicates that A is a new edition of B, , where the new edition has been modified or updated.","inverse":{"name":"IsPreviousVersionOf","displayName":"Is previous version of","description":"Indicates that A is a previous edition of B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPartOf","displayName":"Is part of","description":"Indicates that A is a portion of B; may be used for elements of a series.","inverse":{"name":"HasPart","displayName":"Has part","description":"Indicates that A includes the part B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPublishedIn","displayName":"Is published in","description":"Indicates that A is published inside B, but is independent of other things published inside of B"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReferencedBy","displayName":"Is referenced by","description":"Indicates that A is used as a source of information by B.","inverse":{"name":"References","displayName":"References","description":"Indicates that A is used as a source of information B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDocumentedBy","displayName":"Is documented by","description":"Indicates that B is documentation about/explaining A; e.g. points to software documentation.","inverse":{"name":"Documents","displayName":"Documents","description":"Indicates that A is documentation about B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCompiledBy","displayName":"Is compiled by","description":"Indicates that B is used to compile or create A.","inverse":{"name":"Compiles","displayName":"Compiles","description":"Indicates that B is the result of a compile or creation event using A."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsVariantFormOf","displayName":"Is variant form of","description":"Indicates that A is a variant or different form of B.","inverse":{"name":"IsOriginalFormOf","displayName":"Is original form of","description":"Indicates that A is the original form of B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsIdenticalTo","displayName":"Is identical to","description":"Indicates that A is the same as B.","inverse":{"name":"IsIdenticalTo","displayName":"Is identical to","description":"Indicates that A is identical to B, for use when there is a need to register two separate instances of the same resource."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReviewedBy","displayName":"Is reviewed by","description":"Indicates that A is reviewed by B.","inverse":{"name":"Reviews","displayName":"Reviews","description":"Indicates that A reviews B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDerivedFrom","displayName":"Is derived from","description":"Indicates that B is a source upon which A is based.","inverse":{"name":"IsSourceOf","displayName":"Is source of","description":"Indicates that A is a source upon which B is based."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsRequiredBy","displayName":"Is required by","description":"Indicates that A is required by B.","inverse":{"name":"Requires","displayName":"Requires","description":"Indicates that A requires B."}}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsObsoletedBy","displayName":"Is obsoleted by","description":"Indicates that A is replaced by B.","inverse":{"name":"Obsoletes","displayName":"Obsoletes","description":"Indicates that A replaces B."}}' $DATAVERSE_URL/api/datasets/relationTypes

curl -X PUT $DATAVERSE_URL/api/datasets/relationTypes/defaultRelationType/References
