/*

This file calls 00_simulateData

*Things to do:

*if no error then store.
*generate y_i as a flexible beta distribution function


*setup dlr test "double length" to test different models. 

*/

clear 
set more off


global path ""
global table_path "./table" 


capture program drop logoneplus 
  do logoneplus 



*-----------------------------------------------------------------------------*
*           Generate matrix to keep track of results 
*-----------------------------------------------------------------------------*
 *reset file to save results in
	use coef_boot, clear
	save coef_results, replace
	
*set up file for simulation	
	clear
	set obs 1000

*-----------------------------------------------------------------------------*
*           Generate independent variables 
*-----------------------------------------------------------------------------*

		gen x1 = (rnormal() + 10)
		gen index = _n
		gen k1 = index + x1
		save k, replace
		

*-----------------------------------------------------------------------------*
*           Generate dependent variables
*-----------------------------------------------------------------------------*	
	forvalues i = 1(1)100 {
	 
	 cap clear mat eresults
	 
	
	cap drop y_i k logy y_logplus y_ihs y_doubleneg
	
	*generate y by exponentiating the log function	
		gen k = `i' + x1
		gen y_i = rgamma(k, 1)
	
	

	
*-----------------------------------------------------------------------------*
*           Call program logoneplus
*-----------------------------------------------------------------------------*	
	
	*give the program the dependent variable and any list of independent variables
		logoneplus y_i x1 
 
	preserve	
		mat model = eresults'
		svmat model
		keep model*
		gen model_type = `i'
	
		keep if _n ==1
		append using coef_results
 
		save coef_results, replace
	restore
	}
	 
	 use coef_results, clear


save coef_results_1, replace
	 
*merge dataset

gen index= _n

merge 1:1 index using "k.dta"

keep if _merge==3

save coef_results_1, replace

*graphing

forvalues i = 1(1)5 {

twoway line model`i' k1

save "model`i'.gph", replace

}

graph combine model1.gph model2.gph model3.gph model4.gph model5.gph

twoway line model1 model2 model3 model4 model5 k1




	 
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
	
		
	
	 

		

		
	
