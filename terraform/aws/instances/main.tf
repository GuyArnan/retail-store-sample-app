provider "aws" {
  region = "us-west-2"
}

module "ec2_instance" {
  source = "../modules/ec2"

  instance_name  = "k8s-node"
  ami_id         = "ami-00c257e12d6828491"
  instance_type  = "t2.medium"
  key_name       = "test"
  subnet_ids     = ["subnet-0f92233e44d3044ef", "subnet-007ab506046047319", "subnet-006538decc4e58a2e"]
  instance_count = 3

inbound_from_port  = ["0", "6443", "22", "30000", "0"]
inbound_to_port    = ["65000", "6443", "22", "32768", "65000"]
inbound_protocol   = ["TCP", "TCP", "TCP", "TCP", "TCP"]
inbound_cidr       = ["172.31.0.0/16", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "10.244.0.0/16"]
outbound_from_port = ["0"]
outbound_to_port   = ["0"]
outbound_protocol  = ["-1"]
outbound_cidr      = ["0.0.0.0/0"]
}


#Following rows will allow for tf import (i messed up in this part)
resource "aws_vpc" "k8s_vpc" {}

resource "aws_security_group" "k8s_node_sg" {
	vpc_id = "vpc-056ce3209e600532b"

	lifecycle {
		ignore_changes = [description]
	}
}

resource "aws_subnet" "k8s_subnet_1" {
	vpc_id = "vpc-07989caf66553c21f"
	cidr_block = "10.0.1.0/24"

	lifecycle {
		ignore_changes = [vpc_id,
				  cidr_block,
				  availability_zone]

	}
}

resource "aws_subnet" "k8s_subnet_2" {
        vpc_id = "placeholder"
	cidr_block = "10.0.2.0/24"

	lifecycle {                                                                                  
		ignore_changes = [vpc_id,                                                            
                                  cidr_block,                                                        
                                  availability_zone]                                                 
  }
}

resource "aws_instance" "control_plane" {
	ami	= "ami-0ec1bf4a8f92e7bd1"
	instance_type = "t2.medium"

	lifecycle {
		ignore_changes = [tags]
	}
}

resource "aws_instance" "worker_1" {
	ami	= "ami-0ec1bf4a8f92e7bd1"
	instance_type = "t2.medium"

	lifecycle {
		ignore_changes = [tags]
	}
}

resource "aws_instance" "worker_2" {
        ami     = "ami-0891b4cd4109535b1"
        instance_type = "t2.medium"
	
	lifecycle {
		ignore_changes = [tags]
	}
}
