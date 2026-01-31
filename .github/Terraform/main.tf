# S3 Bucket

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.s3_bucket_name
}

# Block public access (recommended)
resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# EC2 Instance

resource "aws_instance" "my_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "my-first-ec2"
  }
}
