######################
# REQUIRED VARIABLES #
######################

variable "greeting" {
  description = "The greeting"
  type        = string
}


######################
# OPTIONAL VARIABLES #
######################

variable "greetee" {
  description = "The greetee"
  type        = string
  default     = "Engineer!"
}
