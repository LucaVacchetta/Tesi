provider "softlayer" {
  username = "YOUR_USERNAME"
  api_key  = "YOUR_API_KEY"
}

resource "softlayer_ssh_key" "my_key" {
    label = "${var.user_string}"
    public_key = "${file("/home/tesi/.ssh/id_rsa.pub")}"
}

resource "softlayer_virtual_guest" "master" {
    hostname          = "kube-master-${var.user_string}"
    domain            = "bluereply.it"
    os_reference_code = "CENTOS_7_64"
    datacenter        = "${var.datacenter}"
    cores             = 1
    memory            = 1024
    hourly_billing    = true
    local_disk        = true

    ssh_key_ids = [
        "${softlayer_ssh_key.my_key.id}"
    ]

    connection {
        private_key = "${file("/home/tesi/.ssh/id_rsa")}"
    }

    provisioner "file" {
      source      = "conf/virt7-docker-common-release.repo"
      destination = "/etc/yum.repos.d/virt7-docker-common-release.repo"
    }


    provisioner "remote-exec" {
        script = "setup_master.sh"
    }

}

resource "softlayer_virtual_guest" "worker" {
    count             = "${var.worker_count}"
    hostname          = "kube-worker-${var.user_string}-${count.index}"
    domain            = "bluereply.it"
    os_reference_code = "CENTOS_7_64"
    datacenter        = "${var.datacenter}"
    cores             = 1
    memory            = 1024
    local_disk        = true

    ssh_key_ids = [
        "${softlayer_ssh_key.my_key.id}"
    ]

    connection {
        private_key = "${file("/home/tesi/.ssh/id_rsa")}"
    }

    provisioner "file" {
      source      = "conf/virt7-docker-common-release.repo"
      destination = "/etc/yum.repos.d/virt7-docker-common-release.repo"
    }

    provisioner "file" {
      source      = "setup_worker.sh"
      destination = "/tmp/setup_worker.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/setup_worker.sh",
        "/tmp/setup_worker.sh ${softlayer_virtual_guest.master.ipv4_address}",
      ]
    }
}

provider "aws" {
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE"
  region     = "us-east-1"
}

# sia aws_iam_user che aws_iam_user_ssh_key non dovrebbero servire
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
        "/tmp/setup_worker.sh ${softlayer_virtual_guest.master.ipv4_address}",
      ]
    }
}
