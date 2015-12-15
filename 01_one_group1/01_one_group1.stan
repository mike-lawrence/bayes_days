#one group, known error variance
data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	vector[nY] Y ; # initialize a vector to hold the observations
}
parameters {
	real mu ; #mean of the data-generating population
}
model {
	mu ~ normal(100,20) ; #prior on mu
	Y ~ normal(mu,15) ; #sampling statement for data
}
