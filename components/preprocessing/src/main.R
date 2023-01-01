run <- function(min_ngrams, max_ngrams, max_tokens, output, seed){
  suppressPackageStartupMessages({
    library("textrecipes")
    library("rsample")
    library("glue")
  })
  set.seed(seed)
  dataset01 <- read.csv("data/amazon_cells_labelled.txt", sep="\t",
                        quote = "",
                        stringsAsFactors = FALSE)
  dataset02 <- read.csv("data/yelp_labelled.txt", sep="\t",
                        quote = "",
                        stringsAsFactors = FALSE)
  dataset03 <- read.csv("data/imdb_labelled.txt", sep="\t",
                        quote = "",
                        stringsAsFactors = FALSE)
  
  dataset <- rbind(dataset01, dataset02, dataset03)
  
  data_split <- group_initial_split (dataset,
                                     dataset$label,
                                      prop = 3/4)
  data <- list(train = training(data_split), 
               validation = testing(data_split))
  
  cat("Training-validation split:\n")
  print(data_split)
  
  cat("Positive and negative labels in training:\n")
  training(data_split) %>% 
    count(label) %>% 
    print()
  
  cat("Positive and negative labels in validation:\n")
  testing(data_split) %>% 
    count(label) %>% 
    print()
  
  cat("\nRecipe:\n")
  rec <- recipe(label ~ text, data = data$train) %>%
    step_tokenize(text, token = "ngrams",
                  options = list(n = max_ngrams, n_min = min_ngrams, 
                                 ngram_delim = "_")) %>%
    step_tokenfilter(text, max_tokens = max_tokens) %>%
    step_tfidf(text) %>% 
    recipes::prep(verbose = TRUE, log_changes = TRUE) 
  
  print(rec)
  
  out <- list(
    train = bake(rec, new_data = NULL),
    validation = bake(rec, data$validation)
  )

  cat("\nWriting RData object to a file...\n")
  try(dir.create(
    dirname(output), 
    showWarnings = FALSE, 
    recursive = TRUE, 
    mode = "0600"
   ))
  saveRDS(out, output)
  cat("Done!\n")
}


option_list <- list(
  optparse::make_option(c("--min_ngrams"), type="numeric", default = NA,
              help="minimum number of ngrams"),
  optparse::make_option(c("--max_ngrams"), type="numeric", default = NA,
              help="maximum number of ngrams"),
  optparse::make_option(c("--max_tokens"), type="numeric", default = NA, 
              help="maximum number of tokens to use (before creating ngrams)"),
  optparse::make_option(c("--output"), type="character", default = NA,
                        help="output folder (where to store dataset)"),
  optparse::make_option(c("--seed"), type="numeric", default = 123,
                        help="seed for randomness")
)
opt_parser <- optparse::OptionParser(option_list=option_list)
pargs <- optparse::parse_args(opt_parser)
pargs$help <- NULL

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
