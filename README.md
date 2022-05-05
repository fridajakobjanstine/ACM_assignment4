# ACM_assignment4
this is 4 riccardo

## Experimental setup
In this assignment, we are implementing a reinforcement learning model. 
We simulate an experiment in which participants pick between two choices in each trial. 
These two choices have constant and proportional reward probabilities (e.g. if `p(choice_1) = 0.8`, then `p(choice_2) = 0.2`). 
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
1) alpha = 0.6  
2) alpha = 0.8

While having fixed reward probability: `p(choice_1) = 0.75` and `p(choice_2) = 0.25`;
And fixed temperature `tau = 0.5` (value is non-deterministic in making choice) 

The agents chooses an option following the decision rule described above, and updates its value of that choice based on the learning rate. Learning rates were set to 0.8 for condition 1, and 0.6 for condition 2. The agent's belief of the reward probability of option 1 under each of the two condition can be seen below:

<img src="fig/alpha_08.png" alt="alpha08" width="700"/>
<img src="fig/alpha_06.png" alt="alpha06" width="700"/>

Clearly, the agent is updating the expected value of the option too much for both conditions, especially with a learning of 0.8. It is not a problem for the parameter recovery that the agent to such a high degree 

## Parameter recovery model

We fit a model on the simulated data, aiming to recover the alpha- and tau values used in data generation. In order to estimate the required number of trials to correctly recover the parameters, we fit the model using subsets of the data with fewer trials. That is, we fit the model using only the data from the first n trials, with n = 100, 200, 500, 1000, 2000, 5000. 

NOTE description of model, write some equations
