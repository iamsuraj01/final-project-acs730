# final-project-acs730
## Pre-Requirements

- An AWS account with appropriate permissions for creating resources
- Access to the GitHub repository where the workflow will be established
- Terraform installed locally or configured within any other environment like Cloud9
- Ansible installed locally or configured within any other environment like Cloud9
- Install Python boto3 for successful running of the codes
- Install GitHub and clone the project using the clone command
- Create S3 bucket named "**acs730-final-<your_name>-bucket**" and change all the places where S3 bucket is required

## Steps to Deploy Code

1. **Clone the Repository:**
   ```
   git clone https://github.com/iamsuraj01/final-project-acs730.git
   cd final-project-acs730
   ```

2. **Copy SSH key:**
   ```
   cd final-project-acs730/terraform/webserver/
   ssh-keygen -t rsa -f group9
   ```

3. **Terraform Configuration:**
   First, navigate to the network directory:
   ```
   cd ~/environment/final-project-acs730/terraform/network
   ```
   Then run the following commands:
   ```
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```
   Next, navigate to the webserver directory:
   ```
   cd ~/environment/final-project-acs730/terraform/webserver
   ```
   Repeat the same Terraform commands as above.

   **Note:** Before applying the terraform, we used the tag for webserver 3 and 4 as Owner: "**acs730**"

4. **Ansible Configuration:**
   ```
   pip3 install boto3
   python3 -m pip install --user ansible
   cd ~/environment/final-project-acs730/ansiblefinal/
   ```
   Replace bucket name in s3playbook.yml

   ```
   ansible-playbook s3playbook.yml  # it downloads the image from s3 bucket
   cd ~/environment/final-project-acs730/terraform/webserver/
   cp group9 ~/.ssh/
   cp group9.pub ~/.ssh/
   cd ~/.ssh/
   chmod 400 group9
   cd ~/environment/final-project-acs730/ansiblefinal/ 
   ansible-playbook -i aws_ec2.yml myplaybook.yml
   ```

   **Note:** Before using Ansible, we have to upload an image to the S3 bucket manually. The name of the file should be "**demo.png**", which is used in the Ansible configuration.

   #review
