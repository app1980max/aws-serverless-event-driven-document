
![1_Fy6lk_Hcf-JAjWaHzeyjfQ](https://github.com/user-attachments/assets/b0d558dc-8059-485e-8b22-74c8c87fa753)

## AWS Serverless | Event-Driven Document Translation Pipeline
In this project, we build a serverless, event-driven document translation pipeline on AWS, where translation happens automatically whenever a file is uploaded. Using AWS Lambda, S3, and Amazon Translate, we create a system that reacts instantly, eliminating manual intervention

🎯 Architecture Overview
```
✅ S3 input bucket (user uploads)
✅ Lambda Function (process + translate)
✅ S3 output bucket (results)
✅ IAM Role + Permissions
✅ CloudWatch Logs
```


🧱 Package Lambdas
```
cd functions
zip lambda_function.zip lambda_function.py
```


🚀 Deployment Options
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```

🔎 Query
```
curl -X POST https://zo1ehal9pf.execute-api.us-west-2.amazonaws.com/orders \
  -H "Content-Type: application/json" \
  -d '{
    "items": ["book"],
    "userEmail": "test@example.com"
  }'
```
