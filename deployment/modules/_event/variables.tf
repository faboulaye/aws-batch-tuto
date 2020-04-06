variable "batch-cpt-env" {
  default = "batch-compute-environment"
}

variable "batch-sg" {
  default = "batch-compute-environment-sg"
}

variable "batch-cpt-env-subnet" {
  default = "cloudops-vpc-PrivateSubnet1AppID"
}

variable "batch-job-definition-arn" {
  type = string
} 

variable "batch-job-queue-arn" {
  type = string
}

