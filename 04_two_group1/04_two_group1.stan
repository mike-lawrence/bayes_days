#two groups, common sigma, two-cells parameterization
data {
	int nY1 ; # initialize a variable to indicate the number of elements in Y
	int nY2 ; # initialize a variable to indicate the number of elements in Y
	vector[nY1] Y1 ; # initialize a vector to hold the observations
	vector[nY2] Y2 ; # initialize a vector to hold the observations
}
parameters {
	real mu1 ; #mean of the Y1 data-generating population
	real mu2 ; #mean of the Y2 data-generating population
	real<lower=0> sigma ; #SD of both data-generating populations, constrained to positive
}
model {
	mu1 ~ normal(100,20) ; #prior on mu1
	mu2 ~ normal(100,20) ; #prior on mu2
	sigma ~ cauchy(0,15) ; #prior on sigma
	Y1 ~ normal(mu1,sigma) ; #sampling statement for Y1 data
	Y2 ~ normal(mu2,sigma) ; #sampling statement for Y2 data
}
