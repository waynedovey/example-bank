## Repository for demo Submariner and RHACM

All of this commands needs to be performed in the ACM Hub cluster to deploy through GitOps.

* Deploy the transaction-service

```
oc apply -k transaction-service-app/acm-resources
```