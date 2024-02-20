## these commands are intended for workshops facilitators doing cleanup
oc -n d8f105-tools delete --all all,secret,configmap,pvc,route,svc,pipelines,pipelineruns,tasks,pdb,triggerBindings,triggerTemplates 
oc -n d8f105-dev delete --all all,secret,configmap,pvc,route,svc,pipelines,pipelineruns,tasks,pdb,triggerBindings,triggerTemplates 