# ACM_assignment4
this is 4 riccardo

# Part 1

## Experimental setup
In this assignment, we are implementing a reinforcement learning model reflecting a simple task of choosing between two options
We simulate the experiment in which participants pick between two choices in each trial. 
These two choices have constant and proportional reward probabilities (e.g. if `p(choice_1) = 0.75`, then `p(choice_2) = 0.25`) and symmetrical negative/positive feedback. 
The agent implicitly learns these reward probabilities by attributing values to the two choices;
Value, or expectation of reward on next trial if choice c is picked, is updated each trial following:

![eq1](https://latex.codecogs.com/svg.image?V_{t&plus;1}^{c}&space;=&space;V^{c}_{t}&space;&plus;&space;\alpha&space;(R_t&space;-&space;V^{c}_{t}))
<!--$$ V_{t+1}^{c} = V^{c}_{t} + \alpha (R_t - V^{c}_{t}) $$--> 

where t is trial number, alpha is the learning rate and R is whether reward was achieved or not.
Learning rate serves to weight prediction error.
A high learning rate pushes an agent to update value in bigger increments.

An agent reaches a choice following:

![eq2](https://latex.codecogs.com/svg.image?Choice&space;\sim&space;Binomial(1,&space;~\sigma(V_{t}^{c2}&space;-&space;V_{t}^{c1},&space;\tau)))
<!--$$ Choice ~ Binomial(1, \sigma(V_{t}^{c2} - V_{t}^{c1}, \tau)) $$-->

where sigma is a softmax function, with temperature tau. 
Temperature is the "exponentiality" of the softmax function (see figure bellow).
This parameter can be thought of as agent's explore X exploit bias.
A high temperature pushes the agent to "exploit", meaning having higher probability to pick the more valued choice.

![softmax_temp](fig/softmax_vis.png)

## Simulation
We simulate data for two conditions:  
1) `alpha = 0.6`
2) `alpha = 0.8`

While having fixed reward probability: `p(choice_1) = 0.75` and `p(choice_2) = 0.25`;
And fixed temperature `tau = 0.5` (value is non-deterministic in making a choice). The agent plays for 10000 trias in each of the two conditions, giving a total of 20000 simulated trials in the dataset. 

The agents chooses an option following the decision rule described above, and updates its value of that choice based on the learning rate. Learning rates were set to 0.8 for condition 1, and 0.6 for condition 2. The agent's belief of the reward probability of option 1 under each of the two conditions can be seen below:

<img src="fig/alpha_08.png" alt="alpha08" width="600"/>
<img src="fig/alpha_06.png" alt="alpha06" width="600"/>

Clearly, the agent is updating the expected value of the option too much for both conditions, especially with a learning of 0.8. It is not a problem for the parameter recovery that the agent to such a high degree misjudges the true reward probability, but we nevertheless ran a third agent simulation (not used in parameter recovery) where the agent has a learning rate of 0.4 instead to illustrate the effect on reward probability estimation (see figure below)

<img src="fig/alpha_04.png" alt="alpha04" width="600"/>

## Parameter recovery model

For the first part of this assignment, we fit a model on the simulated data, aiming to recover the alpha- and tau values used in data generation. In order to estimate the required number of trials to correctly recover the parameters, we fit multiple models using subsets of the data of varying length (stopping after seeing the first n trials from each condition, with n = 50, 100, 250, 500, 1000, 2500, 5000, 10000). 

We use the following priors when formulating the model:  

![eq3](https://latex.codecogs.com/svg.image?Prior_{\alpha}&space;\sim&space;Normal(1,&space;1))
<!--$$ Prior_{\alpha} \sim Normal(0.5, 0.5) $$--> 
![eq4](https://latex.codecogs.com/svg.image?\alpha_1&space;\sim&space;Normal_{lpdf}(\alpha_1&space;|&space;Prior_{\alpha}))
<!--$$ \alpha_1 \sim Normal_{lpdf}(\alpha_1 | Prior_{\alpha}) $$--> 
![eq5](https://latex.codecogs.com/svg.image?\alpha_2&space;\sim&space;Normal_{lpdf}(\alpha_2&space;|&space;Prior_{\alpha}))
<!--$$ \alpha_2 \sim Normal_{lpdf}(\alpha_2 | Prior_{\alpha}) $$--> 

![eq6](https://latex.codecogs.com/svg.image?Prior_{\tau}&space;\sim&space;Normal(0,&space;20))
<!--$$ Prior_{\tau} \sim Normal(0, 10) $$--> 
![eq7](https://latex.codecogs.com/svg.image?\tau&space;\sim&space;Normal_{lpdf}(\tau&space;|&space;Prior_{\tau}))
<!--$$ \tau \sim Normal_{lpdf}(\tau | Prior_{\tau}) $$--> 



From here, we sample posterior alpha estimates from different model fits, increasing the length of data subset (or n trials) over time:  
rate in condition 1 
<img src="fig/alpha_estimates.png" alt="alpha_estimates" width="600"/>  


From the figure above, we argue that reasonable estimations of learning rate does not happen until around 5000 trials (2500 of each condition). At this stage, both alpha parameters seem to be estimated with reasonable accuracy despite all models underestimating alpha for condition 2. Peculiarly, estimation of the learning rate in condition 2 (`alpha = 0.8`) seems to start worsening when using 10000 trials, which is thus also an argument for stopping at 5000 trials. It appears that precise estimations of the learning rate for condition (`alpha = 0.6`) take form earlier that for conditions 2. This is presumably due to the true posterior for this condition more closely resembles the passed prior. Logically, one could contrarily expect a model to recover a higher learning faster as such a rate would leads to a more drastic effect on agent belief and behavior.

Note that since STAN's sampler has a hard time dealing with hard constraints when sampling parameters values, we transform the parameters into a conceptually meaningful space (between 0 and 1 (except for tau)) using the inverse_logit function when fitting the models to help recover the best estimations. The generated estimates are re-transformed when extracted from the fitted model.

## Model quality checks
#### Markov chains
Below we visualise trace plots of the Markov chains. We see that the chains are scattered around a mean and that they seem to converge.  


<img src="fig/chains_a1.png" alt="chains" width="600"/>
<img src="fig/chains_a2.png" alt="chains" width="600"/>

Thus, we conclude that model fitting was succesfully excecuted. This is also confirmed by the fact that no prior/posterior distributions seem to have any unexpected tails or peaks.

#### Prior-posterior updates
This below figure shows the shows prior(red)-posterior(blue) update for the the parameters alpha1, alpha2 and tau when fitting a model using 2500 trials for each condition. The parameters are estimated by the model based on the priors we set. We see that for both alphas, the posterior has narrowed (thus, more certain) and moved closer to the true rates. Furthermore, the priors do not seem to have constrained estimation of the posteriors. This strenghtens our belief in that the model has successfully fitted to the data. Tau seems to have converged close to perfectly on the true value (0.5). The tau prior distribution looks weird due to the - perhaps unwarranted - transformation but this does not seem to have had any effect on the outcome.

![pp update](fig/pp_checks_alpha.png)

Below, we provide the alpha estimates generated fromm the model summary after 5000 trials. Though the difference between the estimates is not exactly equal to the true difference of 0.2, both parameters have moved significantly towards their true rates.

| Parameter | Mean estimate |  
| --- | --- | 
Alpha 1 | 0.614 |
Alpha 2 | 0.746 | 
Tau | 0.507 | 


# Part 2

## Iterated design
2500 trials is a very large number of trials and would be unmanageable for a participant to complete in one sitting. Hence, for part 2 of the assignment, we conceptualtise and test out a framework where participants can complete fewer trials over multiple sessions To produce an iterated design, we simulate a study in which a participant goes through the trials in different sessions (e.g. 5 session with 20 trials in each). We use the same models as described above, however, to accommodate the iterated study design we use a different approach for setting the priors. The first session is initialized with the same priors as outlined earlier. After each session, we save the mean and standard deviation of the estimated alphas and tau. In the next session, these values are then used for the priors for alpha1, alpha2, and tau, assuming normally distributed priors and posteriors (for a future study, this assumption should be checked and validated for each iteration - or alternatively, the actual raw prior distribution should be passed). 

We expect this approach to yield a trade off between participant comfortabilty and precision of parameter recovery; the more fewer the number of trials per sessions, the easier and more comfortable it would be to participate in such a study, however, higher number of trials per session should give better estimaetes. To explore this trade off and recover the optimal middleground, we run a model fitting loop on 4000 trials (2000 trials per condition) using 3 different trials/session-ratios: 40 sessions with 100 trials in each, 16 sessions with 250 trials and 8 sessions with 500 trials. During this exlporation, we are assuming that there is no variance across sessions for the participant, i.e. that the values for alpha and tau remain fixed between sessions. In a real-life experimental study, one could expect the participant to not remember the exact values he/she has assigned to each choice in the last session upon beginning the next session. For simplicity, our model does not take this into account. However, for future studies some noise could have been added between sessions to circumvent this.

The plot below shows the gradual evolutions of the alpha parameter estimates from session to session during the posterior passing model fitting loop for all three different experimental designs:

![pp_evolution_gif](fig/animation.gif)

The plots reveal that

| Parameter | Mean estimate |  
| --- | --- | 
Alpha 1 | 0.605 |
Alpha 2 | 0.760 | 
Tau | 0.508 | 
