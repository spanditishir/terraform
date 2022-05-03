#To install jenkins, java and python
provider "aws" {
  region = "ap-south-1"
  access_key = "" 
  secret_key = ""
}
resource "aws_key_pair" "terraform-key" {
  key_name = "terraform-key"
  #public key is generate with ssh-keygen -t rsa -b 2048 -f <custom file location>
  public_key = ""
}
resource "aws_security_group" "tfSG" {
 name = "terraformSG"
 description = "THIS IS CREATED BY TERRAFORM: SHASHIKANT"
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
}
resource "aws_security_group_rule" "allow_8080" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks      = [ "0.0.0.0/0", ]
  security_group_id = aws_security_group.tfSG.id
}
resource "aws_instance" "aws-vscode" {
  ami = "ami-079b5e5b3971bd10d"
  instance_type = "t2.micro"
  key_name = aws_key_pair.terraform-key.key_name
  vpc_security_group_ids = [aws_security_group.tfSG.id]
  depends_on = [
    aws_key_pair.terraform-key,
    aws_security_group.tfSG
  ]
  provisioner "remote-exec" {
        connection {
        type = "ssh"
        host = self.public_ip
        port = 22
        user = "ec2-user"
        timeout = "4m"
		#private key is generate with ssh-keygen -t rsa -b 2048 -f <custom file location> and copied that and kept in privatekey.ppk file
        private_key=file("./privatekey.ppk")
    }
    inline  = [
      "sudo yum update –y",
      "sudo yum install java-1.8.0 -y",
      "sudo yum remove java-1.7.0-openjdk -y",
      "sudo yum -y install wget",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo yum install python37 -y",
      "sudo service jenkins start",
      "sudo systemctl status jenkins",
      "jenkins --version",
      "python3 --version"
      ]
  }
}
