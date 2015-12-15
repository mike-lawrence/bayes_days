
data {
	int<lower=1> nY ; # num trials
	int<lower=1> nS ; # num subjects
	int<lower=1,upper=nS> S[nY] ; # subject for trial
	vector[nY] contrast ; # contrast for trial
	vector[nY] Y ; # outcomes
}
parameters {
	real<lower=0> sigma ; #trial-by-trial error
	real intercept ; #population-level intercept
	real effect ; #population-level effect
	real<lower=0> intercept_sd ; #SD of subject-to-subject deviation from the population intercept
	real<lower=0> effect_sd ; #SD of subject-to-subject deviation from the population effect
	vector[nS] Sintercept ; #variable to store each subject's intercept
	vector[nS] Seffect ; #variable to store each subject's intercept
}
model {
	#priors on population parameters
	sigma ~ cauchy(0,20) ;
	intercept ~ normal(100,10) ;
	effect ~ normal(0,20) ;
	intercept_sd ~ cauchy(0,20) ;
	effect_sd ~ cauchy(0,20) ;

	#assert sampling of subject-level parameters given population parameters
	Sintercept ~ normal(intercept,intercept_sd) ;
	Seffect ~ normal(effect,effect_sd) ;

	#assert sampling of trial-by-trial data given subject-level parameters and sigma
	for(ny in 1:nY){
		Y[ny] ~ normal( Sintercept[S[ny]] + Seffect[S[ny]]*contrast[ny] , sigma ) ;
	}

}
