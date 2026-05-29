curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCitedBy","displayName":"Is cited by","inverseName":"Cites","inverseDisplayName":"Cites","description":"Indicates that B includes A in a citation.","inverseDescription":"Indicates that A includes B in a citation."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsSupplementTo","displayName":"Is supplement to","inverseName":"IsSupplementedBy","inverseDisplayName":"Is supplemented by","description":"Indicates that A is a supplement to B.","inverseDescription":"Indicates that B is a supplement to A."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsContinuedBy","displayName":"Is continued by","inverseName":"Continues","inverseDisplayName":"Continues","description":"Indicates that A is continued by the work B.","inverseDescription":"Indicates that A is a continuation of the work B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDescribedBy","displayName":"Is described by","inverseName":"Describes","inverseDisplayName":"Describes","description":"Indicates that A is described by B.","inverseDescription":"Indicates that A describes B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasMetadata","displayName":"Has metadata","inverseName":"IsMetadataFor","inverseDisplayName":"Is metadata for","description":"Indicates that A has additional metadata B.","inverseDescription":"Indicates that A is additional metadata for B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"HasVersion","displayName":"Has version","inverseName":"IsVersionOf","inverseDisplayName":"Is version of","description":"Indicates that A has a version B.","inverseDescription":"Indicates that A is a version of B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsNewVersionOf","displayName":"Is new version of","inverseName":"IsPreviousVersionOf","inverseDisplayName":"Is previous version of","description":"Indicates that A is a new edition of B, , where the new edition has been modified or updated.","inverseDescription":"Indicates that A is a previous edition of B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPartOf","displayName":"Is part of","inverseName":"HasPart","inverseDisplayName":"Has part","description":"Indicates that A is a portion of B; may be used for elements of a series.","inverseDescription":"Indicates that A includes the part B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsPublishedIn","displayName":"Is published in","description":"Indicates that A is published inside B, but is independent of other things published inside of B"}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReferencedBy","displayName":"Is referenced by","inverseName":"References","inverseDisplayName":"References","description":"Indicates that A is used as a source of information by B.","inverseDescription":"Indicates that A is used as a source of information B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDocumentedBy","displayName":"Is documented by","inverseName":"Documents","inverseDisplayName":"Documents","description":"Indicates that B is documentation about/explaining A; e.g. points to software documentation.","inverseDescription":"Indicates that A is documentation about B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsCompiledBy","displayName":"Is compiled by","inverseName":"Compiles","inverseDisplayName":"Compiles","description":"Indicates that B is used to compile or create A.","inverseDescription":"Indicates that B is the result of a compile or creation event using A."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsVariantFormOf","displayName":"Is variant form of","inverseName":"IsOriginalFormOf","inverseDisplayName":"Is original form of","description":"Indicates that A is a variant or different form of B.","inverseDescription":"Indicates that A is the original form of B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsIdenticalTo","displayName":"Is identical to","inverseName":"IsIdenticalTo","inverseDisplayName":"Is identical to","description":"Indicates that A is the same as B.","inverseDescription":"Indicates that A is identical to B, for use when there is a need to register two separate instances of the same resource."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsReviewedBy","displayName":"Is reviewed by","inverseName":"Reviews","inverseDisplayName":"Reviews","description":"Indicates that A is reviewed by B.","inverseDescription":"Indicates that A reviews B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsDerivedFrom","displayName":"Is derived from","inverseName":"IsSourceOf","inverseDisplayName":"Is source of","description":"Indicates that B is a source upon which A is based.","inverseDescription":"Indicates that A is a source upon which B is based."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsRequiredBy","displayName":"Is required by","inverseName":"Requires","inverseDisplayName":"Requires","description":"Indicates that A is required by B.","inverseDescription":"Indicates that A requires B."}' $DATAVERSE_URL/api/datasets/relationTypes
  
curl -H "Content-Type: application/json" -X POST --data '{"name":"IsObsoletedBy","displayName":"Is obsoleted by","inverseName":"Obsoletes","inverseDisplayName":"Obsoletes","description":"Indicates that A is replaced by B.","inverseDescription":"Indicates that A replaces B."}' $DATAVERSE_URL/api/datasets/relationTypes