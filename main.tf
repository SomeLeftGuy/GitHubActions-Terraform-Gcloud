
variable "AUTH_TOKEN" {
  type = string
}
provider "google" {
    project = "artful-patrol-313709"
    region = "eu-central2"
    access_token = var.AUTH_TOKEN
  
}
data "google_client_config" "google_provider" {}


data "google_container_cluster" "terraformcluster" {
    name = "terraformcluster"
    location = "europe-central2"
    
    
}

provider "kubernetes" {
    host = "https://${data.google_container_cluster.terraformcluster.endpoint}"
    token = data.google_client_config.google_provider.access_token
    cluster_ca_certificate = base64decode(
        data.google_container_cluster.terraformcluster.master_auth[0].cluster_ca_certificate,
    )
}


resource "kubernetes_deployment" "balancernode" {
    
    metadata {
      name = "balancernode-deployment"
      labels = {
        App = "balancernode"
      }
    }
    

    spec {
      replicas = 3
      selector  {
        match_labels = {
            App = "balancernode"
        }
      }
      template {
        metadata {
          labels = {
            App = "balancernode"
          }
        }
        spec {
         
         
          container {
            image = "europe-central2-docker.pkg.dev/artful-patrol-313709/testrepo/web-counter:latest"
            name = "balancernode"
            image_pull_policy = "IfNotPresent"
            port{
                container_port = 8080
            }
        
          resources{
            limits = {
              cpu = "0.8"
              memory = "1024Mi"
            }
            requests = {
                cpu = "0.5"
                memory = "250Mi"
            }
          }

        }

        container {
            image = "redis:latest"
            image_pull_policy = "Always"
            name = "redis"
            
            
            resources{
            limits = {
              cpu = "0.8"
              memory = "1024Mi"
            }
            requests = {
                cpu = "0.5"
                memory = "250Mi"
            }
          }

        }
        

        }
      }
    }
  
}

resource "kubernetes_service" "balancernodeservice" {
    metadata {
      name = "balancernode-service"
    }
  

    spec{
        selector = {
            App = kubernetes_deployment.balancernode.spec.0.template.0.metadata[0].labels.App

        }
        port {
            port = 3000
            target_port = 8080
        }

        type = "ClusterIP"
    }
}
resource "kubernetes_deployment" "balancer" {
    
    metadata {
      name = "balancer-deployment"
    labels = {
      App = "balancer"
    }
    }
    
  spec{
   replicas = 1
    selector  {
        match_labels = {
            App = "balancer"
        }
      }
    template {
      metadata {
        labels = {
          App = "balancer"
        }
      }
      spec {
        container {
         image = "europe-central2-docker.pkg.dev/artful-patrol-313709/testrepo/balancer:latest"
         image_pull_policy = "IfNotPresent" 
         name = "balancer"
          port{
                container_port = 80
            }
        
          resources{
            limits = {
              cpu = "0.8"
              memory = "1024Mi"
            }
            requests = {
                cpu = "0.5"
                memory = "250Mi"
            }
          }

        }
         
      }
    }
  }
}
resource "kubernetes_service" "balancerservice" {
    metadata {
      name = "balancer-service"
    }
  

    spec{
        selector = {
            App = kubernetes_deployment.balancer.spec.0.template.0.metadata[0].labels.App

        }
        port {
            port = 80
            target_port = 80
        }

        type = "LoadBalancer"
    }
}
