#two groups, effect on sigma
data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	vector[nY] Y ; # initialize a vector to hold the observations
	vector[nY] X ; # initialize a vector to hold the predictors
}
parameters {
	real mu_center ; #center-point between data-generating populations' means
	real mu_diff ; #difference between data-generating populations' means
	real log_sigma_center ; #SD of both data-generating populations, constrained to positive
	real log_sigma_diff ; #SD of both data-generating populations, constrained to positive
}
model {
	mu_center ~ normal(100,20) ; #prior on mu center-point
	mu_diff ~ normal(0,20) ; #prior on mu difference
	log_sigma_center ~ normal(log(10),1) ; #prior on log-sigma center-point
	log_sigma_diff ~ normal(0,1) ; #prior on log-sigma center-point
	Y ~ normal( mu_center+mu_diff*X , exp(log_sigma_center+log_sigma_diff*X) ) ; #sampling statement for data
}
