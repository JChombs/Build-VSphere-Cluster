import os

ScriptPath = r"C:\Users\Jonah Chambers\Documents\TerraForm\Assignment4\main.tf"
terraform_script_directory = r"C:\Users\Jonah Chambers\Documents\TerraForm\Assignment4"

os.chdir(terraform_script_directory)


## PART C
os.system('terraform init')
os.system('terraform validate')

var = input('Are we destroying or applying?: ')

if var == 'apply':
    os.system('terraform apply --var-file="private.tfvars"')

if var == 'destroy':
    os.system('terraform destroy -var-file="private.tfvars"')

else:
    print('Syntax invalid')