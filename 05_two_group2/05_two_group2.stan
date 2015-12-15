#two groups, common sigma, center-diff parameterization
data {
	int nY1 ; # initialize a variable to indicate the number of elements in Y
	int nY2 ; # initialize a variable to indicate the number of elements in Y
	vector[nY1] Y1 ; # initialize a vector to hold the observations
	vector[nY2] Y2 ; # initialize a vector to hold the observations
}
parameters {
	real mu ; #center-point between data-generating populations' means
	real diff ; #difference between data-generating populations' means
	real<lower=0> sigma ; #SD of both data-generating populations, constrained to positive
}
model {
	mu ~ normal(100,20) ; #prior on center point
	diff ~ normal(0,20) ; #prior on difference
	sigma ~ cauchy(0,15) ; #prior on sigma
	Y1 ~ normal(mu+diff/2,sigma) ; #sampling statement for Y1 data
	Y2 ~ normal(mu-diff/2,sigma) ; #sampling statement for Y2 data
}
