import os

terraform_script_directory = r"C:\Users\Jonah Chambers\Documents\TerraForm\NFS connect"

MainT = r"NFS.tf"

os.chdir(terraform_script_directory)


## PART C
os.system('terraform init')
os.system('terraform validate')
os.system('terraform apply')