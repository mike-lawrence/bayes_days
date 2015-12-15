# hierarchical within with correlations
data {
	int<lower=1> nY ; # num trials
	int<lower=1> nS ; # num subjects
	int<lower=1,upper=nS> S[nY] ; # subject for trial
	vector[nY] contrast ; # contrast for trial
	vector[nY] Y ; # outcomes
}
parameters {
	real<lower=0> sigma ; #trial-by-trial error
	vector[2] mu ; #population-level intercept and effect
	vector<lower=0>[2] tau ; #SDs of subject deviations from population intercept and effect
	corr_matrix[2] rho ; #correlation matrix for across-subjects correlation between intercept and effect
	vector[2] Smu[nS] ; #subject-by-subject intercept and effect
}
model {
	matrix[2,2] Z ; #used in getting correlation to work
	Z <- quad_form_diag(rho,tau) ; #used in getting correlation to work

	#priors on population parameters
	sigma ~ cauchy(0,20) ;
	mu[1] ~ normal(100,10) ; #prior on population intercept
	mu[2] ~ normal(0,20) ; #prior on population effect
	tau ~ cauchy(0,20) ; # prior on SDs (both at once)
	rho ~ lkj_corr(1) ; #uniform prior on correlation

	#assert sampling of subject-level parameters given population parameters
	for(ns in 1:nS){
		Smu[ns] ~ multi_normal(mu,Z) ;
	}

	#assert sampling of trial-by-trial data given subject-level parameters and sigma
	for(ny in 1:nY){
		Y[ny] ~ normal( Smu[S[ny],1] + Smu[S[ny],2]*contrast[ny] , sigma ) ;
	}

}
