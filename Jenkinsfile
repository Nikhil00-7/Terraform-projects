pipleline{
    agent any

    env {
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        TF_IN_AUTOMATION= "true"
    }
   stages{
    stages("Checkout code"){
        steps{
            git 'https://github.com/Nikhil00-7/Terraform-projects.git'
        }
    }

    stages("Terraform init"){
        steps{
            sh "terraform init"
        }
    }

    stages("Terraform plan"){
        steps{
            sh "terraform plan"
        }

    }

    stages("Terraform apply"){
        steps{
            sh "terraform apply --auto-approve"
        }
    }
   }

  post{
    success{
        echo "infrastructure deployed successfully"
     }
   }
    failure{
        echo "infrastructure deployment failed"
    }

}
