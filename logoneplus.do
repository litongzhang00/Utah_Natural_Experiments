/*

This file simulates data to be used in our tests of different methods. 

1) quantile regressions
2) IHS log(y_i + (y_i^2 + 1)^(1/2))
3) Power laws
4) Tobit
5) generate double neglog_y = sign(level) * log(1 + abs(level))
6) log(1 + y)
7) poisson

*/


program logoneplus
	version 10.1
	syntax varlist [if] [in] [, robust]
	
	*Separate the d.v. from i.v.(s).
		gettoken y_i covars : varlist


 
 
 

 
*-----------------------------------------------------------------------------*
*           Generate variables 
*-----------------------------------------------------------------------------*

*log y_i
	gen logy = log(y_i)

*log(1 + y_i)
	gen y_logplus = log(y_i + 1)

*inverse hyperbolic sine transformation
	gen y_ihs = log(y_i + (y_i^2 + 1)^(1/2))
	
*double negative log y_i
	gen y_doubleneg = sign(y_i) * log(1 + abs(y_i))
	
*power law
// 	*generate polynomials as explanatory variables
// 		qui orthpoly `copy' if `touse' & `trunc' == 1 , generate(`y_i_list') deg(`polorder')
//		
*-----------------------------------------------------------------------------*
*           Run specifications
*-----------------------------------------------------------------------------*

*levels
	cap reg y_i `covars'
	est sto A

*logs
	cap reg logy `covars' 
	est sto B	

*log(1 + y_i)
	cap reg y_logplus `covars'
	est sto C
	
*tobit 
	cap tobit logy `covars' , ll(0) 
	est sto D
	
*inverse hyperbolic sine transormation
	cap reg y_ihs `covars'
	est sto E
	
*poisson ---advanced program poi2hdfe
	cap poisson y_i `covars' 
	est sto F
	
*double negative log y_i 
	*cap reg y_doubleneg `covars'
	*est sto E
	
// *quantile regression
// 	cap qreg y_i `covars'
// 	cap est sto D
	
*power law	
	
	
		
		
	#delimit ;
 		estout1 A B C D E F using "$table_path\table.tex" , style(tex) se(par) conslbl("Constant")  
		stats(F r2 N) stlabels("F-statistic" "R-Square" "Observations") stfmt(%9.3f %9.3f %9.0fc %9.0fc)
		star(0.10 0.05 0.01) label replace  
		;
		
		
	#delimit cr	
end
//mlabels("Levels" "Logs" "Log(1+y)" "Tobit" "IHS")
