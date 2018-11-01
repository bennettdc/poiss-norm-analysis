# poiss-norm-analysis
Generates an arbitrary data set by repeatedly taking a Poisson-distributed variable exponentiated by a Normally distributed variable, then uses Gibbs Sampling to derive the original parameters

For instructions on running the program, consult INSTRUCTIONS.txt

The purpose of this program is to test the effectiveness of Bayesian analysis, by attempting something that would be extremely difficult using frequentist analysis.

The problem, specified intentionally to be difficult for frequentist analysis is this:

Z = (X+1)^Y, where X ~ Poisson(lambda) and Y ~ Normal(mu, sigma^2)
Given data points Z, find (or rather, estimate) lambda, mu, and sigma.

An idea of a situation where this form of data might occur could be random events of pedestrians accumulating at a crosswalk generating levels of noise. X could be taken as the number of pedestrians, and Y could be the rate at which they inspire one another to make louder noises (Y>1 could mean an amplifying effect, 0<Y<1 could mean diminishing returns, Y<0 seems unlikely but theoretically justifiable under specific circumstances.)

X+1 was taken in order to avoid the silly 0^Y. Alternatively, X~PositivePoisson(lambda) would have sufficed. Neither is strictly needed, nor does either eliminate the similarly silly data points of 1^Y. Dealing with X + 1 = 1 turned out to be a key element in finding the correct solution.

Ultimately, to solve this using JAGS, I had to do a little tweaking. JAGS hasn't implemented exponentiation of latent variables. JAGS also hasn't implemented multiplication of latent variables. JAGS HAS implemented addition of latent variables, but ultimately that's unnecessary. Doing a little math you can turn this latent exponentiation into a scale variable:

log(z) = Y * log(X+1) ~ Normal(mu * log(X+1), (sigma * log(X+1))^2)

And voila! Now X is just a parameter, which is very easy to implement in Gibbs Sampling. However, we will later encounter a problem with log(X+1), when we try to plug it in for the variance.

As stated, the derived normal distribution has a variance of (sigma * log(X+1))^2. If log(X+1) = log(0+1) = log(1) = 0, then the variance = 0, which is a problem as that results in an infinitely precise normal distribution. Thankfully, we know exactly for which data points X = 0: when Z = 1 it is necessarily due to X = 0. (X+1)^Y = 1 IFF (X = 0 || Y = 0 || Y = -inf || (X = -2 && Y is Even)) Since Y is a continuous distribution, the chances that Y = 0 are infinitesimal, and the third and fourth cases are likewise impossible.

So we separate the data into the points where Z = X+1 = 1 and Z =/= 1. Then we apply Gibbs Sampling such that the data points where Z=1 are informative *only for the poisson distribution.*
