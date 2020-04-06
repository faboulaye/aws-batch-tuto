output "batch-job-definition-arn" {
    value = aws_batch_job_definition.batch-job-def.arn
}
output "batch-job-queue-arn" {
    value = aws_batch_job_queue.batch-job-queue.arn
}