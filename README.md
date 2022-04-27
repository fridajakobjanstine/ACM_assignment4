# ACM_assignment4
this is 4 riccardo

## Experimental setup
In this assignment, we are implementing a reinforcement learning model. 
We simulate an experiment in which participants pick between two choices in each trial. 
These two choices have constant and proportional reward probabilities (e.g. if `p(choice_1) = 0.8`, then `p(choice_2) = 0.2`). 
The agent implicitly learns these reward probabilities by attributing values to the two choices;
Value, or expectation of reward on next trial if choice c is picked, is updated each trial following:

<img src="http://www.sciweavers.org/tex2img.php?eq=V_%7Bt%2B1%7D%5E%7Bc%7D%20%3D%20V%5E%7Bc%7D_%7Bt%7D%20%2B%20%5Calpha%20%28R_t%20-%20V%5E%7Bc%7D_%7Bt%7D%29&bc=White&fc=Black&im=png&fs=12&ff=arev&edit=0" align="center" border="0" alt="V_{t+1}^{c} = V^{c}_{t} + \alpha (R_t - V^{c}_{t})" width="186" height="25" />
<!--$$ V_{t+1}^{c} = V^{c}_{t} + \alpha (R_t - V^{c}_{t}) $$--> 

where t is trial number, alpha is the learning rate and R is whether reward was achieved or not.
Learning rate serves to weight prediction error.
A high learning rate pushes an agent to update value in bigger increments.

An agent reaches a choice following:

<img src="http://www.sciweavers.org/tex2img.php?eq=Choice%20%5Csim%20Binomial%281%2C%20~%5Csigma%28V_%7Bt%7D%5E%7Bc2%7D%20-%20V_%7Bt%7D%5E%7Bc1%7D%2C%20%5Ctau%29%29&bc=White&fc=Black&im=png&fs=12&ff=arev&edit=0" align="center" border="0" alt="Choice \sim Binomial(1, ~\sigma(V_{t}^{c2} - V_{t}^{c1}, \tau))" width="319" height="25" /><!--$$ Choice ~ Binomial(1, \sigma(V_{t}^{c2} - V_{t}^{c1}, \tau)) $$-->

where sigma is a softmax function, with temperature tau. 
Temperature is the "exponentiality" of the softmax function (see figure bellow).
This parameter can be thought of as agent's explore X exploit bias.
A high temperature pushes the agent to "exploit", meaning having higher probability to pick the more valued choice.

![softmax_temp](fig/softmax_vis.png)


## Parameter recovery model
We simulate data for two conditions:  
1) alpha = 0.6  
2) alpha = 0.8

While having fixed reward probability: `p(choice_1) = 0.75` and `p(choice_2) = 0.25`;
And fixed temperature of `
0.5 (value is non-deterministic in making choice) 

We fit a model on the simulated data, aiming to learn the alpha values used in data generation.
