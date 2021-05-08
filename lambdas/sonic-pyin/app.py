import json
import os
import subprocess
import boto3
from urllib.parse import unquote_plus
#update the s3 destintation bucket to yours
S3_DESTINATION_BUCKET = "hmtm-2nd-out"
s3_client = boto3.client('s3')

def handler(event, context):
    parsing_events=json.loads(event['body'])
    s3_source_bucket = parsing_events['bucketName']
    s3_source_key = parsing_events['key']
    print(s3_source_key)
    unquoted_s3_source_key = unquote_plus(s3_source_key)
    parsed_s3_source_key = unquoted_s3_source_key.replace(' ', '')
    s3_source_basename = os.path.splitext(os.path.basename(unquoted_s3_source_key))[0]
    s3_destination_filename = s3_source_basename + ".csv"
    s3_client.download_file(s3_source_bucket, unquoted_s3_source_key, f'/tmp/{parsed_s3_source_key}')

    command_file_parsed = parsed_s3_source_key.replace('(', '"("').replace(')', '")"')
    sonic_annotator_cmd = f'./sonic-annotator -d vamp:pyin:pyin:notes -w csv --csv-stdout /tmp/{command_file_parsed}'
    p1 = subprocess.check_output(sonic_annotator_cmd, shell=True)

    sonic_stdout = p1.replace(b'\n,', b'\n')
    sonic_output = sonic_stdout.decode('utf-8').replace(f'"/tmp/{unquoted_s3_source_key}",', '')
    resp = s3_client.put_object(Body=sonic_output, Bucket=S3_DESTINATION_BUCKET, Key=s3_destination_filename,ACL='public-read')

    return {
        'statusCode': 200,'headers': {
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({"result":'Processing complete successfully',"Bucket":S3_DESTINATION_BUCKET,"key":s3_destination_filename})
    }
