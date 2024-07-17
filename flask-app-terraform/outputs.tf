output "application_name" {
  value = aws_elastic_beanstalk_application.flask_app.name
}

output "environment_name" {
  value = aws_elastic_beanstalk_environment.flask_env.name
}

output "environment_url" {
  value = aws_elastic_beanstalk_environment.flask_env.cname
}
