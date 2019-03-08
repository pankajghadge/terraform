RUN:
   #cd to this vpc directory and run following commands
   terraform init
   terraform plan -var-file ..\..\base.tfvars
   terraform apply -var-file ..\..\base.tfvars
   terraform destroy -var-file ..\..\base.tfvars
