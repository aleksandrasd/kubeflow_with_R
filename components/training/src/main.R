run <- function(input, 
                lambda, 
                alpha, 
                threshold, 
                output= NULL, 
                metric_pipeline = NULL,
                metric_katib = NULL){
  suppressPackageStartupMessages({
    library("MLmetrics")
    library("caret")
    library("glmnet")
    library("jsonlite")
    library("glue")
  })
  dataset <- readRDS(input)
  X = model.matrix(label ~ . , dataset$train)[, -1]
  y = dataset$train$label
  
  fit = glmnet(X, y, family = "binomial", 
               alpha = alpha, 
               lambda = lambda)
  
  X_val = model.matrix(label ~ . , dataset$validation)[, -1]
  y_true <- dataset$validation$label
  y_pred <- predict(fit, X_val, type = "link")
  y_pred <- as.integer(y_pred > threshold)
  
  recall_value <- Recall(y_true, y_pred)
  precision_value <- Precision(y_true, y_pred)
  f1_score_value <- F1_Score(y_true, y_pred)
  
  if (!is.null(metric_pipeline)){
    metrics_out <- list(
      metrics = list(
        list(
          name = "Recall",
          numberValue  = recall_value,
          format = "PERCENTAGE"
        ),
        list(
          name = "Precision",
          numberValue  = precision_value,
          format = "PERCENTAGE"
        ),
        list(
          name = "F1 score",
          numberValue  = f1_score_value,
          format = "PERCENTAGE"
        )
      )
    )
    cat("Storing accuracy metrics to a file:", metric_pipeline,"\n")
    try(dir.create(
      dirname(metric_pipeline), 
      showWarnings = FALSE, 
      recursive = TRUE, 
      mode = "0600"
    ))
    write_json(metrics_out, metric_pipeline, auto_unbox  = TRUE)
    cat("Done!\n")
  }
  
  if (!is.null(metric_katib)){
    out <- paste0("{metricName: recall, metricValue: ", recall_value, "}\n",
                  "{metricName: precision, metricValue: ", precision_value, "}\n",
                  "{metricName: F-score, metricValue: ", f1_score_value, "}")
    cat("Storing accuracy metrics to a file (katib):", metric_katib, "\n")
    try(dir.create(
      dirname(metric_katib), 
      showWarnings = FALSE, 
      recursive = TRUE, 
      mode = "0600"
    ))
    writeLines(out, metric_katib, useBytes = TRUE)
    cat("Done!\n")
  }
  
  if (!is.null(output)){
    cat("Writing model to a file:", output, "\n")
    try(dir.create(
      dirname(output), 
      showWarnings = FALSE, 
      recursive = TRUE, 
      mode = "0600"
    ))
    saveRDS(fit, output)
    cat("Done!\n")
  }
}

option_list <- list(
  optparse::make_option(c("--input"), type="character", default = NA, 
                        help="path to dataset folder"),
  optparse::make_option(c("--lambda"), type="numeric", default = NA, 
                        help="lambda (elastic net's hyperparameter)"),
  optparse::make_option(c("--alpha"), type="numeric", default = NA, 
                        help="alpha (elastic net's hyperparameter)"),
  optparse::make_option(c("--threshold"), type="numeric", default = NA, 
                        help="classification threshold"),
  optparse::make_option(c("--output"), type="character", default = NULL,
                        help="model output path"),
  optparse::make_option(c("--metric_pipeline"), type="character",default = NULL, 
                        help="output path to metric file"),
  optparse::make_option(c("--metric_katib"), type="character",
                        default = "/var/log/katib/metrics.log", 
                        help="output path to metric file")
)
opt_parser <- optparse::OptionParser(option_list=option_list)
pargs <- optparse::parse_args(opt_parser)
pargs$help <- NULL

filled_args <- mapply(
  pargs,
  names(pargs), 
  USE.NAMES = FALSE, 
  FUN = function(value, arg_name){
    var_mis <- is.na(value)
    if (var_mis){
      cat("Missing required variable: '", arg_name, "'\n", sep = "")
    }
    var_mis
  })

if (any(filled_args)){
  optparse::parse_args(opt_parser, c("-h"))
}

missing_args <- mapply(
  names(pargs),
  pargs,
  USE.NAMES = FALSE, 
  FUN = function(param_name, param_value){
    arg_missing <- is.na(param_value)
    if (arg_missing){
      cat("Missing required argument: '", param_name, "'\n", sep = "")
    }
    arg_missing
  })

if (any(missing_args)){
  optparse::parse_args(opt_parser, c("-h"))
}

cat("Script parameters:\n")
for (arg_name in names(pargs)){
  cat(arg_name, "=", pargs[[arg_name]], "\n", sep = "")
}
cat("\n\n")

do.call(run, pargs)
