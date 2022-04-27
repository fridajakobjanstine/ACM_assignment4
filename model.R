d <- df 

data <- list(
  trials = trials,
  choice = d$choice + 1,
  feedback = d$feedback,
  #condition =
)

file <- file.path("ACM_assignment4/model.stan")
mod <- cmdstan_model(file, cpp_options = list(stan_threads = TRUE), pedantic = TRUE)

samples <- mod$sample(
  data = data,
  seed = 123,
  chains = 2,
  parallel_chains = 2,
  threads_per_chain = 2,
  iter_warmup = 2000,
  iter_sampling = 2000,
  refresh = 1000,
  max_treedepth = 20,
  adapt_delta = 0.99
)