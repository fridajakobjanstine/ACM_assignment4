library(pacman)
p_load(tidyverse, patchwork, wesanderson, rcartocolor, cmdstanr, brms, posterior)

d <- read.csv('simulation_data.csv')

# Adding condition column
for (i in 1:nrow(d)){
  ifelse(d$true_alph[i] == 0.6, d$condition[i] <- 0, d$condition[i] <- 1)
}

trials = 20000

data <- list(
  trials = trials,
  condition = d$condition,
  choice = d$choice+1,
  feedback = d$feedback
)

file <- file.path("model.stan")
mod <- cmdstan_model(file, cpp_options = list(stan_threads = TRUE), pedantic = TRUE)

samples <- mod$sample(
  data = data,
  seed = 123,
  chains = 2,
  parallel_chains = 2,
  threads_per_chain = 2,
  iter_warmup = 1000,
  iter_sampling = 1000,
  refresh = 1000,
  max_treedepth = 20,
  adapt_delta = 0.99
)

model_sum <- samples$summary()

# Return model defined priors and posteriors
draws_df <- as_draws_df(samples$draws())

# Save draws_df
write.csv(draws_df, 'draws_df.csv')
