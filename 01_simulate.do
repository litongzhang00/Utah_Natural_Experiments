/*

This file calls 00_simulateData

*Things to do:

*if no error then store.
*generate y_i as a flexible beta distribution function


*setup dlr test "double length" to test different models. 

*/

clear 
set more off

cap global path "C:\Users\u0908787\Dropbox\Research Projects\r\RinggenbergSeegert\code"
cap global table_path "C:\Users\u0908787\Dropbox\Research Projects\r\RinggenbergSeegert\table"
cap cd "C:\Users\u0908787\Dropbox\Research Projects\r\RinggenbergSeegert\code"


cap global path "F:\Dropbox\Research Projects\r\RinggenbergSeegert\code"
cap global table_path "F:\Dropbox\Research Projects\r\RinggenbergSeegert\table"
cap cd "F:\Dropbox\Research Projects\r\RinggenbergSeegert\code"

capture program drop logoneplus
  do logoneplus

set obs 100000

*-----------------------------------------------------------------------------*
*           Generate independent variables 
*-----------------------------------------------------------------------------*
		gen x1 = (rnormal() + 10)
		gen x2 = (rnormal() + 10)
		gen bx3 = (rnormal() + 10)
		gen eps = 0.01*rnormal()

*-----------------------------------------------------------------------------*
*           Generate dependent variables
*-----------------------------------------------------------------------------*		
	*generate y by exponentiating the log function	
		gen logy = 2 + 4*x1 + 6*x2 + eps
		gen y_i = exp(logy)
		drop logy
	*generate y as the multiplication of independent variables		
		*gen y_i = 2*(exp(x1)^4)*(exp(x2)^6)*eps
	
	*generate y_i as a linear function
		*gen y_i = 2 + 4*x1 + 6*x2 + eps

	
*-----------------------------------------------------------------------------*
*           Call program logoneplus
*-----------------------------------------------------------------------------*	
	
	*give the program the dependent variable and any list of independent variables
		logoneplus y_i x1 x2 


		
stop		
*-----------------------------------------------------------------------------*
*          Try power expansion
*-----------------------------------------------------------------------------*	
	local covars x1 x2
	local polyorder 2
	local covars2 
// 	foreach var in `covars' {
// 		qui orthpoly `var' , generate(`var'_*) deg(`polorder')
// 		local covars2 `covars2' `var'_1 `var'_2
// 	}

	*generate polynomials 
		foreach var in `covars'  {
			forvalues i = 1(1)`polyorder' {
				gen `var'_`i' = `var'^`i'
				local covars2 `covars2' `var'_`i'		// save local of all new variables
			}

		}

		
	*generate interactions of variables
		geninteract `covars2'
		
		local covars3 x1_1 x1_2 x2_1 x2_2  ///
		x1_1_x1_2 x1_1_x2_1 x1_1_x2_2 ///
		x1_2_x2_1 x1_2_x2_2 x2_1_x2_2
		
	*generate averages 
		foreach var in `covars3' {
			sum `var', meanonly
			scalar sc_`var' = r(mean)
		}
		
		 sum y_i
		 scalar sc_y_i = r(mean)
		
	*regression
		reg y_i `covars3' 
		
	*calculate effects
		nlcom (_b[x1_1] +  2*_b[x1_2]*sc_x1_1	+ 3*_b[x1_1_x1_2]*sc_x1_2 ///
		+ _b[x1_1_x2_1]*sc_x2_1 + _b[x1_1_x2_2]*sc_x2_2 ///
		+ 2*_b[x1_2_x2_1]*sc_x1_1*sc_x2_1 + 2*b[x1_2_x2_2]*sc_x1_1*sc_x2_2)/sc_y_i
	
		
	
	 

		

		
	