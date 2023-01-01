variable "region" {
  description = "AWS Region"
  type        = string
}
variable "environment" {
  description = "Define the enviroment."
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Allowed values for env are \"dev\", \"stg\", or \"prod\"."
  }
}
variable "project_name" {
  description = "Project name"
  type        = string
}
variable "owner" {
  description = "Name of project owner"
  type        = string
}
variable "prefix" {
  description = "Default name of resources"
  type        = string
  default     = "prefix"
}
variable "cidr_vpc" {
  description = "IP Class"
  type        = string
  default     = "10.0.0.0/16"
}
variable "azs" {
  description = "Region's name"
  type        = list(string)
  default     = []
}
variable "cidr_public" {
  description = "Public IPs"
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "cidr_private" {
  type    = list(any)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
variable "cidr_database" {
  type    = list(any)
  default = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}
variable "instance_type" {
  description = "Type of instance"
  type        = string
}
variable "public_key" {
  description = "Public Key"
  type        = string
}