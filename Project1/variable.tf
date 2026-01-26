variable "first_bucket_name" {
     type = string
     default = "hosting-static-web-site"
}


variable "environment_dev" {
     type = string
     default = "dev"
}

variable "logs" {
  type= string
  default = "static-website-logs"
}