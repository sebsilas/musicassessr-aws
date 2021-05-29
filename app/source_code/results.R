

results <- file.info(list.files("output/results", pattern = "\\.rds$", full.names = TRUE))

latest <- rownames(results)[which.max(results$mtime)]


res <- readRDS(latest)

res2 <- as.list(res)$results

res3 <- res2[which(base::grepl("melody", names(res2)))]


end_result <- list()

res4 <- lapply(res3, function(x) {
          promise <- x[1]$promise_result
          print(promise)
          if(is.promise(promise)) {
            promise_res <- promise %>%
              then(function(value) {
                print(value)
                end_result <<- append(end_result, list(value), after = length(end_result))
              })
          }
          else {
            promise_res <- NA
          }
          promise_res
})


