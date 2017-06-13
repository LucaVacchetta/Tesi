provider "aws" {
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE"
  region     = "us-east-1"
}

# resource "aws_iam_user" "luca" {
#  name = "tesi"
# }

# resource "aws_iam_user_ssh_key" "user" {
#  username   = "${aws_iam_user.luca.name}"
#  encoding   = "PEM"
#  public_key = "${file("/home/tesi/.ssh/id_rsa.pub")}"
# }

resource "aws_instance" "worker" {
    ami           = "${var.aws_ami}" # questo codice specifica CENTOS_7_64 del datacenter us-east-1
    instance_type = "t2.micro"

    provisioner "file" {
      source      = "conf/virt7-docker-common-release.repo"
      destination = "/etc/yum.repos.d/virt7-docker-common-release.repo"

      connection {
        private_key = "${file("/home/tesi/.ssh/id_rsa")}"
      }
    }

    provisioner "file" {
      source      = "setup_worker.sh"
      destination = "/tmp/setup_worker.sh"
    
      connection {
        private_key = "${file("/home/tesi/.ssh/id_rsa")}"
      }   
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/setup_worker.sh",
        "/tmp/setup_worker.sh ${var.kube_master_ip}",
      ]
    }
}
