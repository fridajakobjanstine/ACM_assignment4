
data {
  int<lower=1> trials;
  array[trials] int<lower=0, upper=1> condition; 
  array[trials] int<lower=0, upper=1> choice;
  array[trials] int<lower=0, upper=1> feedback;
}

parameters { //Things we estimate
  int<lower=0, upper=1> alpha1; // learning rate
  int<lower=0, upper=1> alpha2; // learning rate
  real<lower=0, upper=20> tau; // softmax inv. temp
  }

model {
  real pe; //prediction error
  vector[2] value; 
  vector[2] theta; 
  
  target += uniform_lpdf(alpha1 | 0,1); // TERRIBLE PRIORS
  target += uniform_lpdf(alpha2 | 0,1);
  target += uniform_lpdf(tau | 0,20);
  
  value = initValue; // ??????
  
  for (t in 1:trials){
    theta = softmax(tau * value); //action probability computed via softmax
    target += categorical_lpmf(choice[t] | theta);
    
    pe = feedback[t] - value[choice[t]]; //compute pe for chosen value only
    
    if (condition == 0)
      value[choice[t]] = value[choice[t]] + alpha1 * pe; // update chosen V
    if (condition == 1)
      value[choice[t]] = value[choice[t]] + alpha2 * pe; // update chosen V
    
  }
}
  
generated quantities {
  real<lower=0, upper=1> alpha1_prior;
  real<lower=0, upper=1> alpha2_prior;
  real<lower=0, upper=20> tau_prior;
  
  real pe;
  vector[trials] int expected_vals;
  vector[trials] real alpha;
  
  real log_lik;
  
  alpha1_prior = uniform_rng(0,1);
  alpha2_prior = uniform_rng(0,1);
  tau_prior = uniform_rng(0,20);
  
  value = initValue;
  log_lik = 0;
  
  for (t in 1:trials){
    theta = softmax(tau * value); //action probability computed via softmax
    target += categorical_lpmf(1 | theta);
    
    pe = feedback[t] - value; //compute pe for chosen value only
    
    if (condition == 0)
      value[choice[t]] = value[choice[t]] + alpha1 * pe; // update chosen V
    if (condition == 1)
      value[choice[t]] = value[choice[t]] + alpha2 * pe; // update chosen V
    expected_vals[t] = value //Saving this for plotting afterwards
    
    alpha[t] = alpha1 * (1-condition) + alpha2 * (condition)
    
  }

}
  
