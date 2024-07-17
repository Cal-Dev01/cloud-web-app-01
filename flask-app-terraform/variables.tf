variable "region" {
  description = "The AWS region to deploy the application"
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
}

variable "application_name" {
  description = "The name of the Elastic Beanstalk application"
  type        = string
  default     = "flask-app"
}

variable "environment_name" {
  description = "The name of the Elastic Beanstalk environment"
  type        = string
  default     = "flask-env"
}
