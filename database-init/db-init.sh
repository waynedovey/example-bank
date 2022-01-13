#!/bin/bash

oc process postgresql-persistent -p DATABASE_SERVICE_NAME=creditdb -p POSTGRESQL_USER=postgres -p POSTGRESQL_PASSWORD=postgres -p POSTGRESQL_DATABASE=example -n openshift |  oc create -f -

oc apply -f job.yaml
