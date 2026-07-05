#############################################
# CloudWatch Log Group
#############################################

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/flask-cicd-app"
  retention_in_days = 7
}

#############################################
# ECS Cluster
#############################################

resource "aws_ecs_cluster" "main" {
  name = "flask-cicd-cluster"

  tags = {
    Name = "flask-cicd-cluster"
  }
}

#############################################
# ECS Task Definition
#############################################

resource "aws_ecs_task_definition" "app" {

  family                   = "flask-cicd-task"
  network_mode             = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "flask-app"

      image = "${aws_ecr_repository.app.repository_url}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#############################################
# ECS Service
#############################################

resource "aws_ecs_service" "app" {

  name            = "flask-cicd-service"

  cluster         = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count   = 2

  launch_type     = "FARGATE"

  network_configuration {

    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id
    ]

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    assign_public_ip = true
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.ecs_tg.arn

    container_name = "flask-app"

    container_port = 5000
  }

  depends_on = [
    aws_lb_listener.http
  ]
}