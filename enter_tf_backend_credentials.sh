#!/bin/bash

function fatal() {
    echo "Error: $1" >&2
    exit 1
}

function enter_credentials() {
    local minio_user
    local minio_pass

    read -r -p "Enter s3 admin user username: " minio_user || fatal "Failed to read username"

    read -r -s -p "Enter s3 admin user password: " minio_pass || fatal "Failed to read password"
    echo

    if [[ -z "$minio_user" || -z "$minio_pass" ]]; then
        fatal "Username and password cannot be empty"
    fi

    export AWS_ACCESS_KEY_ID="$minio_user"
    export AWS_SECRET_ACCESS_KEY="$minio_pass"

    unset minio_pass

    echo "Credentials set successfully"
}

function run() {
    enter_credentials
}

if run; then
    echo "Terraform S3 backend credentials initialized"
else
    fatal "An error occurred during credentials initialization for terraform s3 backend"
fi
