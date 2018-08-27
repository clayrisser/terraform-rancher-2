variable "region" {
  type    = "string"
  default = "us-west-2"
}
variable "name" {
  type    = "string"
  default = "orch"
}
variable "pub_key_path" {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}
variable "domain" {
  type    = "string"
}
variable "volume_size" {
  type    = "string"
  default = "40"
}
variable "instance_type" {
  type    = "string"
  default = "t2.large"
}
