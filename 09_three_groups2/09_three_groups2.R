#three groups, matrix-coded 

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
Y3 = rnorm(30,108,15)

#generate contrast data
X = data.frame(
	intercept = 1
	, contrast1 = c(
		rep(-.5,times=length(Y1))
		, rep(.5,times=length(Y2))
		, rep(0,times=length(Y2))
	)
	, contrast2 = c(
		rep(-.25,times=length(Y1))
		, rep(-.25,times=length(Y2))
		, rep(.5,times=length(Y2))
	)
)
X = as.matrix(X)

#package the data for stan
data = list(
	nY = length(Y1)+length(Y2)+length(Y3)
	, nX = ncol(X)
	, Y = c(Y1,Y2,Y3)
	, X = X
)

#compile the model (takes a minute or so)
model = rstan::stan_model(file=list.files(pattern='.stan'))

#evaluate the model
sampling_iterations = 2e4 #best to use 1e3 or higher
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

#look at the group means
samples %>% 
	plyr::summarize(
		group1 = value[Parameter=='beta.1.'] + value[Parameter=='beta.2.']*-.5 + value[Parameter=='beta.3.']*-.25
		, group2 = value[Parameter=='beta.1.'] + value[Parameter=='beta.2.']*.5 + value[Parameter=='beta.3.']*-.25
		, group3 = value[Parameter=='beta.1.'] + value[Parameter=='beta.2.']*0 + value[Parameter=='beta.3.']*.5
	) %>%
	plyr::summarize(
		group1vs2 = quantile(group1-group2,probs=c(.025,.5,.975))
		, group2vs3 = quantile(group2-group3,probs=c(.025,.5,.975))
		, group1vs3 = quantile(group1-group3,probs=c(.025,.5,.975))
	)
