terraform {
  backend "s3" {
    bucket = "codejamninja-terraform"
    key    = "orch.codejam.ninja/nodes"
    region = "us-west-2"
  }
}
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "codejamninja-terraform"
    key    = "orch.codejam.ninja/nodes"
    region = "us-west-2"
  }
}
provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}
variable "aws_access_key" {
  type = "string"
}
variable "aws_secret_key" {
  type = "string"
}
variable "dedicated_desired_capacity" {
  type    = "string"
  default = "1"
}
variable "spot_desired_capacity" {
  type    = "string"
  default = "2"
}
variable "command" {
  type    = "string"
}
variable "region" {
  type    = "string"
  default = "us-west-2"
}
variable "name" {
  type    = "string"
  default = "servers"
}
variable "domain" {
  type    = "string"
  default = "codejam.ninja"
}
variable "volume_size" {
  type    = "string"
  default = "40"
}
variable "dedicated_instance_type" {
  type    = "string"
  default = "t2.medium"
}
variable "spot_instance_type" {
  type    = "string"
  default = "t2.large"
}
variable "docker_version" {
  type    = "string"
  default = "18.09.4-ce"
}
variable "ami" {
  type    = "string"
  default = "ami-0d554a1dd1d4ed527"
}
