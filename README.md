## Prerequisites:

1. Login your gitlab and make sure your registration token of runners. Disable shared runners.

2. Make sure your AWS role have enough permissions.


## Tree

```
├───providers.tf
├───aws_ami.tf
├───aws_vpc.tf
├───main.tf
├───variable.tf
└───YOURKEY.pem

```


## How to use:

1. Fill in your AWS Role about "access_id" "secret_key" "region" and "key_name". The filename is variable.tf, AWS section.

2. Fill in your desired CIDR, do not cross the existing CIDRs. The filename is variable.tf, VPC section.

3. According to Prerequisites item1, Fill in token.

4. Select your desired Runner number and version. The filename is variable.tf, Runner section.

5. variable "terraform_self_IP" Used for Runner security group, let Terraform can remote-exec command via ssh port 22.

6. variable "gitlab_self_IP" used for AWS route table, let multiple runners can access your gitlab via NAT gateway only public IP.

7. copy your aws key here.


## Need to improve

1. More Runner need more EC2 instance. It is not economic. Consider spot instance or multiple dockers on one instance. To be continued.

2. Runners subnet currently is public subnet. It's possible to make it private, just use ssh to remote-exec provisioner via bastion instance.
   And now use security goup to limit internet accessable.
