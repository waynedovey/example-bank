#!/bin/bash

export control_cluster=control_cluster
export cluster1=aws-cluster-shared-0
export cluster2=aws-cluster-shared-1
export cluster3=aws-cluster-shared-2

export infrastructure=aws

export cluster_base_domain=$(oc --context ${control_cluster} get dns cluster -o jsonpath='{.spec.baseDomain}')
export global_base_domain=global.${cluster_base_domain#*.}
for context in ${cluster1} ${cluster2} ${cluster3}; do
  oc --context ${context} new-project cockroachdb
  export uid=$(oc --context ${context} get project cockroachdb -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}'|sed 's/\/.*//')
  export guid=$(oc --context ${context} get project cockroachdb -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups}'|sed 's/\/.*//')
  export cluster=${context}
  envsubst < ./values.templ.yaml > /tmp/values.yaml
  helm --kube-context ${context} upgrade cockroachdb ./charts/cockroachdb-multicluster -i --create-namespace -n cockroachdb -f /tmp/values.yaml
done


oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach init --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local

oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach node status --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local

export tools_pod=$(oc --context ${cluster1} get pods -n cockroachdb | grep tools | awk '{print $1}')
oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach sql --execute='CREATE USER dba WITH PASSWORD dba;' --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local

oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach sql --execute='GRANT admin TO dba WITH ADMIN OPTION;' --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local

oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach sql --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local --echo-sql --execute='SET CLUSTER SETTING cluster.organization = '\""${cluster_organization}"\"';'

oc --context ${cluster1} exec $tools_pod -c tools -n cockroachdb -- /cockroach/cockroach sql  --certs-dir=/crdb-certs --host cockroachdb-0.aws-cluster-shared-0.cockroachdb.cockroachdb.svc.clusterset.local --echo-sql --execute='SET CLUSTER SETTING enterprise.license = '\""${enterprise_license}"\"';'
