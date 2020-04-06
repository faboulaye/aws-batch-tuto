provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = var.profile
}

module "db" {
  source = "./modules/_dynamodb"
}

module "bucket" {
  source = "./modules/_s3"
}

module "batch" {
  source = "./modules/_batch-job"
}

module "event" {
  source = "./modules/_event"
  batch-job-queue-arn = module.batch.batch-job-queue-arn
  batch-job-definition-arn = module.batch.batch-job-definition-arn
}



