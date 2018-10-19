# Outer code, set initialization parameters and loop lengths

library ('rjags')
#setwd("D:/Users/David/Dropbox/Other/Schoolwork/Machine Learning/part 2")

# True values underlying the data generation
core_mu <- 4
core_sigma <- 0.4
core_lambda <- 10
num_data <- 400

# Convert Sigma to Tau
core_tau <- core_sigma^(-2)

# Generate the data to analyze
# Essentially: z = (rpois + 1) ^ rnorm
x <- rnorm(num_data, mean = core_mu, sd = core_sigma)
y <- rpois(num_data, core_lambda) + 1
z <- y ^ x

# ** Prior Distribution Parameters **
#   Notes:
#    tau = 1/(sigma ^ 2)
#    gamma mean = r/lambda
#    gamma var = r/(lambda^2) = (gamma mean)/lambda
#   So uninformative priors have tau, r, and lambda all relatively low.
#   I do not recommend r less than 0.05, as it approaches the limit of floating-point precision.
mu_mu <- 4 # Initial mean for normal estimator for mu
mu_tau <- 0.3 # Initial tau for normal estimator for mu, lower is less precise
tau_r <- 0.1 # Initial shape of Gamma estimator for tau
tau_glambda <- 0.08 # Initial rate (lambda) of Gamma estimator for tau
poi_r <- 0.1 # Initial shape of Gamma estimator for lambda
poi_glambda <- 0.02 # Initial rate (lambda) of Gamma estimator for lambda

# Gibbs sampling variables
num_samples <- 1000 # Number of Gibbs samples
burn_cycles <- 1000 # Number of cycles to ignore, as it "burns in" to the limiting distribution
num_adapt <- 1000 # Length of adaptation step, which theoretically improves performance
num_thin <- 10 # Thinning size, i.e. how many iterations to wait per sample, for independence

# Load gibbs sampling code
source("mcmc_analyzer.r")

# Execute sampling and get results
var_samples <- poiss_norm_analysis (z, mu_mu, mu_tau, tau_r, tau_glambda, poi_r, poi_glambda,
									                  num_samples, burn_cycles, num_adapt, num_thin)

# Unpack the results into vectors
norm_mus <-unlist(var_samples[1], use.names=FALSE)
norm_taus <- unlist(var_samples[2], use.names=FALSE)
pois_lams <- unlist(var_samples[3], use.names=FALSE)
norm_sigmas <- vector(mode='numeric',length(norm_taus))
for (i in 1:length(norm_taus))
{
	norm_sigmas[i] = 1/sqrt(norm_taus[i])
}

# Graph the results
plot(pois_lams, norm_mus, xlab='Poisson Lambda estimates',
     ylab='Normal Mu estimates',main='Posterior Pairs for underlying values')


# Median is much more accurate as a point estimate than the mean due to curvature
# The Mode is possible to deduce, but tricky
median_mu <- median(norm_mus) # Final median mu estimate
median_sigma <- median(norm_sigmas) # Final median SD estimate
median_tau <- median(norm_taus) # Final median tau estimate
median_lambda <- median(pois_lams) # Final median lambda estimate

# Differences between original and median estimate mu/sigma/lambda
diff_mu <- median_mu - core_mu
diff_sigma <- median_sigma - core_sigma
diff_lambda <- median_lambda - core_lambda
diff <- list(diff_mu,diff_sigma,diff_lambda)

# Percentage difference between estimates and underlying values
# (Note that because the data is randomly generated, and the estimates are based
#   on the data, even perfect induction results in error)
perc_diff <- list(diff_mu/core_mu, diff_sigma/core_sigma, diff_lambda/core_lambda)

# This repeats the procedure done in poiss_norm_analysis so it shows up in environment overlay/can be queried
# "ones_i" will be the number of ones, z2_i the number of non-ones
ones_i = 0
ones = list()
z2_i = 0
z2 = list()
for (i in 1:length(z))
{
  if (z[i] == 1)
  {
    ones_i = ones_i + 1
    ones[ones_i] = 0
  } else {
    z2_i = z2_i + 1
    z2[z2_i] = z[i]
  }
}