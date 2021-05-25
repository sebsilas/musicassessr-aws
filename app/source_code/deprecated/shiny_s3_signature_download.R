# https://towardsdatascience.com/r-shiny-enable-efficient-file-downloads-from-amazon-s3-f575bfb21244

get_aws_signed_url <- function(file, bucket = "hmtm-out-v2", timeout_seconds = 60, key = "my_jey", secret = "my_secret", region = "us-east-1"){
  # API Implmented according to https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html#query-string-auth-v4-signing-example
  
  print('get_aws_signed_url')
  print(bucket)
  print(key)
  print(secret)
  
  algorithm <- "AWS4-HMAC-SHA256"
  time <- Sys.time()
  date_time <- format(time, "%Y%m%dT%H%M%SZ", tz = "UTC")
  
  # Build query parameters
  date <- glue("/{format(time,'%Y%m%d', tz = 'UTC')}/")
  region_encoded <- glue("{region}/")
  amzn <- "s3/aws4_request"
  
  # Query parameters, this portion is implemented with the help of https://github.com/cloudyr/aws.s3/blob/master/R/s3HTTP.R
  request_body <- ""
  body_hash <- tolower(digest::digest(request_body,
                                      file = is.character(request_body) && file.exists(request_body),
                                      algo = "sha256", serialize = FALSE))
  
  
  signature <- aws.signature::signature_v4_auth(datetime = date_time,
                                                region = region,
                                                service = "s3",
                                                verb = "GET",
                                                action = glue("/{bucket}/{file}"),
                                                key = key,
                                                secret = secret,
                                                request_body = "",
                                                query_args = list(`X-Amz-Algorithm` = algorithm,
                                                                  `X-Amz-Credential` = glue("{key}{date}{region_encoded}{amzn}"),
                                                                  `X-Amz-Date` = date_time,
                                                                  `X-Amz-Expires` = timeout_seconds,
                                                                  `X-Amz-SignedHeaders` = "host",
                                                                  `x-amz-content-sha256` = body_hash),
                                                algorithm = algorithm,
                                                canonical_headers = list(host = glue("s3-{region}.amazonaws.com")))
  
  # try remove region
  # try remove x-amz-content
  # try removing both
  
  # https://s3-us-east-1.amazonaws.com/hmtm-out-v2/1618902310095.wav
  # ?X-Amz-Algorithm=AWS4-HMAC-SHA256
  # &X-Amz-Credential=AKIAZZI24EFBH2OUQ7QE/20210427/us-east-1/s3/aws4_request
  # &X-Amz-Date=20210427T091341Z
  # &X-Amz-Expires=100
  # &x-amz-content-sha256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  # &X-Amz-SignedHeaders=host
  # &X-Amz-Signature=d636ef097ad5ed3bec1f6e8c17df2fb1fbc59fbdf97765f1a64da9bda4210599
  # 
  # https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
  #
  # example from documentation:
  # https://s3.amazonaws.com/examplebucket/test.txt
  # ?X-Amz-Algorithm=AWS4-HMAC-SHA256
  # &X-Amz-Credential=<your-access-key-id>/20130721/us-east-1/s3/aws4_request
  # &X-Amz-Date=20130721T201207Z
  # &X-Amz-Expires=86400
  # &X-Amz-SignedHeaders=host
  # &X-Amz-Signature=<signature-value>  
  #   
  #   https://s3.amazonaws.com/hmtm-out-v2/1618902310095.wav
  # ?X-Amz-Algorithm=AWS4-HMAC-SHA256
  # &X-Amz-Credential=AKIAZZI24EFBH2OUQ7QE/20210427/us-east-1/s3/aws4_request
  # &X-Amz-Date=20210427T092123Z
  # &X-Amz-Expires=100
  # &X-Amz-SignedHeaders=host
  # &X-Amz-Signature=595de108c4af6a9ddca8c04f3ba9a1ee489be4fa5ecbdfd9f63e61d3b018a34b
  # 
  print(glue("https://s3.amazonaws.com/{bucket}/{file}?X-Amz-Algorithm={signature$Query$`X-Amz-Algorithm`}&X-Amz-Credential={signature$Query$`X-Amz-Credential`}&X-Amz-Date={signature$Query$`X-Amz-Date`}&X-Amz-Expires={signature$Query$`X-Amz-Expires`}&X-Amz-SignedHeaders={signature$Query$`X-Amz-SignedHeaders`}&X-Amz-Signature={signature$Signature}"))
  return(glue("https://s3.amazonaws.com/{bucket}/{file}?X-Amz-Algorithm={signature$Query$`X-Amz-Algorithm`}&X-Amz-Credential={signature$Query$`X-Amz-Credential`}&X-Amz-Date={signature$Query$`X-Amz-Date`}&X-Amz-Expires={signature$Query$`X-Amz-Expires`}&X-Amz-SignedHeaders={signature$Query$`X-Amz-SignedHeaders`}&X-Amz-Signature={signature$Signature}"))
}