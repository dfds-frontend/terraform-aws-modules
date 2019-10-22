// Configure Terragrunt to automatically store tfstate files in an S3 bucket. To get short intro to the used terragrunt specific functions, see bottom.
remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket = get_env("terraform_state_s3bucket", "terraform-state-${get_aws_account_id()}-example-s3bucket")
    key            = "${path_relative_to_include()}/terraform.tfstate" 
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
     source = "./../../"
}


/*
Description of used terragrunt specific functions:
'path_relative_to_include()' adds the relative path from the root terragrunt.hcl file and any child module being added, simplifying state structure in the bucket (resembling the module folder structure).
'get_env("environment variable name", "default value if not found"). In this file used to set the s3 bucket name to store the terraform state in.'
*/