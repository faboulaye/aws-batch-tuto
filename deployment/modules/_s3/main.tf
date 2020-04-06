resource "random_string" "random" {
  length  = 4
  upper   = false
  lower   = true
  number  = false
  special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${random_string.random.result}"

  tags = {
    Name        = var.bucket_name
    Environment = "formation"
    Description = "AWS Batch - tutorial"
  }
}

resource "aws_sns_topic" "topic" {
  name = "s3-event-notification-topic"

  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[{
          "Effect": "Allow",
          "Principal": {"AWS":"*"},
          "Action": "SNS:Publish",
          "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
          "Condition":{
              "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.bucket.arn}"}
          }
      }]
  }
  POLICY
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id
  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectCreated:Put"]
  }
}
