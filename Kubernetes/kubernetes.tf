provider "softlayer" {
  username = "YOUR_USERNAME"
  api_key  = "YOUR_API_KEY"
}

resource "softlayer_ssh_key" "my_key" {
    label = "${var.user_string}"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
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
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    
    provisioner "file" {
      source      = "conf/virt7-docker-common-release.repo"
      destination = "/etc/yum.repos.d/virt7-docker-common-release.repo"
    }

    provisioner "file" {
      source      = "setup_master.sh"
      destination = "/tmp/setup_master.sh"
    }

    provisioner "file" {
      source      = "script-on-master.sh"
      destination = "/run/script-on-master.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/setup_master.sh",
        "chmod +x /run/script-on-master.sh",
        "/tmp/setup_master.sh ${self.ipv4_address}",
      ]
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
        private_key = "${file("~/.ssh/id_rsa")}"
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
        "/tmp/setup_worker.sh ${softlayer_virtual_guest.master.ipv4_address} ${self.ipv4_address}",
      ]
    }
}

provider "aws" {
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
  region     = "us-east-1"
}

# Our default security group to access
# the instances over SSH
resource "aws_security_group" "ssh" {
  name        = "ssh_security"
  description = "Security group of AWS machine"

# Permit access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0 
    protocol    = -1 
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "key-aws-ssh"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "worker" {
    ami           = "${var.aws_ami}" # questo codice specifica CENTOS_7_64 del datacenter us-east-1
    instance_type = "t2.micro"
    key_name      = "${aws_key_pair.deployer.id}"

    # Our Security group to allow SSH access
    vpc_security_group_ids = ["${aws_security_group.ssh.id}"]

    provisioner "file" {
      source      = "conf/virt7-docker-common-release.repo"
      destination = "/tmp/virt7-docker-common-release.repo"

      connection {
        user = "centos"
        private_key = "${file("id_rsa.pem")}"
        agent = false
        timeout = "1m"
      }
    }

    provisioner "file" {
      source      = "setup_worker.sh"
      destination = "/tmp/setup_worker.sh"

      connection {
        user = "centos"
        private_key = "${file("id_rsa.pem")}"
        agent = false
        timeout = "1m"
      }
    }

    provisioner "remote-exec" {
      connection {
        user = "centos"
        private_key = "${file("id_rsa.pem")}"
        agent = false
        timeout = "1m"
      }

      inline = [
        "sudo mv /tmp/virt7-docker-common-release.repo /etc/yum.repos.d/virt7-docker-common-release.repo",
        "chmod +x /tmp/setup_worker.sh",
        "sudo /tmp/setup_worker.sh ${softlayer_virtual_guest.master.ipv4_address} ${self.public_ip}"
      ]
    }
   
    provisioner "local-exec" {
      command = "./local-script.sh ${softlayer_virtual_guest.master.ipv4_address} ${softlayer_virtual_guest.worker.ipv4_address} ${self.public_ip}"
    }

}

