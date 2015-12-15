# hierarchical within

#clear workspace to ensure a fresh start
rm(list=ls())

#load rstan
library(rstan)

#load ggmcmc
library(ggmcmc)

#set the random seed (so we all generate the same fake data)
set.seed(1)

########
#generate some fake data
########

N = 30 #number of subjects
K = 5 #number of observations per subject per condition

#population parameters
sigma = 10 #trial-by-trial error (common across Ss)
intercept_mean = 100
intercept_sd = 15
effect_mean = 10
effect_sd = 3

Sintercept = rnorm(N,intercept_mean,intercept_sd)
Seffect = rnorm(N,effect_mean,effect_sd)

#iterate over subjects to generate data for each one
data = NULL
for(subnum in 1:N){
	data = rbind(
		data
		, data.frame(
			id = subnum
			, condition = 'a'
			, value = rnorm( K , Sintercept[subnum] - Seffect[subnum]/2 , sigma )
		)
		, data.frame(
			id = subnum
			, condition = 'b'
			, value = rnorm( K , Sintercept[subnum] + Seffect[subnum]/2 , sigma )
		)
	)
}

#factorize id & condition because this is how we usually encounter them in real data
data$id = factor(data$id)
data$condition = factor(data$condition)

#show the data in the viewer
View(data)

#define a helper function
factor_to_contrast = function(x){
	as.numeric(x)-1.5
}


#package the data for stan
data_for_stan = list(
	nY = nrow(data)
	, nS = length(unique(data$id))
	, Y = data$value
	, contrast = factor_to_contrast(data$condition)
	, S = as.numeric(data$id)
)

#compile the model (takes a minute or so)
model = rstan::stan_model(file=list.files(pattern='.stan'))
save(model,file='model.rdata')
# load('model.rdata')

#evaluate the model
sampling_iterations = 2e4 #best to use 2e3 or higher
out = rstan::sampling(
	object = model
	, data = data_for_stan
	, chains = 1
	, iter = sampling_iterations
	, warmup = sampling_iterations/2
	, refresh = sampling_iterations/10 #show an update @ each %10
	, seed = 1
	#uncomment the next line to retain only the population-level parameters
	# , pars = c('sigma','intercept','effect','intercept_sd','effect_sd')
)

#print a summary table
print(out)
#look at n_eff and RHat to see if we've groupd enough
#    we generally want n_eff>1e3 & Rhat==1
#    if these criteria are not met, run again with more iterations
save(out,file='stan_out.rdata')
# load('stan_out.rdata')

#define a function that will extract samples for a subset of the parameters
get_samples = function(stan_out,pars_to_keep){
	samples = ggmcmc::ggs(stan_out)
	a = attributes(samples)
	samples = samples[samples$Parameter %in% pars_to_keep,]
	a$row.names = 1:nrow(samples)
	attributes(samples) <- a
	attr(samples,'nParameters') = length(pars_to_keep)
	return(samples)
}

#extract the posterior samples in a format that ggmcmc likes
samples = get_samples(
	stan_out = out
	, pars_to_keep = c('sigma','intercept','effect','intercept_sd','effect_sd')
)

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

#look at the condition means & difference score
condition1 = with(
	samples
	, value[Parameter=='intercept'] +
		value[Parameter=='effect']*-.5
)
condition2 = with(
	samples
	, value[Parameter=='intercept'] +
		value[Parameter=='effect']*.5
)
quantile(condition1,probs=c(.025,.5,.975))
quantile(condition2,probs=c(.025,.5,.975))
quantile(condition1-condition2,probs=c(.025,.5,.975))

#another way to look at the cells, "zeroing-out" intercept variance
# so that we can show a plot of the cells without showing uninteresting
# uncertainty associated with the intercept
condition1 = with(
	samples
	, mean(value[Parameter=='intercept']) +
		value[Parameter=='effect']*-.5
)
condition2 = with(
	samples
	, mean(value[Parameter=='intercept']) +
		value[Parameter=='effect']*.5
)
quantile(condition1,probs=c(.025,.5,.975))
quantile(condition2,probs=c(.025,.5,.975))
quantile(condition1-condition2,probs=c(.025,.5,.975))















