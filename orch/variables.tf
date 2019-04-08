variable "region" {
  type    = "string"
  default = "us-west-2"
}
variable "name" {
  type    = "string"
  default = "orch"
}
variable "domain" {
  type    = "string"
  default = "codejam.ninja"
}
variable "volume_size" {
  type    = "string"
  default = "40"
}
variable "instance_type" {
  type    = "string"
  default = "t2.medium"
}
variable "rancher_version" {
  type    = "string"
  default = "latest"
}
variable "docker_version" {
  type    = "string"
  default = "18.09.4-ce"
}
variable "cloudflare_token" {
  type    = "string"
  default = "0"
}
variable "cloudflare_email" {
  type    = "string"
  default = "0"
}
