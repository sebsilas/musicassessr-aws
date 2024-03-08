import json
import os
import subprocess
import boto3
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')

def handler(event, context):
    S3_DESTINATION_BUCKET = os.environ['S3_DESTINATION_BUCKET']
    s3_source_bucket = event['Records'][0]['s3']['bucket']['name']
    unquoted_s3_source_key = unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    parsed_s3_source_key = unquoted_s3_source_key.replace(' ', '')
    s3_source_basename = os.path.splitext(os.path.basename(unquoted_s3_source_key))[0]
    s3_destination_filename = s3_source_basename + ".csv"

    s3_response_object = s3_client.get_object(Bucket=s3_source_bucket, Key=unquoted_s3_source_key)
    s3_source_metadata = s3_response_object['Metadata']
  
    s3_client.download_file(s3_source_bucket, unquoted_s3_source_key, f'/tmp/{parsed_s3_source_key}')
    command_file_parsed = parsed_s3_source_key.replace('(', '"("').replace(')', '")"')

    if s3_source_metadata.get("onset","").lower() == "true":
        print("Metadata contains 'onset' key with value 'true'")
        sonic_annotator_cmd = f'./sonic-annotator -d vamp:qm-vamp-plugins:qm-onsetdetector:onsets -w csv --csv-stdout /tmp/{command_file_parsed}'
    else:
        sonic_annotator_cmd = f'./sonic-annotator -d vamp:pyin:pyin:notes -w csv --csv-stdout /tmp/{command_file_parsed}'
    p1 = subprocess.check_output(sonic_annotator_cmd, shell=True)

    sonic_stdout = p1.replace(b'\n,', b'\n')
    sonic_output = sonic_stdout.decode('utf-8').replace(f'"/tmp/{unquoted_s3_source_key}",', '')
    resp = s3_client.put_object(Body=sonic_output, Bucket=S3_DESTINATION_BUCKET, Key=s3_destination_filename, ACL='public-read', Metadata=s3_source_metadata)

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({"result": 'Processing complete successfully', "Bucket": S3_DESTINATION_BUCKET, "key": s3_destination_filename})
    }