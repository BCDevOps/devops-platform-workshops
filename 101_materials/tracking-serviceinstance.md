

oc -n zswelr-dev get dc -l 'template.openshift.io/template-instance-owner=a3b5d74e-4191-11ea-afd1-005056832285'

oc -n zswelr-dev get ServiceInstance -o json | jq '.items[] | .spec | .parametersFrom // {} | .secretKeyRey // {} | .name'

  .spec.parametersFrom.secretKeyRey.name = mongodb-ephemeral-parameters6f2xh
    .data.parameters
  .spec.externalID = a04327e6-4191-11ea-ac3e-0a58ac3311c3


oc api-resources | grep -i 'service'


oc -n zswelr-dev get ClusterServicePlan
oc -n zswelr-dev get ClusterServiceClass
oc -n zswelr-dev get ClusterServiceBroker

oc -n zswelr-dev get ServiceInstance
oc -n zswelr-dev get ServicePlan,ServiceClass,ServiceBroker,ServiceBinding

oc -n zswelr-dev get TemplateInstance/a04327e6-4191-11ea-ac3e-0a58ac3311c3
  .metadata.uid = a3b5d74e-4191-11ea-afd1-005056832285

oc -n zswelr-dev get ClusterServicePlan/c2a633d9-47bb-11e6-b25f-005056832285
oc -n zswelr-dev get ClusterServiceClass/c2a633d9-47bb-11e6-b25f-005056832285

oc -n zswelr-dev get BrokerTemplateInstance/a04327e6-4191-11ea-ac3e-0a58ac3311c3

NOTE: there are orphans BrokerTemplateInstance!!!
oc -n zswelr-dev get BrokerTemplateInstance

oc -n zswelr-dev get ServiceInstance/mongodb-ephemeral-wq975

oc -n zswelr-dev get ServiceInstance/mongodb-ephemeral-wq975 -o 'custom-columns=ID:.spec.externalID'

oc -n zswelr-dev get BrokerTemplateInstance | grep 'zswelr-dev/' | grep 'fa793478-41ed-11ea-ac3e-0a58ac3311c3'


oc -n zswelr-dev get BrokerTemplateInstance --no-headers | grep 'zswelr-dev/' | wc -l

oc -n zswelr-dev get ServiceInstance --no-headers | wc -l