# Source: https://github.com/gdcc/dataverse-previewers/blob/develop/6.1curlcommands.md

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Read Text",
  "description":"Read the text file.",
  "toolName":"textPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/TextPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/plain",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Html",
  "description":"View the html file.",
  "toolName":"htmlPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/HtmlPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/html",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/mp3",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/mpeg",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/wav",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/ogg",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/mp4",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Audio",
  "description":"Listen to an audio file.",
  "toolName":"audioPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/AudioPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"audio/x-m4a",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Image",
  "description":"Preview an image file.",
  "toolName":"imagePreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/ImagePreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"image/gif",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Image",
  "description":"Preview an image file.",
  "toolName":"imagePreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/ImagePreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"image/jpeg",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Image",
  "description":"Preview an image file.",
  "toolName":"imagePreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/ImagePreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"image/png",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Read Document",
  "description":"Read a pdf document.",
  "toolName":"pdfPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/PDFPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/pdf",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Video",
  "description":"Watch a video file.",
  "toolName":"videoPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/VideoPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"video/mp4",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Video",
  "description":"Watch a video file.",
  "toolName":"videoPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/VideoPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"video/ogg",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Play Video",
  "description":"Watch a video file.",
  "toolName":"videoPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/VideoPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"video/quicktime",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Data",
  "description":"View the spreadsheet data.",
  "toolName":"spreadsheetPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/SpreadsheetPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/comma-separated-values",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Data",
  "description":"View the spreadsheet data.",
  "toolName":"spreadsheetPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/SpreadsheetPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/tab-separated-values",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Data",
  "description":"View the spreadsheet data.",
  "toolName":"spreadsheetPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/SpreadsheetPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/csv",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Data",
  "description":"View the spreadsheet data.",
  "toolName":"spreadsheetPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/SpreadsheetPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/tsv",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Stata File",
  "description":"View the Stata file as text.",
  "toolName":"stataPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/TextPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/x-stata-syntax",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View R file",
  "description":"View the R file as text.",
  "toolName":"rPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/TextPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"type/x-r-syntax",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Annotations",
  "description":"View the annotation entries in a file.",
  "toolName":"annotationPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/HypothesisPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/x-json-hypothesis",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Map",
  "description":"View a map of the file.",
  "toolName":"mapPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/MapPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/geo+json",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Map",
  "description":"View a map of the file.",
  "toolName":"mapPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/MapPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/geo+json",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Preview Zip file",
  "description":"Preview the structure of a Zip file.",
  "toolName":"zipPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/ZipPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/zip",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Preview ELN file",
  "description":"Preview the structure of an ELN Archive.",
  "toolName":"zipPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/ZipPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/vnd.eln+zip",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Show NcML (XML)",
  "description":"Metadata from HDF5 files.",
  "toolName":"ncmlPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/NcmlPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "requirements": {
    "auxFilesExist": [
      {
        "formatTag": "NcML",
        "formatVersion": "0.1"
      }
    ]
  },
  "contentType":"application/x-hdf5",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Show NcML (XML)",
  "description":"Metadata from NetCDF files.",
  "toolName":"ncmlPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/NcmlPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "requirements": {
    "auxFilesExist": [
      {
        "formatTag": "NcML",
        "formatVersion": "0.1"
      }
    ]
  },
  "contentType":"application/netcdf",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"H5Web",
  "description":"Explore and visualize HDF5 files",
  "toolName":"HDF5Preview",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/HDF5Preview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/x-hdf5"
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"H5Web",
  "description":"Explore and visualize HDF5 files",
  "toolName":"HDF5Preview",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/HDF5Preview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/netcdf"
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"Show Markdown (MD)",
  "description":"View the Markdown file.",
  "toolName":"mdPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"https://gdcc.github.io/dataverse-previewers/previewers/v1.5/MdPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"text/markdown",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'

curl -X POST -H 'Content-type: application/json' $DATAVERSE_URL/api/admin/externalTools -d \
'{
  "displayName":"View Map",
  "description":"View a map of the file.",
  "toolName":"mapShpPreviewer",
  "scope":"file",
  "types":["preview"],
  "toolUrl":"gdcc.github.io/dataverse-previewers/previewers/v1.5/MapShpPreview.html",
  "toolParameters": {
      "queryParameters":[
        {"fileid":"{fileId}"},
        {"siteUrl":"{siteUrl}"},
        {"datasetid":"{datasetId}"},
        {"datasetversion":"{datasetVersion}"},
        {"locale":"{localeCode}"}
      ]
    },
  "contentType":"application/zipped-shapefile",
  "allowedApiCalls": [
    {
      "name": "retrieveFileContents",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=true",
      "timeOut": 3600
    },
    {
      "name": "downloadFile",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/access/datafile/{fileId}?gbrecs=false",
      "timeOut": 3600
    },
    {
      "name": "getDatasetVersionMetadata",
      "httpMethod": "GET",
      "urlTemplate": "/api/v1/datasets/{datasetId}/versions/{datasetVersion}",
      "timeOut": 3600
    }
  ]
}'