resource "aws_security_group" "instance-sg" {
  name        = "Ks Node SG"
  description = "SG for Kubeadm Nodes"

  dynamic "ingress" {
    for_each = toset(range(length(var.inbound_from_port)))
    content {
      from_port   = var.inbound_from_port[ingress.key]
      to_port     = var.inbound_to_port[ingress.key]
      protocol    = var.inbound_protocol[ingress.key]
      cidr_blocks = [var.inbound_cidr[ingress.key]]
    }
  }

  dynamic "egress" {
    for_each = toset(range(length(var.outbound_from_port)))
    content {
      from_port   = var.outbound_from_port[egress.key]
      to_port     = var.outbound_to_port[egress.key]
      protocol    = var.outbound_protocol[egress.key]
      cidr_blocks = [var.outbound_cidr[egress.key]]
    }
  }
}
