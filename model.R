library(pacman)
p_load(tidyverse, patchwork, wesanderson, rcartocolor, cmdstanr, brms, posterior, boot)

# set_cmdstan_path('/work/cmdstan-2.29.2')
d <- read.csv('dat/simulation_data.csv')

# Adding condition column
for (i in 1:nrow(d)){
  ifelse(d$true_alph[i] == 0.6, d$condition[i] <- 0, d$condition[i] <- 1)
}

file <- file.path("model_invlogit.stan")
mod <- cmdstan_model(file, cpp_options = list(stan_threads = TRUE), pedantic = TRUE)


### PART 1 ###


# Adding initial priors
alpha1_prior_values = c(0.5, 0.5)
alpha2_prior_values = c(0.5, 0.5)
tau_prior_values = c(0, 10)

# save only every 100th trail on drawing form samples
save_every = 100

recovery_df = NULL
stopping_n_trials = c(100, 200, 500, 1000, 2000, 5000, 10000)
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
    feedback = c(d$feedback[1:idx_end_c1], d$feedback[10001:idx_end_c2]),
    alpha1_prior_vals = alpha1_prior_values,
    alpha2_prior_vals = alpha2_prior_values,
    tau_prior_vals = tau_prior_values
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
                alpha1_est = downsampled_draws_df$alpha1_trans,
                alpha2_est = downsampled_draws_df$alpha2_trans,
                alpha1_prior = downsampled_draws_df$alpha1_prior,
                alpha2_prior = downsampled_draws_df$alpha2_prior
  )
  
  if (exists("recovery_df")) {recovery_df = rbind(recovery_df, temp)} else {recover_df = temp}
  
}


model_sum <- samples$summary()
inv.logit(as.numeric(model_sum[2,2]))
inv.logit(as.numeric(model_sum[3,2]))
inv.logit(as.numeric(model_sum[4,2]))*20

# Return model defined priors and posteriors

# Save draws_df
write.csv(recovery_df, 'dat/recovery_df.csv')
write.csv(downsampled_draws_df, 'dat/downsampled_draws_df.csv')




### PART 2 ###

# Define session
trials_per_sessions = c(100, 250, 500)
n_sessions = c(2, 2, 2)
save_every = 100

recovery_df2 = NULL

for (k in 1:range(length(trials_per_sessions))){
  n_trials = trials_per_sessions[k]
  sessions = n_sessions[k]
  
  # Adding initial priors
  alpha1_prior_vals = c(0.5, 0.5)
  alpha2_prior_vals = c(0.5, 0.5)
  tau_prior_vals = c(0, 10)
  
  for (i in 1:sessions){
    
    print(paste0('starting n_trials ', n_trials))
    
    # data needs to be sliced, to have both conditions in.
    # fist 10k rows are condition 1 & last 10k are condition 2
    idx_length = ceiling(n_trials/2) #round up to nearest integer
    
    idx_start_c1 = 1 + i*idx_length - idx_length #start of slice for cond1
    idx_start_c2 = 10000 + idx_start_c1 #start of slice for cond2
    
    idx_end_c1 = i * idx_length #end of slice for cond1
    idx_end_c2 = 10000 + idx_end_c1 #end of slice for cond2
    
    data <- list(
      trials = n_trials,
      # only draws samples at every n-th trial to save sapce
      save_every = save_every,
      # adjusted_trials = i/save_every,
      condition = c(d$condition[idx_start_c1:idx_end_c1], d$condition[idx_start_c2:idx_end_c2]),
      choice = c(d$choice[idx_start_c1:idx_end_c1] + 1, d$choice[idx_start_c2:idx_end_c2] + 1),
      feedback = c(d$feedback[idx_start_c1:idx_end_c1], d$feedback[idx_start_c2:idx_end_c2]),
      alpha1_prior_vals = alpha1_prior_vals,
      alpha2_prior_vals = alpha2_prior_vals,
      tau_prior_vals = tau_prior_vals
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
    
    downsampled_draws_df_it <- as_draws_df(samples$draws())
    
    temp = tibble(trials = n_trials,
                  n_sess = sessions,
                  sess = i,
                  tau_est = downsampled_draws_df_it$tau_trans,
                  tau_prior = downsampled_draws_df_it$tau_prior,
                  alpha1_est = downsampled_draws_df_it$alpha1_trans,
                  alpha2_est = downsampled_draws_df_it$alpha2_trans,
                  alpha1_prior = downsampled_draws_df_it$alpha1_prior,
                  alpha2_prior = downsampled_draws_df_it$alpha2_prior
    )
    
    alpha1_prior_vals = c(mean(logit(temp$alpha1_est)), sd(logit(temp$alpha1_est)))
    alpha2_prior_vals = c(mean(logit(temp$alpha2_est)), sd(logit(temp$alpha2_est)))
    tau_prior_vals = c(mean(logit(temp$tau_est/20)), sd(logit(temp$tau_est/20)))
    
    if (exists("recovery_df2")) {recovery_df2 = rbind(recovery_df2, temp)} else {recovery_df2 = temp}
  }
}

# Save draws_df
write.csv(recovery_df2, 'dat/recovery_df2.csv')
write.csv(downsampled_draws_df_it, 'dat/downsampled_draws_df_it.csv')

model_sum_it <- samples$summary()
inv.logit(as.numeric(model_sum_it[2,2]))
inv.logit(as.numeric(model_sum_it[3,2]))
inv.logit(as.numeric(model_sum_it[4,2]))*20


