resource "aws_secretsmanager_secret" "teste" {
  name = "chip-teste-v1"
}

resource "aws_secretsmanager_secret_version" "teste" {
  secret_id     = aws_secretsmanager_secret.teste.id
  secret_string = "Eu amo absurdamente pudim"
}

resource "aws_secretsmanager_secret" "teste_json" {
  name = "chip-teste-json-v1"
}

resource "aws_secretsmanager_secret_version" "teste_json" {
  secret_id = aws_secretsmanager_secret.teste_json.id
  secret_string = jsonencode({
    username = "root",
    password = "toor",
  })
}