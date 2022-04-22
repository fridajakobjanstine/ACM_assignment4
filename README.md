# ACM_assignment4
this is 4 riccardo


## First meaning
**THIS IS NOT WHAT WE'RE DOING ACTUALLY**  
Is a simplification. 
The agent choses between two options, which have a constant underlying reward probability.
Reward probabilities for the two options ("choices") add up to 1 – if option 1 has reward probability of 0.8, then option two has rp of 0.2.

We model an agent learning this underlying reward probability.
Because they are symmetrical, our agent can be assumed to always choose the same option – the agent learns reward probability of option 1 explicitly & of option 2 implicitly.

During a trial, the agent makes a choice between the two options based on theta – 
that is which option has higher value (value(option 1) and 1 - value(option 1) ) * temperature. 
Normalization to make theta a probability included.

Based on the option picked, the agent gets a reward. 
If reward is different than expected, prediction error will be high.

The agents estimates a value (expectation on the next trial), based on last choice modified by learning rate * prediction error.
We are interested in the number of trials needed for the agent to learn the underlying reward probability.
That is simply, at which trial number does reward probability equal agent's value.

    Dictionary:
    ----------

    value : expectation on the next trial 
    theta : probability of chosing option 1, modified by tau 
    tau : temperature (explore X exploit bias)
    alpha : learning rate (impact of prediction error on value)
  
  
## Second meaning
**THIS IS WHAT WE'RE DOING**  
From the environment (trial, choice, feedback, condition, etc.) reconstruct an agents ALPHA & TAU!
