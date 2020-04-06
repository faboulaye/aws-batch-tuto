resource "aws_iam_role" "batch-events" {
  name = "batch-events-role"
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy_attachment" "batch-events-policy" {
  role       = aws_iam_role.batch-events.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole"
}



resource "aws_cloudwatch_event_rule" "batch-event-rule" {
  name        = "capture-aws-s3-put"
  description = "Capture each AWS S3 put"

  event_pattern = <<PATTERN
    {
      "source": [
        "aws.s3"
      ],
      "detail-type": [
        "AWS API Call via CloudTrail"
      ],
      "detail": {
        "eventSource": [
          "s3.amazonaws.com"
        ],
        "eventName": [
          "PutObject"
        ]
      }
    }
  PATTERN
}

resource "aws_cloudwatch_event_target" "batch-job-target" {
  rule      = aws_cloudwatch_event_rule.batch-event-rule.name
  arn      = var.batch-job-queue-arn
  role_arn = aws_iam_role.batch-events.arn
  batch_target {
    job_definition = var.batch-job-definition-arn
    job_name       = "example-batch-job"
    job_attempts   = 2
  }
  input_transformer {
    input_paths = {
      "S3_BUCKET_VALUE" = "$.detail.requestParameters.bucketName",
      "S3_KEY_VALUE" =  "$.detail.requestParameters.key"
    }
    input_template = <<INPUT_TEMPLATE
      {
        "S3_BUCKET": <S3_BUCKET_VALUE>, 
        "S3_KEY": <S3_KEY_VALUE>
      }
    INPUT_TEMPLATE
  }

}