#two groups, common sigma, center-diff parameterization, long-formatted data
data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	vector[nY] Y ; # initialize a vector to hold the observations
	vector[nY] X ; # initialize a vector to hold the predictors
}
parameters {
	real mu ; #center-point between data-generating populations' means
	real diff ; #difference between data-generating populations' means
	real<lower=0> sigma ; #SD of both data-generating populations, constrained to positive
}
model {
	mu ~ normal(100,20) ; #prior on center-point
	diff ~ normal(0,20) ; #prior on difference
	sigma ~ cauchy(0,15) ; #prior on sigma
	Y ~ normal(mu+diff*X,sigma) ; #sampling statement for data
}
