resource "kind_cluster" "this" {
  name           = "vault"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}

resource "helm_release" "vault" {
  depends_on = [kind_cluster.this]

  name       = "vault"
  chart      = "vault"
  version    = "0.29.0"
  repository = "https://helm.releases.hashicorp.com"

  namespace        = "vault"
  create_namespace = true

  values = [file("./values/community.yml")]
}
