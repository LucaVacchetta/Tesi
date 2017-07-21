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

    provisioner "file" {
      source      = "setup_master.sh"
      destination = "/tmp/setup_master.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/setup_master.sh",
        "/tmp/setup_master.sh ${self.ipv4_address}",
      ]
    }

#    provisioner "remote-exec" {
#        script = "setup_master.sh"
#    }

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
  description = "Used in the terraform"
 #  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

# Permit access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0 #65535
    protocol    = -1 #"0" #permetto tutto il traffico
    cidr_blocks = ["0.0.0.0/0"]
  }

# Permit access from anywhere
#  ingress {
#    from_port   = 10250
#    to_port     = 10250
#    protocol    = "tcp"
#    cidr_blocks = ["172.31.27.96/32"]
#  }

  # Permit access from master node
#  ingress {
#    from_port   = 10250
#    to_port     = 10250
#    protocol    = "tcp"
#    cidr_blocks = ["172.0.0.0/8"]
#  }

  # Permit access from master node
#  ingress {
#    from_port   = 2379
#    to_port     = 2379
#    protocol    = "tcp"
#    cidr_blocks = ["${softlayer_virtual_guest.master.ipv4_address}/32"]
#  }

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
  public_key = "${file("/home/tesi/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "worker" {
    ami           = "${var.aws_ami}" # questo codice specifica CENTOS_7_64 del datacenter us-east-1 #"ami-5f709f34" codice ubuntu us-east-1
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
}

