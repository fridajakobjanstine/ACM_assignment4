# ACM_assignment4
this is 4 riccardo

## Experimental setup
In this assignment, we are implementing a reinforcement learning model. 
We simulate an experiment in which participants pick between two choices in each trial. 
These two choices have constant and proportional reward probabilities (e.g. if p(choice_1) = 0.8, then p(choice_2) = 0.2). 
The agent implicitly learns these reward probabilities by attributing values to the two choices;
Value, or expectation of reward on next trial if choice c is picked, is updated each trial following:

<img src="https://render.githubusercontent.com/render/math?math=V_{t+1}^{c} = V^{c}_{t} + \alpha (R_t - V^{c}_{t})">
[//]: $$ V_{t+1}^{c} = V^{c}_{t} + \alpha (R_t - V^{c}_{t}) $$

where t is trial number, alpha is the learning rate and R is whether reward was achieved or not.
Learning rate serves to weight prediction error.
A high learning rate pushes an agent to update value in bigger increments.

An agent reaches choice

<img src="https://render.githubusercontent.com/render/math?math=Choice ~ Binomial(1, \sigma(V_{t}^{c2} - V_{t}^{c1}, \tau))">
[//]: $$ Choice ~ Binomial(1, \sigma(V_{t}^{c2} - V_{t}^{c1}, \tau)) $$

where sigma is a softmax function, with temperature tau. 
Temperature is the "exponentiality" of the softmax function (see figure bellow).
This parameter can be thought of as agent's explore X exploit bias.
A high temperature pushes the agent to "exploit", meaning having higher probability to pick the more valued choice.

![softmax_temp](fig/softmax_vis.png)


## Parameter recovery model
We simulate data for two conditions:  
1) alpha = 0.6  
2) alpha = 0.8

While having fixed reward probability: p(choice_1) = 0.75 and p(choice_2) = 0.25;
And fixed temperature of 0.5 (value is non-deterministic in making choice) 

We fit a model on the simulated data, aiming to learn the alpha values used in data generation.
