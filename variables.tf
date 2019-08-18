###############
# AWS Config
###############

variable "aws_access_key" {
  default = "AKIAYT34IHRFZCCRHC6O"
}

variable "aws_secret_key" {
  default = "nNtd53uquQVUPbOxdQwenqUEaWIspcl+j8psRUa1"
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_key_name" {
  default = "York"
}

###############
# AWS VPC
###############

variable "vpc_CIDR_block" {
  default = "10.10.0.0/16"
}

variable "subnet_CIDR_block" {
  default = "10.10.1.0/24"
}

variable "runner_subnet_CIDR_block" {
  default = "10.10.2.0/24"
}

################
# Runners
################

variable "gitlab_runner_registration_token" {
  default = "UfnTqMomZuc2RUyddCQd"
}

variable "gitlab_runner_version" {
  description = "runner_version like 'v12.1.0' 'v11.11.4' 'v11.9.1' 'v11.4.0' 'v10.8.0'"
  default     = "v12.1.0"
}

variable "gitlab_runner_count" {
  default = "2"
}

variable "terraform_self_IP" {
  default = "220.238.18.137/32"
}

variable "gitlab_self_IP" {
  default = "8.8.8.8/32"
}
