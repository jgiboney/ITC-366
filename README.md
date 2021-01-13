# it366 setup

## Linux Recommended

- It is highly recommended that you use a Linux machine to setup the following
- If you do not have one, you can install a Linux virtual machine inside VMware and setup everything using the vm

# Pre-requisites

## Install AWS Command Line Tool and Terraform

### Linux
- Open Command Prompt in Ubuntu - or your command prompt on Linux/Mac
- Add unzip (it is already installed on Mac)
    - ```sudo apt install unzip -y```
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
    - ```curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"```
    - ```unzip awscliv2.zip```
    - ```sudo ./aws/install```
    - ```aws --version```
- Add $HOME/.local/bin to path
    - ```
      vim .bashrc
          if [ -d "$HOME/.local/bin" ] ; then
              PATH="$HOME/.local/bin:$PATH"
          fi
      source .bashrc
      ```
- Install [Terraform](https://www.terraform.io/downloads.html)
    - ```curl "https://releases.hashicorp.com/terraform/0.14.4/terraform_0.14.4_linux_amd64.zip" -o "terraform.zip"```
    - ```unzip terraform.zip```
    - ```sudo mv terraform /usr/local/bin/```
    - ```terraform --version```

### Windows
- Install AWS CLI (https://awscli.amazonaws.com/AWSCLIV2.msi)
- 

## Logging in to AWS Educate and Get the Keys

- Log in to [https://www.awseducate.com](https://www.awseducate.com)
- Click the *My Classrooms* link
- Click the *Go to classroom* button alongside your desired classroom
- Under the *Your AWS Account Status* area, click the *Account Details* button
- Show the *AWS CLI* information - copy this into your *~/.aws/credentials* file
    - Open WSL
    - ```mkdir ~/.aws```
    - ```vim ~/.aws/credentials```
        - ```
            [default]
            aws_access_key_id=QWERTYUIOPASDFGHJKL
            aws_secret_access_key=tHisIsnOtanActUal/Key
            aws_session_token=Vy0suaL4NT1PrSLaPLZAT8fgbNpwhw07ByUvBZ6F0BSITkbUyrIOFUdQu6HDYVhskoQt4OGvTzi0PdLQwvI8FNnMrkESlFxeLSxVy0suaL4NT1PrSLaPLZAT8fgbNpwhw07ByUvBZ6F0BSITkbUyrIOFUdQu6HDYVhskoQt4OGvTzi0PdLQwvI8FNnMrkESlFxeLSxVy0suaL4NT1PrSLaPLZAT8fgbNpwhw07ByUvBZ6F0BSITkbUyrIOFUdQu6HDYVhskoQt4OGvTzi0PdLQwvI8FNnMrkESlFxeLSx
            ```
    - ATTENTION: The token generated renews quickly. Make sure you do not wait too long to start setting up everything, otherwise an error will appear.

- Click the *AWS Console* button to log into the console.
    - At the top right; ensure the region you are in is *N. Virginia*

# Part One Setup

## Terraform Infrastructure

- ```mkdir ~/GitRepos```
- ```cd ~/GitRepos```
- ```git clone https://github.com/jgiboney/ITC-366.git```
- ```cd ITC-366/partOne```
- ```terraform init```
- ```terraform apply```
- Accept the changes ```yes```
- If Terraform complains about credentials, go back to the *Logging in to AWS Educate and Get the Keys* section and re-create your ~/.aws/credentials file
- This will take a few minutes, but you should see the infrastructure appear in the AWS Console.
- The output from the terraform will give you details for logging in to the NAT Instance and the Linux Instance
    - chmod the PEM file
        - ```chmod 400 my-key.pem```
    - ssh into the NAT instance
        - ```ssh -i my-key.pem ec2-user@123.123.123.123```
    - log out of the NAT instance
        - ```exit```
    - use the tunnel script to log into the private linux instance via the NAT
        - ```ssh -f -i my-key.pem ec2-user@123.123.123.123 -L 10000:172.31.129.100:22 sleep 5; ssh -i my-key.pem -p 10000 ec2-user@127.0.0.1```
    - check that NAT is setup correctly
        - ```ping google.com```
- If the above commands do not work for ssh connections, try using the following format instead
    - All of the information of your instance can be found on AWS EC2.
        - ```ssh -i "[publicKey.pem]" [your username]@[your public ipv4 DNS]```
    - The command should look something like this:
        - ```ssh -i "my-key.pem" ec2-user@ec2-123-123-123-123.us-east-1.compute.amazonaws.com```
- Once you are finished, you can use ```terraform destroy``` to remove the entire infrastructure if you want.

# Part Two Setup

- Infrastructure in this part does not collide with part 1. They can run together or separately.
- You DO NOT need to destroy everything in part one to run part two.

## Terraform Infrastructure

- Navigate to your GitHub folder that you cloned from part one
- ```cd partTwo```
- ```terraform init```
- ```terraform apply```
- Accept the changes ```yes```
- If Terraform complains about credentials, go back to the *Logging in to AWS Educate* section and re-create your ~/.aws/credentials file
- This will take a few minutes, but you should see the infrastructure appear in the AWS Console.

## Routing in AWS

- Part Two creates three subnets in AWS
    - ```172.31.101.0/24```
    - ```172.31.102.0/24```
    - ```172.31.103.0/24```
- And three EC2 instances
    - 2 Clients in the 101 and 102 subnets
    - 1 Router in the 103 Subnet
- Security Groups
    - 101 and 102 can only talk to the router

### Try the following if your machines cannot ping each other
- Turn on IP Forwarding on the router (SSH into the router)
```
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
```

- Add routes to the route tables in the clients (SSH into the clients). Change the x, y, and z depending on the client and instance.
```
sudo route add -net 172.31.10x.0 netmask 255.255.255.0 gw 172.31.y.z
```
## Note
- Source/Destination Checks must be turned off for the router and the added network cards for traffic to flow
```
source_dest_check = false
```
- Once you are finished, you can use ```terraform destroy``` to remove the entire infrastructure.

## Resources for Mac users
- https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
- https://www.terraform.io/downloads.html

- For Mac Terraform install. Download the above terraform download then move the terraform file to /usr/local/bin


