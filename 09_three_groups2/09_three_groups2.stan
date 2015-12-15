#three groups, matrix-coded 
data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	int nX ; # initialize a variable to indicate the number of contrast columns in X
	vector[nY] Y ; # initialize a vector to hold the observations
	matrix[nY,nX] X ; # initialize a matrix to hold contrasts
}
parameters {
	vector[nX] beta ; #vector for coefficients
	real<lower=0> sigma ; #SD of all data-generating populations, constrained to positive
}
model {
	beta[1] ~ normal(100,5) ; #prior on center-point
	for(nx in 2:nX){ #loop over non-intercept contrasts
		beta[nx] ~ normal(0,5) ; #prior on each of the contrasts
	}
	sigma ~ cauchy(0,15) ; #prior on sigma
	Y ~ normal( X*beta , sigma ) ; #sampling statement for data (note: must be order "X*beta"; "beta*X" won't work!)
}
