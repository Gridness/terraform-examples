resource "minio_iam_group" "devops" {
  name = "devops"
}

resource "minio_iam_group" "worker" {
  name = "worker"
}

resource "minio_iam_group" "registry" {
  name = "registry"
}

resource "minio_iam_group_policy" "access_terraform_state" {
  name   = "access-terraform-state"
  group  = minio_iam_group.devops.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAllBucket",
            "Effect": "Allow",
            "Action": ["s3:PutObject"],
            "Principal": "*",
            "Resource": "arn:aws:s3:::terraform-state/*"
        }
    ]
}
EOF
}

resource "minio_iam_group_policy" "access_backup" {
  name   = "access-backup"
  group  = minio_iam_group.worker.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListAllBucket",
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket",
              "s3:GetBucketLocation",
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject",
              "s3:ListMultipartUploadParts",
              "s3:AbortMultipartUpload"
            ],
            "Principal": "*",
            "Resource": [
              "arn:aws:s3:::backup",
              "arn:aws:s3:::backup/*"
            ]
        }
    ]
}
EOF
}

resource "minio_iam_group_policy" "access_registry" {
  name   = "access-registry"
  group  = minio_iam_group.registry.id
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "s3:ListBucket",
       "s3:GetBucketLocation",
       "s3:ListBucketMultipartUploads"
     ],
     "Resource": [
      "arn:aws:s3:::registry"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "s3:AbortMultipartUpload",
       "s3:DeleteObject",
       "s3:GetObject",
       "s3:ListMultipartUploadParts",
       "s3:PutObject"
     ],
     "Resource": [
      "arn:aws:s3:::registry/*"
     ]
   }
 ]
}
EOF
}

resource "minio_iam_group_policy_attachment" "devops" {
  group_name  = minio_iam_group.devops.name
  policy_name = minio_iam_group_policy.access_terraform_state.name
}

resource "minio_iam_group_policy_attachment" "worker" {
  group_name  = minio_iam_group.worker.name
  policy_name = minio_iam_group_policy.access_backup.name
}

resource "minio_iam_group_policy_attachment" "registry" {
  group_name  = minio_iam_group.registry.name
  policy_name = minio_iam_group_policy.access_registry.name
}

resource "minio_iam_user" "developer" {
  name          = "developer"
  force_destroy = true
  tags = {
    "kind" = "dev"
  }
}

resource "minio_iam_user" "longhorn" {
  name          = "longhorn"
  force_destroy = true
  tags = {
    "kind" = "worker"
  }
}

resource "minio_iam_service_account" "longhorn" {
  target_user = minio_iam_user.longhorn.name
}

resource "minio_iam_user" "harbor" {
  name          = "harbor"
  force_destroy = true
}

resource "minio_iam_service_account" "harbor" {
  target_user = minio_iam_user.harbor.name
}

resource "minio_iam_group_membership" "devops" {
  name  = "devops-group-membership"
  users = [minio_iam_user.developer.name]
  group = minio_iam_group.devops.name
}

resource "minio_iam_group_membership" "worker" {
  name  = "worker-group-membership"
  users = [minio_iam_user.longhorn.name]
  group = minio_iam_group.worker.name
}

resource "minio_iam_group_membership" "registry" {
  name  = "registry-group-membership"
  users = [minio_iam_user.harbor.name]
  group = minio_iam_group.registry.name
}

resource "minio_s3_bucket" "terraform" {
  bucket         = "terraform-state"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket" "backup" {
  bucket         = "backup"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket" "registry" {
  bucket         = "registry"
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket_versioning" "terraform_versioning" {
  bucket = minio_s3_bucket.terraform.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "minio_s3_bucket_versioning" "backup_versioning" {
  bucket = minio_s3_bucket.backup.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "minio_s3_bucket_versioning" "registry_versioning" {
  bucket = minio_s3_bucket.registry.bucket
  versioning_configuration {
    status = "Enabled"
  }
}
