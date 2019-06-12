resource "aws_s3_bucket" "tf_bucket" {
  bucket = "helloworld-tf-states"
  force_destroy = false
}

resource "aws_s3_bucket_policy" "tf_bucket_policy" {
  bucket = "${aws_s3_bucket.tf_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "helloworld-s3-tf-policy",
  "Statement": [
    {
      "Sid": "Allow only trusted IP range for tf states",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::helloworld-tf-states/*",
      "Condition": {
         "NotIpAddress": {"aws:SourceIp": "${var.trusted_ip_range}"}
      }
    }
  ]
}
POLICY
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "helloworld-tf-states"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
