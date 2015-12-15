#one group, estimated error variance

#clear workspace to ensure a fresh start
rm(list=ls())

#load rstan
library(rstan)

#load ggmcmc
library(ggmcmc)

#set the random seed (so we all generate the same fake data)
set.seed(1)

#generate some fake data
Y = rnorm(30,110,10)

#package the data for stan
data = list(
	nY = length(Y)
	, Y = Y
)

#compile the model (takes a minute or so)
if('02_one_group2.rdata' %in% list.files()){
	load('02_one_group2.rdata')
}else{
	model = rstan::stan_model(file='02_one_group2.stan')
	save(model,file='02_one_group2.rdata')
}

#evaluate the model
sampling_iterations = 1e4 #best to use 1e3 or higher
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
#look at n_eff and RHat to see if we've sampled enough
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
