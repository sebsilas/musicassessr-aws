
wRegion <- "us-east-1"
poolid <- "us-east-1:4d21dfc9-6265-466d-b5cd-23594d5f8a75"
s3bucketName <- "hmtm"
audioPath <- "/audio-files"

produce.aws.footer.from.credentials <- function(footer_type, wRegion, poolid, s3bucketName, audioPath) {

  if (footer_type == "first") { # this footer should be used in an instantiating page e.g a microphone setup page

    shiny::tags$div(
      htmltools::includeScript("https://www.WebRTC-Experiment.com/RecordRTC.js"),
      htmltools::includeScript("https://sdk.amazonaws.com/js/aws-sdk-2.2.32.min.js"),
      includeScript("www/js/record_aws_legacy.js"),
      #includeScript("www/js/record_aws.js"),
      shiny::tags$script(HTML(paste0('
  var wRegion = \"', wRegion, '\";
  var poolid = \"', poolid, '\";
  var s3bucketName = \"', s3bucketName, '\";
  var audioPath = \"', audioPath, '\";
  function audio(wRegion,poolid,path) {
    AStream = new AudioStream(wRegion,poolid,path);
    return AStream;
  }
  var NewAudio = audio(wRegion,poolid,s3bucketName+audioPath);
  NewAudio.audioStreamInitialize();
  '))))

  }

  else { # and this one should be used on every other page that records and sends audio to aws afterwards


    shiny::tags$div(
      htmltools::includeScript("https://www.WebRTC-Experiment.com/RecordRTC.js"),
      htmltools::includeScript("https://sdk.amazonaws.com/js/aws-sdk-2.2.32.min.js"),
      shiny::tags$script(HTML(paste0('
  var wRegion = \"', wRegion, '\";
  var poolid = \"', poolid, '\";
  var s3bucketName = \"', s3bucketName, '\";
  var audioPath = \"', audioPath, '\";
  function AudioBuild(wRegion,poolid,path) {
    console.log("AudioBuild called");
    console.log(typeof AudioStream);
    AudioS = new AudioStream(wRegion,poolid,path);
    return AudioS;
  }
  var NewAudio = AudioBuild(wRegion,poolid,s3bucketName+audioPath);
  NewAudio.audioStreamInitialize();
  '))))

  }

}


produce.aws.footer.from.credentials2 <- function(wRegion, poolid, s3bucketName, audioPath) {
  div(
    tags$script(src="https://cdn.rawgit.com/mattdiamond/Recorderjs/08e7abd9/dist/recorder.js"),
    tags$script(src="https://sdk.amazonaws.com/js/aws-sdk-2.585.0.min.js"),
    tags$script('
    //change your info here
    var destBucket="awsmedx"
    var api_url="https://pv3r2l54zi.execute-api.us-east-1.amazonaws.com/prod/api"
    var bucketName = "drm-med-delivery-2020";
    var bucketRegion = "us-east-1";
    var IdentityPoolId = "us-east-1:b1f72461-d02c-495a-a7bf-43196809096f";'),
    includeScript("static-website-s3/app.js")
  )
}

# produce.aws.footer.from.credentials(footer_type = "first",
#                                     wRegion = "us-east-1",
#                                     poolid = "us-east-1:c74a7565-ecd3-4abb-9dba-3d02b483e795",
#                                     s3bucketName = "melody-singing-task",
#                                     audioPath = "/audio-files")
#

# produce.aws.footer.from.credentials(footer_type = "every_other",
#                                     wRegion = "us-east-1",
#                                     poolid = "us-east-1:c74a7565-ecd3-4abb-9dba-3d02b483e795",
#                                     s3bucketName = "melody-singing-task",
#                                     audioPath = "/audio-files")



# produce.aws.footer.from.credentials(footer_type = "first",
#                                     wRegion = wRegion,
#                                     poolid = poolid,
#                                     s3bucketName = s3bucketName)
#
#
# produce.aws.footer.from.credentials(footer_type = "every_other",
#                                     wRegion = wRegion,
#                                     poolid = poolid,
#                                     s3bucketName = s3bucketName)


