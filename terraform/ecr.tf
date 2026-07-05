#############################################
# Elastic Container Registry (ECR)
#############################################

resource "aws_ecr_repository" "app" {
  name                 = "flask-cicd-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "flask-cicd-app"
  }
}