library(pacman)
p_load(tidyverse, patchwork, wesanderson, rcartocolor, cmdstanr, brms, posterior)

set_cmdstan_path('/work/cmdstan-2.29.2')
d <- read.csv('dat/simulation_data.csv')

# Adding condition column
for (i in 1:nrow(d)){
  ifelse(d$true_alph[i] == 0.6, d$condition[i] <- 0, d$condition[i] <- 1)
}

file <- file.path("model.stan")
mod <- cmdstan_model(file, cpp_options = list(stan_threads = TRUE), pedantic = TRUE)

recovery_df = NULL
# save only every 100th trail on drawing form samples
save_every = 100

stopping_n_trials = c(100, 200, 500, 1000, 2000, 5000, 10000, 20000)
for (i in stopping_n_trials){
  
  print(paste0('starting n_trials ', i))
  
  # data needs to be sliced, to have both conditions in.
  # fist 10k rows are condition 1 & last 10k are condition 2
  idx_end_c1 = i / 2
  idx_end_c2 = 10000 + idx_end_c1
  
  data <- list(
    trials = i,
    # only draws samples at every n-th trial to save sapce
    save_every = save_every,
    # adjusted_trials = i/save_every,
    condition = c(d$condition[1:idx_end_c1], d$condition[10001:idx_end_c2]),
    choice = c(d$choice[1:idx_end_c1] + 1, d$choice[10001:idx_end_c2] + 1),
    feedback = c(d$feedback[1:idx_end_c1], d$feedback[10001:idx_end_c2])
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
  
  downsampled_draws_df <- as_draws_df(samples$draws())
  
  temp = tibble(n_trials = i, 
                alpha1_est = downsampled_draws_df$alpha1,
                alpha2_est = downsampled_draws_df$alpha2
                )

  if (exists("recovery_df")) {recovery_df = rbind(recovery_df, temp)} else {recover_df = temp}
  
}

model_sum <- samples$summary()

# Return model defined priors and posteriors

# Save draws_df
write.csv(recovery_df, 'dat/recovery_df.csv')
write.csv(downsampled_draws_df, 'dat/downsampled_draws_df.csv')



