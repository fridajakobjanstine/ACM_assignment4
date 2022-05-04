library(pacman)
p_load(tidyverse, patchwork, wesanderson, rcartocolor, cmdstanr, brms, posterior)

set_cmdstan_path('/work/cmdstan-2.29.2')
d <- read.csv('dat/simulation_data.csv')

# Adding condition column
for (i in 1:nrow(d)){
  ifelse(d$true_alph[i] == 0.6, d$condition[i] <- 0, d$condition[i] <- 1)
}

# save_every = 100
# trials = 20000
# 
# data <- list(
#   trials = trials,
#   save_every = save_every,
#   condition = d$condition,
#   choice = d$choice+1,
#   feedback = d$feedback
# )

file <- file.path("model.stan")
mod <- cmdstan_model(file, cpp_options = list(stan_threads = TRUE), pedantic = TRUE)

recovery_df = NULL

stopping_n_trials = c(100, 200, 500, 1000, 2000, 5000, 10000)
for (i in stopping_n_trials){
  
  print('STARING N_TRAILS ', i)
  
  data <- list(
    trials = i,
    save_every = 1,
    condition = d$condition[1:i],
    choice = d$choice[1:i] + 1,
    feedback = d$feedback[1:i]
  )
  
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
  
  draws_df <- as_draws_df(samples$draws())
  
  temp = tibble(n_trials = i, 
                alpha1_est = draws_df$alpha1,
                alpha2_est = draws_df$alpha2
                )

  if (exists("recovery_df")) {recovery_df = rbind(recovery_df, temp)} else {recover_df = temp}
  
}

model_sum <- samples$summary()

# Return model defined priors and posteriors

# Save draws_df
write.csv(recovery_df, 'dat/recovery_df.csv')
write.csv(draws_df, 'dat/last_draws_df.csv')



