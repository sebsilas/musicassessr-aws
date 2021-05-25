
# set AWS credentials

Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIAZZI24EFBH2OUQ7QE",
           "AWS_SECRET_ACCESS_KEY" = "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",
           "AWS_DEFAULT_REGION" = "us-east-1")


save.aws.credentials <- function(wRegion, poolid, s3bucketName, audioPath) {

  df <- data.frame(wRegion = wRegion,
                   poolid = poolid,
                   s3bucketName = s3bucketName,
                   audioPath = audioPath)

  readr::write_csv(df, 'dat/aws_credentials.csv')

}


aws_admin_panel <- function(input, output, session, ...) {

  get.aws.credentials()

  output$custom_admin_panel <- shiny::renderUI({
    tagList(
      shinyBS::bsModal('AWSinstructions_modal',
                       title = 'AWS Setup instructions',
                       trigger = 'AWSinstructions',
                       htmlOutput("aws.instructions")),
      actionButton('AWSinstructions', 'AWS Setup Instructions') ,
      textInput("wRegion","wRegion", value = wRegion),
      textInput("poolid", "poolid", value = poolid),
      textInput("s3bucketName", "s3bucketName", value = s3bucketName),
      textInput("audioPath", "audioPath", value = audioPath),
      actionButton('saveAWS', 'Save')
    )})

  output$aws.instructions <- renderUI({
    shiny::tags$iframe(src="docs/Setting up Amazon S3 Server.pdf", width="400", height="600")
  })

  list (

    observeEvent(input$AWSinstructions, {
      shinyBS::toggleModal(session, "AWSinstructions", toggle = "open")
    }),

    observeEvent(input$saveAWS, {
      print("New AWS credentials saved.")
      save.aws.credentials(input$wRegion, input$poolid, input$s3bucketName, input$audioPath)
    })
  )

}


get.aws.credentials <- function() {
  if(file.exists('dat/aws_credentials.csv')) {
    df <- readr::read_csv('dat/aws_credentials.csv')
    wRegion <<- df$wRegion
    poolid <<- df$poolid
    s3bucketName <<- df$s3bucketName
    audioPath <<- HTML(df$audioPath)
  }
  else {
    print('No AWS Credentials Saved')
    wRegion <<- "No AWS Credentials Saved"
    poolid <<- "No AWS Credentials Saved"
    s3bucketName <<- "No AWS Credentials Saved"
    audioPath <<- "No AWS Credentials Saved"
  }
}
