/*

This file simulates a gamma distribution with covariates

*/

clear
set more off

set obs 10000


/*
The gamma distribution is parameterized by the shape parameter a=k and scale parameter b. 

The mean of the gamma distribution is given by a*b

skewness is 2/sqrt(a) and therefore decreases with a. 
*/

*generate covariates
	gen x1 = runiform()
	gen x2 = runiform()


*shape parameter, which determines skewness
	scalar a = 0.1
	
*scale parameter---differs for each observation, causing them the have different means
	*gen b = 10 + 4*x1 + 2*x2
	*sum b
	*scalar scalar_b = r(mean)
	
	scalar b = 4

gen Y = -10 + 4*x1 + 2*x2 + rgamma(a,b)

sum Y, d

di `=a'*`=scalar_b'

kdensity Y

reg Y x1 x2

gen logy = log(Y)

reg logy x1 x2