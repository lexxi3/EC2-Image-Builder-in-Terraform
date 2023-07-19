variable "ec2_iam_role_name" {
  type = string
  default = "lexi-role"
}
variable "aws_key_pair_name" {
  type = string
  default = "lexi-test-key"
}
variable "aws_s3_log_bucket" {
  type = string
  default = "lexi-bucket"
}

variable "userdata_file" {
  type = string
  default = "script.sh"
}

variable "ebs_root_vol_size" {
  type = number
  default = "10"
}
variable "image_receipe_version" {
  type = string
  default = "1"
}
variable "ami_name_tag" {
  type = string
 default = "lexi-ami"
}
