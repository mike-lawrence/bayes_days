#one group, estimated error variance, heavy-tailed for outlier-robustness

data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	vector[nY] Y ; # initialize a vector to hold the observations
}
parameters {
	real mu ; #mean of the data-generating population
	real<lower=0> sigma ; #SD of the data-generating population, constrained to positive
}
model {
	mu ~ normal(100,20) ; #prior on mu
	sigma ~ lognormal(2.7,2) ; #prior on sigma
	Y ~ cauchy(mu,sigma) ; #sampling statement for data (note outlier-robust cauchy)
}
