data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "apache" {
  name        = "allow appache"
  description = "Allow apache inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh from  admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion.id]
   
  }
   ingress {
    description      = "alb for end users"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb.id]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "stage-apache-sg"
    terrform="true"
  }
}

resource "aws_instance" "apache" {
  ami           = "ami-094bbd9e922dc515d"
  instance_type = "t2.micro"
  subnet_id=aws_subnet.private[0].id 
  vpc_security_group_ids=[aws_security_group.bastion.id,aws_security_group.alb.id]

  tags = {
    Name = "stage-apache"
  }
}