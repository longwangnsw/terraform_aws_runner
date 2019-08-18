resource "aws_instance" "my-bastion-instance" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.My_Terra_VPC_Bastion_SG.id}"]
  subnet_id              = "${aws_subnet.My_Terra_VPC_Subnet.id}"
  key_name               = "${var.aws_key_name}"
  tags = {
    Name = "Bastion"
  }
}

resource "aws_eip" "bastion_EIP" {
  vpc = true
  instance                  = "${aws_instance.my-bastion-instance.id}"
  associate_with_private_ip = "${aws_instance.my-bastion-instance.private_ip}"
  depends_on                = ["aws_internet_gateway.My_Terra_VPC_IGW"]
}

resource "aws_instance" "my-runner-instance" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.My_Terra_VPC_Runner_SG.id}"]
  subnet_id              = "${aws_subnet.My_Terra_VPC_Runner_Subnet.id}"
  key_name               = "${var.aws_key_name}"
  count                  = "${var.gitlab_runner_count}"
  depends_on             = ["aws_route_table.My_Terra_VPC_route_table"]
  tags = {
    Name = "Runner"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("York.pem")}"
    }

    inline = [
      "sudo apt update",
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo docker run -d -e DOCKER_IMAGE=ruby:2.1 -e RUNNER_NAME=terra-runner -e CI_SERVER_URL=https://gitlab.com/ -e REGISTRATION_TOKEN=${var.gitlab_runner_registration_token} -e RUNNER_EXECUTOR=docker -e REGISTER_NON_INTERACTIVE=true --name gitlab-runner --restart always -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:alpine-${var.gitlab_runner_version}",
      "sudo docker exec -it gitlab-runner gitlab-runner register"
    ]
  }
}

output "Bastion_IP" {
  value = "${aws_eip.bastion_EIP.public_ip}"
}

output "NAT_IP" {
  value = "${aws_eip.NAT_EIP.public_ip}"
}
