api=$(terraform output | grep "api_base_url =" | cut -d = -f 2 | xargs) 


identitypool=$(terraform  output | grep "aws_cognito_identity_pool =" | cut -d = -f 2 | xargs)


bucketName=$(terraform  output  | grep "s3_source_bucket =" | cut -d = -f 2 | xargs)

destBucket=$(terraform  output  | grep "s3_source_destination =" | cut -d = -f 2 | xargs)
api_gateway=$(echo "${api}" | sed -e 's/[]$.*[\^]/\\&/g' )
cd s3-demo
sed  -i -e "s|apigateway|${api_gateway}|g" \
 -e "s|identitypool|${identitypool}|g" \
-e "s|bucketsource|${bucketName}|g" \
-e "s|bucket-dest|${destBucket}|g"  index.html


aws s3 sync . s3://$(echo $bucketName)