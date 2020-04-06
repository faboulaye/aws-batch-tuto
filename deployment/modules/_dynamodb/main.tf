
resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "isbn"
  range_key      = "title"

  attribute {
    name = "isbn"
    type = "S"
  }

  attribute {
    name = "title"
    type = "S"
  }

  tags = {
    Name        = var.table_name
    Environment = "formation"
    Description = "AWS Batch - tutorial"
  }
}
