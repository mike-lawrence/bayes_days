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
Ya1 = rnorm(30,97,15)
Ya2 = rnorm(30,108,15)
Yb1 = rnorm(30,100,15)
Yb2 = rnorm(30,100,15)

#generate contrast data
X = data.frame(
	intercept = 1
	, contrast1 = c(
		rep(-.5,times=length(Ya1))
		, rep(-.5,times=length(Ya2))
		, rep(.5,times=length(Yb1))
		, rep(.5,times=length(Yb2))
	)
	, contrast2 = c(
		rep(-.5,times=length(Ya1))
		, rep(.5,times=length(Ya2))
		, rep(-.5,times=length(Yb1))
		, rep(.5,times=length(Yb2))
	)
)
X$contrast3 = X$contrast1*X$contrast2
X = as.matrix(X)


my_data = data.frame(
	Y = c(Ya1,Ya2,Yb1,Yb2)
	, var1 = c(
		rep('a',times=length(Ya1))
		, rep('a',times=length(Ya2))
		, rep('b',times=length(Yb1))
		, rep('b',times=length(Yb2))
	)
	, var2 = c(
		rep('1',times=length(Ya1))
		, rep('2',times=length(Ya2))
		, rep('1',times=length(Yb1))
		, rep('2',times=length(Yb2))
	)
)
my_data$var1 = factor(my_data$var1)
my_data$var2 = factor(my_data$var2)
#now forget how my_data was structured and try to create X
X = data.frame(
	intercept = 1
	, contrast1 = as.numeric(my_data$var1)-1.5
	, contrast2 = as.numeric(my_data$var2)-1.5
	, contrast3 = as.numeric(my_data$var3)-1.5
)
X$contrast4 = X$contrast1*X$contrast2
X$contrast5 = X$contrast2*X$contrast3
X$contrast6 = X$contrast1*X$contrast3
X$contrast7 = X$contrast1*X$contrast2*X$contrast3
X = as.matrix(X)


#package the data for stan
data = list(
	nY = nrow(my_data)
	, nX = ncol(X)
	, Y = my_data$Y
	, X = X
)

#compile the model (takes a minute or so)
model = rstan::stan_model(file=list.files(pattern='.stan'))

#evaluate the model
sampling_iterations = 2e3 #best to use 1e3 or higher
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

groupA1 = with(
	samples
	, value[Parameter=='beta.1.'] +
		value[Parameter=='beta.2.']*-.5 +
		value[Parameter=='beta.3.']*-.5 +
		value[Parameter=='beta.4.']*.25
)
groupA2 = with(
	samples
	, value[Parameter=='beta.1.'] +
		value[Parameter=='beta.2.']*-.5 +
		value[Parameter=='beta.3.']*.5 +
		value[Parameter=='beta.4.']*-.25
)
groupB1 = with(
	samples
	, value[Parameter=='beta.1.'] +
		value[Parameter=='beta.2.']*.5 +
		value[Parameter=='beta.3.']*-.5 +
		value[Parameter=='beta.4.']*-.25
)
groupB2 = with(
	samples
	, value[Parameter=='beta.1.'] +
		value[Parameter=='beta.2.']*.5 +
		value[Parameter=='beta.3.']*.5 +
		value[Parameter=='beta.4.']*.25
)

quantile(groupA1,probs=c(.025,.5,.975))
quantile(groupA2,probs=c(.025,.5,.975))

quantile(groupA1-groupA2,probs=c(.025,.5,.975))
quantile(groupB1-groupB2,probs=c(.025,.5,.975))
quantile(groupA1-groupB1,probs=c(.025,.5,.975))
quantile(groupA2-groupB2,probs=c(.025,.5,.975))


