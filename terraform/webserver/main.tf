provider "aws" {
  region = var.region
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "prod/network/terraform.tfstate"
    region = var.region
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "webserver" {
  name_prefix   = "${var.prefix}-${var.env}-webserver-lt"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webserver.id]
  }

  user_data = base64encode(templatefile("${path.module}/install_httpd.sh", {
    env = var.env
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-${var.env}-webserver"
    }
  }
}

resource "aws_autoscaling_group" "webserver" {
  name                = "${var.prefix}-${var.env}-webserver-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.public_subnet_ids
  desired_capacity    = 4
  max_size            = 8
  min_size            = 4

  launch_template {
    id      = aws_launch_template.webserver.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.webserver.arn]

  tag {
    key                 = "Name"
    value               = "${var.prefix}-${var.env}-webserver"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  

  tags = {
    Name = "${var.prefix}-${var.env}-bastion"
  }
}

# Private web servers
resource "aws_instance" "private_webserver" {
  count                  = 2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index]

 user_data = base64encode(templatefile("${path.module}/install_httpd.sh", {
    env = var.env
  }))

  tags = {
    Name = "${var.prefix}-${var.env}-private-webserver-${count.index + 1}"
  }
}

# Application Load Balancer
resource "aws_lb" "webserver" {
  name               = "${var.prefix}-${var.env}-webserver-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids

  tags = {
    Name = "${var.prefix}-${var.env}-webserver-alb"
  }
}

# ALB listener
resource "aws_lb_listener" "webserver" {
  load_balancer_arn = aws_lb.webserver.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.arn
  }
}

# ALB target group
resource "aws_lb_target_group" "webserver" {
  name     = "${var.prefix}-${var.env}-webserver-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_ebs_volume" "webserver" {
  count             = 4
  availability_zone = data.terraform_remote_state.network.outputs.public_subnet_azs[count.index % length(data.terraform_remote_state.network.outputs.public_subnet_azs)]
  size              = 10

  tags = {
    Name = "${var.prefix}-${var.env}-webserver-ebs-${count.index + 1}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.prefix}-${var.env}-deployer-key"
  public_key = file("${path.module}/deployer_key.pub")
}
