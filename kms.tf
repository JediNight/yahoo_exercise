data "aws_iam_policy_document" "uploader_kms_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "s3_kms_key" {
  description = "KMS key for encrypting S3 objects"
  policy      = data.aws_iam_policy_document.uploader_kms_policy.json
}
