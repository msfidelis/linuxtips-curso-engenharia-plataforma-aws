resource "aws_ssm_parameter" "teste" {
  name = "/Parameters/chip-teste-parameter"
  type = "String"
  value = "VIM DO PARAMETER STORE"
}

resource "aws_ssm_parameter" "toggle_fallback" {
  name = "/Parameters/chip/toggle-fallback"
  type = "String"
  value = "1"
}