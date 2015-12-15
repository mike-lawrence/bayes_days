# hierarchical within

#clear workspace to ensure a fresh start
rm(list=ls())

#load rstan
library(rstan)

#load ggmcmc
library(ggmcmc)

#load MASS for mvrnorm
library(MASS)

#set the random seed (so we all generate the same fake data)
set.seed(1)

########
#generate some fake data
########

N = 30 #number of subjects
K = 5 #number of observations per subject per condition

#population parameters
intercept_mean = 100
intercept_sd = 15
effect_mean = 10
effect_sd = 3
intercept_effect_correlation = 0.7
sigma = 10 #trial-by-trial error (common across Ss)

#covariance matrix
v = matrix(
	data = c(
		intercept_sd^2
		, intercept_sd*effect_sd*intercept_effect_correlation
		, intercept_sd*effect_sd*intercept_effect_correlation
		, effect_sd^2
	)
	, nrow = 2
	, ncol = 2
)

#actually sample the population
subject_parameters = MASS::mvrnorm(N,c(intercept_mean,effect_mean),v)
mean(subject_parameters[,1])
mean(subject_parameters[,2])
sd(subject_parameters[,1])
sd(subject_parameters[,2])
cor(subject_parameters[,1],subject_parameters[,2])

#iterate over subjects to generate data for each one
data = NULL
for(subnum in 1:N){
	data = rbind(
		data
		, data.frame(
			id = subnum
			, condition = 'a'
			, value = rnorm(K , subject_parameters[subnum,1] - subject_parameters[subnum,2]/2 , sigma )
		)
		, data.frame(
			id = subnum
			, condition = 'b'
			, value = rnorm(K , subject_parameters[subnum,1] + subject_parameters[subnum,2]/2 , sigma )
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

#define contrast matrix
X = data.frame(
	intercept = 1
	, contrast1 = factor_to_contrast(data$condition)
)
X = as.matrix(X)
#package the data for stan
data_for_stan = list(
	nY = nrow(data)
	, nX = ncol(X)
	, nS = length(unique(data$id))
	, Y = data$value
	, X = X
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
)
save(out,file='stan_out.rdata')
# load('stan_out.rdata')

#print a summary table
print(out)
#look at n_eff and RHat to see if we've sampled enough
#    we generally want n_eff>1e3 & Rhat==1
#    if these criteria are not met, run again with more iterations

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
	out
	, pars_to_keep = c('sigma','mu.1.','mu.2.','tau.1.','tau.2.','rho.1.2.')
)

#look at the full-vs-partial density (should look the same)
ggmcmc::ggmcmc(
	D = samples
	, file = NULL
	, plot = 'ggs_compare_partial'
	, param_page = length(unique(samples$Parameter))
)

#look at the auto-correlations
ggmcmc::ggmcmc(
	D = samples
	, file = NULL
	, plot = 'ggs_autocorrelation'
	, param_page = length(unique(samples$Parameter))
)

#look at the condition means & difference score
condition1 = with(
	samples
	, value[Parameter=='mu.1.'] +
		value[Parameter=='mu.2.']*-.5
)
condition2 = with(
	samples
	, value[Parameter=='mu.1.'] +
		value[Parameter=='mu.2.']*.5
)
quantile(condition1,probs=c(.025,.5,.975))
quantile(condition2,probs=c(.025,.5,.975))
quantile(condition1-condition2,probs=c(.025,.5,.975))

#another way to look at the cells, "zeroing-out" intercept variance
# so that we can show a plot of the cells without showing uninteresting
# uncertainty associated with the intercept
condition1 = with(
	samples
	, mean(value[Parameter=='mu.1.']) +
		value[Parameter=='mu.2.']*-.5
)
condition2 = with(
	samples
	, mean(value[Parameter=='mu.1.']) +
		value[Parameter=='mu.2.']*.5
)
quantile(condition1,probs=c(.025,.5,.975))
quantile(condition2,probs=c(.025,.5,.975))
quantile(condition1-condition2,probs=c(.025,.5,.975))















