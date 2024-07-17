provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_iam_instance_profile" "eb_profile" {
  name = "elasticbeanstalk-instance-profile"
  role = aws_iam_role.eb_role.name
}

resource "aws_iam_role" "eb_role" {
  name = "elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_role_policy_attachment" {
  role       = aws_iam_role.eb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_elastic_beanstalk_application" "flask_app" {
  name        = var.application_name
  description = "Flask application deployed to Elastic Beanstalk"
}

resource "aws_s3_bucket" "eb_bucket" {
  bucket = "${var.application_name}-eb-bucket"
}

resource "aws_s3_object" "flask_app" {
  bucket = aws_s3_bucket.eb_bucket.bucket
  key    = "${var.application_name}.zip"
  source = "../app.zip"
  etag   = filemd5("../app.zip") 
}

resource "aws_elastic_beanstalk_application_version" "flask_app_version" {
  name        = "v1"
  application = aws_elastic_beanstalk_application.flask_app.name
  description = "Application version created by Terraform"
  bucket      = aws_s3_bucket.eb_bucket.bucket
  key         = aws_s3_object.flask_app.key
}

resource "aws_elastic_beanstalk_environment" "flask_env" {
  name                = var.environment_name
  application         = aws_elastic_beanstalk_application.flask_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running Python 3.11"
  version_label       = aws_elastic_beanstalk_application_version.flask_app_version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PYTHONPATH"
    value     = "/var/app/current"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FLASK_APP"
    value     = "application.py"
  }
}
