resource "aws_ecs_cluster" "mailhog-cluster" {
  name = "mailhog-cluster"
  tags = {
    Name = "mailhog-cluster"
  }

}

resource "aws_ecs_task_definition" "mailhog" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "mailhog"
  container_definitions = jsonencode([
    {
      name    = "mailhog",
      command = [],
      image   = "mailhog/mailhog",
      portMappings = [
        {
          "name"          = "mailhog-8025-tcp",
          "containerPort" = 8025,
          "hostPort"      = 8025,
          "protocol"      = "tcp",
          "appProtocol"   = "http"
        }
      ],
      environment = [
        {
          "name"  = "MH_WEB_HOST",
          "value" = "MH_WEB_HOST"
        },
        {
          "name"  = "MH_PORT",
          "value" = "1025"
        },
        {
          "name"  = "MH_WEB_PORT",
          "value" = "8025"
        },
        {
          "name"  = "MH_SMTP_PORT",
          "value" = "1025"
        },
        {
          "name"  = "MH_API_PORT",
          "value" = "8025"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "mailhog" {
  name            = "mailhog"
  cluster         = aws_ecs_cluster.mailhog-cluster.id
  task_definition = aws_ecs_task_definition.mailhog.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.mailhog_security_group.id]
    subnets = [
      aws_subnet.mailhog_vpc_public_subnet.id,
    ]
    assign_public_ip = true
  }
}

