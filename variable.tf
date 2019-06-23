variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "ec2 region for the vpc"
    default = "us-west-2"
}
variable "amis" {
    description = "ami by region"
    default = {
        us-west-2 = "ami- 63336763996"
}
}
variable "vpc_cidr" {
    description = "aboutvpccidr"
    default = "10.0.0.0/16" 
}  
variable "public1_subnet_cidr" {
    description = "about subnet cidr"
    default= "10.0.0.0/24"
}
variable "private2_subnet_cidr" {
    description= "about subnet cidr"
    default = "10.0.3.0/24"
}
variable "public2_subnet_cidr" {
    description = "about subnet cidr"
    default = "10.0.1.0/24"
}
variable "private1_subnet_cidr" {
    description = "about subnet cidr"
    default = "10.0.2.0/24"
}
