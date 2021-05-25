

results <- file.info(list.files("output/results", pattern = "\\.rds$", full.names = TRUE))

latest <- rownames(results)[which.max(results$mtime)]

res <- readRDS(latest)
as.list(res)

hello <- res$results$test

hello %>%
  then(function(value) {
    cat("The operation completed!\n")
    print(value)
  })
