# German Central Health Study Hub - Deployment Configuration

## Introduction
The [German Central Health Study Hub](https://csh.nfdi4health.de) is a platform that serves two different kinds of users. First, it allows scientists
and data holding organizations (data producers) to publish their project characteristics, documents and data related to
their research endeavour in a FAIR manner. Obviously, patient-level data cannot be shared publicly, however, metadata
describing the patient-level data along with information about data access can be shared via the platform (preservation
description information). The other kind of user is a scientist or researcher (data consumer) that likes to find
information about past and ongoing studies and is interested in reusing existing patient-level data for their project.
To summarize, the platforms connect data providers with data consumers in the domain of clinical, public health and
epidemiologic health research to foster reuse. Since the system is freely accessible via a web browser and provides
explanatory information about collected information via an extensive glossary, the system can also be used by scientists
of other research domains.
More and detailed information can be found [here](https://www.nfdi4health.de/en/service/health-study-hub.html).

## Deployment Configuration

The service is hosted in a [kubernetes](https://kubernetes.io) cluster. This repository contains the required cluster
configuration and
documentation. [Helm](https://helm.sh) is used as the package manager, and this repository also acts as the chart
repository for helm.
To add this repository to helm, use the following snippet:

```
helm repo add csh-deployment https://nfdi4health.github.io/csh-deployment/
helm repo update
```


## Funding

This work was done as part of the NFDI4Health Consortium and is published on behalf of this
Consortium (www.nfdi4health.de).
It is funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) – project number 442326535.

This work was done at [ZB MED - Information Centre for Life Sciences](https://www.zbmed.de/en/)
