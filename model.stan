
data {
  int<lower=1> trials;
  int<lower=1> save_every;
  array[trials] int<lower=0, upper=1> condition; 
  array[trials] int<lower=1, upper=2> choice;
  array[trials] int<lower=0, upper=1> feedback;
}

transformed data {
  vector[2] initValue; // initial values for V

  initValue = rep_vector(0.5, 2);
}

parameters { //Things we estimate
  real<lower=0, upper=1> alpha1; // learning rate
  real<lower=0, upper=1> alpha2; // learning rate
  real<lower=0, upper=20> tau; // softmax inv. temp
}

model {
  real pe; //prediction error
  vector[2] value; 
  vector[2] theta; 
  
  target += uniform_lpdf(alpha1 | 0,1); // TERRIBLE PRIORS
  target += uniform_lpdf(alpha2 | 0,1);
  target += uniform_lpdf(tau | 0,20);
  
  value = initValue;
  
  for (t in 1:trials){
    theta = softmax(tau * value); //action probability computed via softmax
    target += categorical_lpmf(choice[t] | theta);
    
    pe = feedback[t] - value[choice[t]]; //compute pe for chosen value only
    
    if (condition[t] == 0)
      value[choice[t]] = value[choice[t]] + alpha1 * pe; // update chosen V
    if (condition[t] == 1)
      value[choice[t]] = value[choice[t]] + alpha2 * pe; // update chosen V
    
  }
}
  
generated quantities {
  real<lower=0, upper=1> alpha1_prior;
  real<lower=0, upper=1> alpha2_prior;
  real<lower=0, upper=20> tau_prior;
  
  // saving every n-th trial, so array is shorter than trials
  array[trials/save_every] real expected_val1;
  array[trials/save_every] real expected_val2;
  // array[trials/save_every] real expected_alpha1;
  // array[trials/save_every] real expected_alpha2;
  vector[2] theta; 
  real pe;
  
  real log_lik;
  
  // vector[2] alpha;
  vector[2] value; 
  vector[2] initValueGen;
  initValueGen = rep_vector(0.5, 2);
  
  alpha1_prior = uniform_rng(0,1);
  alpha2_prior = uniform_rng(0,1);
  tau_prior = uniform_rng(0,20);
  
  value = initValueGen;
  log_lik = 0;
  
  for (t in 1:trials){
    
    // save every n-th trial
    if (t / save_every == 0){
      
      theta = softmax(tau * value); //action probability computed via softmax
    
      log_lik = log_lik + categorical_lpmf(choice[t] | theta);
      
      pe = feedback[t] - value[choice[t]]; //compute pe for chosen value only
      
      if (condition[t] == 0)
        value[choice[t]] = value[choice[t]] + alpha1 * pe; // update chosen V
      if (condition[t] == 1)
        value[choice[t]] = value[choice[t]] + alpha2 * pe; // update chosen V

      expected_val1[t] = value[1]; //Saving this for plotting afterwards
      expected_val2[t] = value[2]; //Saving this for plotting afterwards
      
      // alpha[t] = alpha1 * (1-condition[t]) + alpha2 * (condition[t]);
      // expected_alpha1[t] = alpha[1];
      // expected_alpha2[t] = alpha[2];
      
    }

  }

}
  
