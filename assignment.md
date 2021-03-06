Assignment 4 - Instructions
Part 1 - You have to design a study (aka plan the number of trials) assuming that people are using a reinforcement learning process to pick between 2 stimuli. In this study you expect there to be 2 conditions and the 1 participant playing the game will vary its learning rate between conditions. The difference in learning rate is .2: condition 1 has x - .1 and condition 2 x + .1, with x = 0.7. The temperature is the same: 0.5.

    Identify a feasible number of trials and motivate it.
    [optional]: what happens if x is not = +.7 (tip: test a range of different x)?
    [optional]: what happens if temperature is not 0.5, but 5?

Part 2 - Given the large number of trials required, could you imagine producing an iterated design? E.g. a phone app where you can do a smaller number of trials (e.g. 10-20 or even 100, up to you!) in separate sessions, each time a posterior is generated and it is used as prior in the next time.

    Assuming no variance over time (ah!) can you figure out a good trade off between how many trials per session and number of sessions?
    [optional]: what are the differences in just re-running the model on the cumulative dataset (increased at every session) vs passing the posterior? Differences in terms of computational time, estimates, but also practical implication for running your study.
    [optional]: what happens if learning rate changes a bit across sessions? Include a variation between sessions according to a normal distribution with a mean of 0 and a sd of 0.02. Re-assess the number of trials/sessions used.
