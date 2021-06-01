[{

    "name": "${container_name}",
    "image": "${image}",
    "essential" : true,
      "portMappings": [
      {
        "containerPort": ${container_port}
      }
    ],"logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "${cloudwatch_logs}",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
      }
  
  }]