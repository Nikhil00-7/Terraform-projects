                      Hosting a Static Website on AWS using Terraform  


## Project Overview
 
This project demonstrates how to host a secure and highly available static website on AWS using Terraform.  
The architecture leverages Amazon S3 for storage, Amazon CloudFront for global content delivery, and AWS Certificate Manager (ACM) to enable HTTPS.

## Architecture Explanation

1. Users access the website using a CloudFront distribution URL or custom domain.
2. CloudFront serves content from the nearest Edge Location to reduce latency.
3. An Amazon S3 bucket is configured as the origin to store static website files such as:
   - index.html
   - style.css
   - script.js
4. Origin Access Control (OAC) ensures that the S3 bucket is not publicly accessible and can only be accessed by CloudFront.
5. AWS Certificate Manager (ACM) provides an SSL/TLS certificate to enable HTTPS for secure communication.
6. An S3 bucket policy allows CloudFront to fetch content securely from the bucket.


## AWS Services Used

- Amazon S3 – Static website storage
- Amazon CloudFront – Content Delivery Network (CDN)
- AWS Certificate Manager (ACM) – HTTPS/SSL certificate
- AWS IAM – Bucket policy and access control
- Terraform – Infrastructure provisioning


##  Data Protection & Encryption

- S3 bucket versioning is enabled to protect against accidental deletion or overwrite
- Objects are encrypted at rest using AWS KMS
- Custom KMS key is created and managed using Terraform

##  Custom Domain & DNS Configuration

- Route 53 hosted zone is created for the domain `nikhil.com`
- ACM certificate is requested in `us-east-1` for CloudFront compatibility
- DNS validation records are automatically created using Terraform
- CloudFront distribution is configured with a custom domain alias



##  Security & Compliance Features

- S3 bucket is fully private with all public access blocked
- CloudFront Origin Access Control (OAC) is used instead of legacy OAI
- Bucket policy allows access only from the specific CloudFront distribution
- Server-side encryption enabled using AWS KMS (SSE-KMS)
- HTTPS enforced using CloudFront viewer protocol policy
- ACM certificate validated using DNS

##  Future Improvements

- Configure remote backend using S3 and DynamoDB for state locking
- Enable CloudFront access logs
- Add WAF for additional security
- Introduce CI/CD pipeline for automated deployments
- Add multi-environment support (dev/stage/prod)

  ##  Outputs

- CloudFront Distribution URL
- S3 Bucket Name
- Domain Name
  
##  Deployment Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/Nikhil00-7/Terraform-projects/tree/main
   cd project-1-static-website

2. Initialize Terraform:
   terraform init

3. Priview the changes
   terraform plan

4. Apply the configuration 
   terraform apply

