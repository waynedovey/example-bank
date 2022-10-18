#!/bin/bash

oc create secret generic mobile-simulator-secrets --from-env-file=mobile-simulator-secrets

oc create secret generic bank-db-secret --from-literal=DB_SERVERNAME=creditdb --from-literal=DB_PORTNUMBER=5432 --from-literal=DB_DATABASENAME=example --from-literal=DB_USER=postgres --from-literal=DB_PASSWORD=postgres


oc create secret generic bank-oidc-secret --from-literal=OIDC_JWKENDPOINTURL=https://au-syd.appid.cloud.ibm.com/oauth/v4/264d9ed3-389a-4c7e-8a0f-94eb7054a160/publickeys --from-literal=OIDC_ISSUERIDENTIFIER=https://au-syd.appid.cloud.ibm.com/oauth/v4/264d9ed3-389a-4c7e-8a0f-94eb7054a160 --from-literal=OIDC_AUDIENCES=2a9e390f-2056-4dfe-be89-643de51cc9bf
