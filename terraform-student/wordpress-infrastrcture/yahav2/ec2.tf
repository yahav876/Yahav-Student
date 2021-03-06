data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_iam_instance_profile" "wp_profile" {
  name = "wpprofile"
  role = aws_iam_role.s3accessEC2.name
}

data "aws_security_group" "secgroup" {
          depends_on = [aws_security_group.wp_sg]
          tags = {
            Name = "allow_tls"
          }
}

data "template_file" "userdata-wp" {
  template = "./user-data.tpl"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.wp_profile.name
  depends_on = [aws_security_group.wp_sg]
  vpc_security_group_ids = [data.aws_security_group.secgroup.id]
  user_data = data.template_file.userdata-wp.rendered
  tags = {
    Name = "wordpress"
  }
}