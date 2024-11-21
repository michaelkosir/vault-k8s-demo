# vault-k8s-demo
This repository provides a demo of HashiCorp Vault on Kubernetes.

# Usage

### Requirements
- docker
- kind
- kubectl
- helm

### Terraform
Spin up a multi-node local K8s cluster with `kind`, and the deploy an HA Vault Cluster using `helm`.
```shell
terraform apply
```

### K8s
Verify K8s cluster exists and wait for Vault pods.
```shell
alias k="kubectl"

# verify k8s nodes exist
k get nodes

# verify vault pods exist
k get pods -n vault

# wait for vault pods
k wait -n vault --for=jsonpath='{.status.phase}'=Running pod/vault-{0..2}
```

### Vault
Initialize and Unseal Vault
```shell
# initialize the cluster, demo purposes, using 1 key share
k exec -n vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > init.json

# unseal each node manually 
k exec -n vault vault-0 -- vault operator unseal $(jq -r .unseal_keys_b64[0] init.json)
k exec -n vault vault-1 -- vault operator unseal $(jq -r .unseal_keys_b64[0] init.json)
k exec -n vault vault-2 -- vault operator unseal $(jq -r .unseal_keys_b64[0] init.json)

# verify nodes auto-joined the cluster
k exec -n vault vault-0 -- /bin/sh -c "VAULT_TOKEN=$(jq -r .root_token init.json) vault operator raft list-peers"
```
