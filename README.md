# fullstack-kubernetes

"Why?", you ask?

![Why not?](https://raw.githubusercontent.com/anthcor/gifs/master/whynot/why-not.gif)

This project configures and deploys a wicked-simple, full-stack web application
that runs entirely on kubernetes and can be deployed in any kubernetes
environment.

This project uses [Google Cloud Platform's GKE](https://cloud.google.com/kubernetes-engine)
for kubernetes servicing, but should work on any managed, or self-managed
kubernetes cluster with similar configurations as per the specs in the
`gcloud container clusters create` CLI command.

## what you'll need

- `gcloud`
- `kubectl`
- `helm`
- `docker`
- `python3.8`
- `node12`

## what's included?

- **UI**: [react-admin](https://github.com/marmelab/react-admin)
- **API**: [FastAPI](https://github.com/tiangolo/fastapi)
- **PubSub**: [Apache Pulsar](https://github.com/apache/pulsar)
- **DB**: [Cockroach DB](https://github.com/cockroachdb/cockroach)
- **Secrets**: [Vault](https://github.com/hashicorp/vault)

## what does it do?

- Stores secrets in Vault which are accessed by the restful API.
- Provides a UI atop the restful API which persists data in Cockroach DB.
  Why Cockroach DB? [I'll let them tell you](https://www.cockroachlabs.com/docs/stable/training/why-cockroachdb.html).
- Sends and displays messages with Pulsar in the UI (message persistence is not
  implemented).


## instructions

### create the stack
```sh
git clone https://github.com/anthcor/fullstack-kubernetes
cd fullstack-kubernetes
./stackup

⏳

NGINX_CONTROLLER_INGRESS_IP=$(kubectl get services -l component=controller,app=nginx-ingress -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
curl -I -X GET "http://$NGINX_CONTROLLER_INGRESS_IP/"
curl -I -X GET "http://$NGINX_CONTROLLER_INGRESS_IP/api/v1/healthcheck"

# visit the ui
open http://$NGINX_CONTROLLER_INGRESS_IP/
# enter any username and password to interact with the ui

# create an item
http://$NGINX_CONTROLLER_INGRESS_IP/items

# send a message via pulsar
http://$NGINX_CONTROLLER_INGRESS_IP/messages

```

### delete the stack
```sh
./cleanup
```

## production

This is currently **not** an out-of-the-box, production-ready stack and should
be used for development, educational, and instructional purposes only.

In order for this to be production ready, the following would need to be done/
added (this is not an exhaustive list):
- network encryption at each layer
- a secured kubernetes cluster
- user login authentication
- each stack component would be secured appropriately (with tls, certs, etc)
- place the api and ui in their own separate host space
- proper rbac
- nix helm if you arent prepared to maintain helm charts
- make each component HA (highly-available)
- add a backup system ([velero](https://github.com/vmware-tanzu/velero) is a great example)
- database rollbacks
- layer autoscaling
- metrics, logging, and alerting
- what about cicd and tests? yup that too! [drone](https://drone.io) would be great to have
- less shell, more [terraform](https://terraform.io)

These may be added in future updates.


## contributions & suggestions

Did something not work correctly for you? Do you have a question or feature
suggestion? Want to add something cool?

Let me know! [Pull requests](https://github.com/anthcor/fullstack-kubernetes/compare)
and [issues](https://github.com/anthcor/fullstack-kubernetes/issues/new) are
 welcome.
