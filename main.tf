#Helm install of sample app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = var.org 
    workspaces = {
      name = var.ikswsname
    }
  }
}

variable "ikswsname" {
  type = string
}
variable "org" {
  type = string
}

resource helm_release teaiksfrtfcb {
  name       = "metricsiksapp"
  namespace = "kube-system"
  chart = "https://prathjan.github.io/helm-chart/metrics-server-3.5.0.tgz"

}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key = base64decode(local.kube_config.users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  }
}

locals {
  kube_config = yamldecode(data.terraform_remote_state.iksws.outputs.kube_config)
}

