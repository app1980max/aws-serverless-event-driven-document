import boto3
import os
s3 = boto3.client('s3')
translate = boto3.client('translate')
def lambda_handler(event, context):
    # 1. Retrieve the file metadata from the S3 trigger
    input_bucket = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']
    
    # 2. Get the output bucket name from environment variables
    output_bucket = os.environ['OUTPUT_BUCKET']
    
    # 3. Read the content of the uploaded file
    file_obj = s3.get_object(Bucket=input_bucket, Key=file_key)
    source_text = file_obj['Body'].read().decode('utf-8')
    
    # 4. Perform translation (English to French in this example)
    response = translate.translate_text(
        Text=source_text,
        SourceLanguageCode="en",
        TargetLanguageCode="fr"
    )
    
    # 5. Save the translated text to the response bucket
    output_key = f"translated_{file_key}"
    s3.put_object(
        Bucket=output_bucket,
        Key=output_key,
        Body=response['TranslatedText']
    )
    
    print(f"Successfully translated {file_key} and saved to {output_bucket}")
