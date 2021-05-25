library(aws.s3)
library(aws.iam)

get_caller_identity()

token <- get_session_token()

set_credentials(token)  

Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIAZZI24EFBH2OUQ7QE",
           "AWS_SECRET_ACCESS_KEY" = "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",
           "AWS_DEFAULT_REGION" = "us-east-1")



test_bucket <- put_bucket(bucket = "HMTM_test",
                          region = "us-east-1")


put_cors(bucket = "HMTM_test", 
'<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedMethod>DELETE</AllowedMethod>
    <AllowedMethod>HEAD</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <ExposeHeader>ETag</ExposeHeader>
    <ExposeHeader>x-amz-meta-custom-header</ExposeHeader>
    <AllowedHeader>*</AllowedHeader>

</CORSRule>
</CORSConfiguration>')

create_user("HMTM_test_user", "HMTM", ...)