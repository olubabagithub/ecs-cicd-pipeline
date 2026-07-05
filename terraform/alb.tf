#############################################
# Application Load Balancer
#############################################

resource "aws_lb" "app_alb" {
  name               = "flask-cicd-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  tags = {
    Name = "flask-cicd-alb"
  }
}

#############################################
# Target Group
#############################################

resource "aws_lb_target_group" "ecs_tg" {

  name        = "flask-cicd-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2
  }

  tags = {
    Name = "flask-cicd-target-group"
  }
}

#############################################
# HTTP Listener
#############################################

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.app_alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}