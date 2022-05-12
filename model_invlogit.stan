data {
  int<lower=1> trials;
  int<lower=1> save_every;
  array[trials] int<lower=0, upper=1> condition; 
  array[trials] int<lower=1, upper=2> choice;
  array[trials] int<lower=0, upper=1> feedback;
  array[2] real alpha1_prior_vals;
  array[2] real alpha2_prior_vals;
  array[2] real tau_prior_vals;
}

transformed data {
  vector[2] initValue; // initial values for V

  initValue = rep_vector(0.5, 2);
}

parameters { //Things we estimate
  real alpha1; // learning rate
  real alpha2; // learning rate
  real tau; // softmax inv. temp
}

model {
  real pe; //prediction error
  vector[2] value; 
  vector[2] theta; 
  
  //target += uniform_lpdf(alpha1 | 0,1); // TERRIBLE PRIORS
  //target += uniform_lpdf(alpha2 | 0,1);
  //target += uniform_lpdf(tau | 0,20);
  target += normal_lpdf(alpha1 | alpha1_prior_vals[1], alpha1_prior_vals[2]); 
  target += normal_lpdf(alpha2 | alpha2_prior_vals[1], alpha2_prior_vals[2]);
  target += normal_lpdf(tau | tau_prior_vals[1], tau_prior_vals[2]);
  
  value = initValue;
  
  for (t in 1:trials){
    theta = softmax(inv_logit(tau)*20 * value); //action probability computed via softmax
    target += categorical_lpmf(choice[t] | theta);
    
    pe = feedback[t] - value[choice[t]]; //compute pe for chosen value only
    
    if (condition[t] == 0)
      value[choice[t]] = value[choice[t]] + inv_logit(alpha1) * pe; // update chosen V
    if (condition[t] == 1)
      value[choice[t]] = value[choice[t]] + inv_logit(alpha2) * pe; // update chosen V
    
  }
}
  
generated quantities {
  real alpha1_prior; //<lower=0, upper=1>
  real alpha2_prior; //<lower=0, upper=1>
  real tau_prior; //<lower=0, upper=20>
  real<lower=0, upper=1> alpha1_trans;
  real<lower=0, upper=1> alpha2_trans;
  real<lower=0> tau_trans;

  vector[2] theta; 
  real pe;
  real log_lik;
  int<lower=1> adjusted_idx = 1;
  
  // expected value is only gonna be saved every save_entry-th time 
  // array is thus shorter than trials
  // %/% is integer division
  array[trials %/% save_every] real expected_val1;
  array[trials %/% save_every] real expected_val2;

  vector[2] value; 
  vector[2] initValueGen;
  initValueGen = rep_vector(0.5, 2);
  
  //alpha1_prior = uniform_rng(0,1);
  //alpha2_prior = uniform_rng(0,1);
  //tau_prior = uniform_rng(0,20);  
  alpha1_prior = inv_logit(normal_rng(alpha1_prior_vals[1],alpha1_prior_vals[2]));
  alpha2_prior = inv_logit(normal_rng(alpha2_prior_vals[1],alpha2_prior_vals[2]));
  tau_prior = inv_logit(normal_rng(tau_prior_vals[1],tau_prior_vals[2]))*20;
  
  alpha1_trans = inv_logit(alpha1);
  alpha2_trans = inv_logit(alpha2);
  tau_trans = inv_logit(tau)*20;

  value = initValueGen;
  log_lik = 0;
  
  for (t in 1:trials){
      
    theta = softmax(inv_logit(tau) * value); //action probability computed via softmax
      
    log_lik = log_lik + categorical_lpmf(choice[t] | theta);
        
    pe = feedback[t] - value[choice[t]]; //compute pe for chosen value only
        
    if (condition[t] == 0)
      value[choice[t]] = value[choice[t]] + inv_logit(alpha1) * pe; // update chosen V
    if (condition[t] == 1)
      value[choice[t]] = value[choice[t]] + inv_logit(alpha2) * pe; // update chosen V

    // save only every n-th trial
    if (t % save_every == 0){
      adjusted_idx = t %/% save_every;
      expected_val1[adjusted_idx] = value[1]; //Saving this for plotting afterwards
      expected_val2[adjusted_idx] = value[2]; //Saving this for plotting afterwards
    }
      
      // alpha[t] = alpha1 * (1-condition[t]) + alpha2 * (condition[t]);
      // expected_alpha1[t] = alpha[1];
      // expected_alpha2[t] = alpha[2];
      
  }
}
