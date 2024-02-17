

variable "region" {
  description = "The AWS region to deploy the infrastructure."
  default     = "us-east-1"
}


variable "alarm_email_address" {
  description = "Email address for CloudWatch alarm notifications."
  default     = "tafawibe@gmail.com"  
}