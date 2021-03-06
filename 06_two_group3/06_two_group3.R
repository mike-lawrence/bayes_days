#two groups, common sigma, center-diff parameterization, long-formatted data

#clear workspace to ensure a fresh start
rm(list=ls())

#load rstan
library(rstan)

#load ggmcmc
library(ggmcmc)

#set the random seed (so we all generate the same fake data)
set.seed(1)

#generate some fake data
Y1 = rnorm(30,97,15)
Y2 = rnorm(30,108,15)

my_long_data = data.frame(
	Y = c(Y1,Y2)
	, group = c(
		rep('a',times=length(Y1))
		, rep('b',times=length(Y2))
	)
	, X = c(
		rep(-.5,times=length(Y1))
		, rep(.5,times=length(Y2))
	)
)

#package the data for stan
data = list(
	nY = nrow(my_long_data)
	, Y = my_long_data$Y
	, X = my_long_data$X
)

#compile the model (takes a minute or so)
model = rstan::stan_model(file=list.files(pattern='.stan'))

#evaluate the model
sampling_iterations = 2e3 #best to use 2e3 or higher
out = rstan::sampling(
	object = model
	, data = data
	, chains = 1
	, iter = sampling_iterations
	, warmup = sampling_iterations/2
	, refresh = sampling_iterations/10 #show an update @ each %10
	, seed = 1
)

#print a summary table
print(out)
#look at n_eff and RHat to see if we've groupd enough
#    we generally want n_eff>1e3 & Rhat==1
#    if these criteria are not met, run again with more iterations

#extract the posterior groups in a format that ggmcmc likes
samples = ggmcmc::ggs(out)

#look at the full-vs-partial density (should look the same)
ggmcmc::ggmcmc(
	D = samples
	, file = NULL
	, plot = 'ggs_compare_partial'
)

#look at the auto-correlations
ggmcmc::ggmcmc(
	D = samples
	, file = NULL
	, plot = 'ggs_autocorrelation'
)
