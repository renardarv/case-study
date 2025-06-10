variable "description" {
  type    = string
  default = "Transit Gateway"
}

variable "amazon_side_asn" {
  type    = number
  default = 64512
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
