#three groups
data {
	int nY ; # initialize a variable to indicate the number of elements in Y
	vector[nY] Y ; # initialize a vector to hold the observations
	vector[nY] contrast1 ; # initialize a vector to hold contrast1
	vector[nY] contrast2 ; # initialize a vector to hold contrast2
}
parameters {
	real mu ; #center-point between data-generating populations' means
	real diff1 ; #group1 vs group2
	real diff2 ; #(group1 + group2)/2 vs group3
	real<lower=0> sigma ; #SD of all data-generating populations, constrained to positive
}
model {
	mu ~ normal(100,5) ; #prior on center-point
	diff1 ~ normal(0,5) ; #prior on diff1
	diff2 ~ normal(0,5) ; #prior on diff2
	sigma ~ cauchy(0,15) ; #prior on sigma
	Y ~ normal(mu+diff1*contrast1+diff2*contrast2,sigma) ; #sampling statement for data
}
