poiss_norm_analysis <- function (z, mu_mu, mu_tau, tau_r, tau_glambda, poi_r, poi_glambda,
									num_samples, burn_cycles, num_adapt, num_thin)
{
  # Separate z into ones ('ones') and non-ones ('z2')
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
  if (num_thin<1)
  {
    num_thin = 1
  }
  # Call JAGS to generate a model
	mc.mod <- jags.model("Combined Model.txt",
						 data = list('ones' = ones, 'z2' = z2, 'M' = ones_i, 'N'=z2_i, 'mu_mu'=mu_mu, 'mu_tau'=mu_tau,
						             'tau_r'=tau_r, 'tau_glambda'=tau_glambda, 'poi_r'=poi_r, 'poi_glambda'=poi_glambda),
						 n.chains = 1,
						 n.adapt = num_adapt)
	if (burn_cycles > 0)
	{
	  update(mc.mod, n.iter=burn_cycles)
	}
	# Call JAGS to generate posterior samples
	mclist.samples <- jags.samples(mc.mod,
								c('hidden_mu', 'hidden_tau', 'hidden_lambda'),
								num_samples,
								thin = num_thin)
	# Lists of the sampled points (for mu, tau, and lambda)
	est_mus <- mclist.samples$hidden_mu
	est_taus <- mclist.samples$hidden_tau
	est_lambdas <- mclist.samples$hidden_lambda
	return (list(est_mus, est_taus, est_lambdas))
}