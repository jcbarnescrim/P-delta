


* ------------------------------------------------------------------------------
* 							Perfect Relative Stability
*							No Absolute Stability n=10
* ------------------------------------------------------------------------------

drop _all



* ----------------
* generate 110 obs, N=10, waves=11
* ----------------

set obs 110
egen id = seq(),f(1) t(10)
sort id
bysort id: gen wave = _n-1

* generate y to have a predetermined correlation with x, 
* only distinction across ID is the intercept
* i.e., perfect RELATIVE stability
gen 	y = -5+(.3*wave) if id==1
replace y = -4+(.3*wave) if id==2
replace y = -3+(.3*wave) if id==3
replace y = -2+(.3*wave) if id==4
replace y = -1+(.3*wave) if id==5
replace y = 0+(.3*wave) if id==6
replace y = 1+(.3*wave) if id==7
replace y = 2+(.3*wave) if id==8
replace y = 3+(.3*wave) if id==9
replace y = 4+(.3*wave) if id==10

* show perfect relative stability
bysort id: cor y wave
bysort id: reg y wave

* Multi-level model for change, linear growth
xtmixed y wave || id: wave, mle cov(un)
estat icc
xtmrho

* plot
scatter y wave, ///
	msym(oh) mc(gs10) connect(L) lc(gs10) ///
	lpattern(longdash_dot) graphregion(color(white)) ///
	xlabel(0(1)10) ylabel(-6(4)8) ///
	xtitle("{bf:Time}",height(5)) ytitle("{bf:Y}",height(5)) ///
	title("{it:P} ({&Delta}) = 0.00",color(black)) ///
	name(stability, replace)
	
save "stabilitySimulation.dta", replace	
	
		
		
		
* ----------------
* run pDelta
* ----------------

capture program drop pdelta
capture program define pdelta

use "stabilitySimulation.dta", clear
quietly reshape wide y,i(id) j(wave)
quietly sample 2, count
foreach var of varlist y* {
	quietly egen rank`var'=rank(`var')
}
quietly gen crosspaths=0
quietly replace crosspaths=1 if 	(ranky1!=ranky2 | ///
									ranky2!=ranky3 | ///
									ranky3!=ranky4 | ///
									ranky4!=ranky5 | ///
									ranky5!=ranky6 | ///
									ranky6!=ranky7 | ///
									ranky7!=ranky8 | ///
									ranky8!=ranky9 | ///
									ranky9!=ranky10)
quietly sum crosspaths
end

* test with 1000 cases 
simulate probCross=r(max), reps(1000) seed(2217) : pdelta
sum	

* ------------------------------------------------------------------------------















































* ------------------------------------------------------------------------------
* 							No Relative Stability
*							No Absolute Stability n=10
* ------------------------------------------------------------------------------

drop _all



* ----------------
* generate 110 obs, N=10, waves=11
* ----------------

set obs 110
egen id = seq(),f(1) t(10)
sort id
bysort id: gen wave = _n-1

gen 	y = -5+(.99*wave) if id==1
replace y = -4+(.8*wave) if id==2
replace y = -3+(.6*wave) if id==3
replace y = -2+(.4*wave) if id==4
replace y = -1+(.2*wave) if id==5
replace y = 0+(0*wave) if id==6
replace y = 1+(-.2*wave) if id==7
replace y = 2+(-.4*wave) if id==8
replace y = 3+(-.6*wave) if id==9
replace y = 4+(-.8*wave) if id==10

/*
* generate a random variable to serve as the slope
set seed 2217
gen slope=rnormal() if wave==-5
bysort id: replace slope=slope[_n-1] if wave!=-5

* generate y to have a predetermined correlation with wave - the 'slope' 
* no relative stability (slopes are randomly drawn and will cross)
* different intercepts
* but wave and y are perfectly correlated
gen y = (slope*wave) 
*/

* show no relative stability
bysort id: cor y wave
bysort id: reg y wave

* Multi-level model for change, linear growth
xtmixed y wave || id: wave, mle cov(un)
estat icc
xtmrho

* plot
*replace wave=wave+5
scatter y wave, ///
	msym(oh)  mc(gs10) connect(L) lc(gs10) ///
	lpattern(longdash_dot) graphregion(color(white)) ///
	xlabel(0(1)10) ylabel(-8(4)8) ///
	xtitle("{bf:Time}",height(5)) ytitle("{bf:Y}",height(5)) ///
	title("{it:P} ({&Delta}) = 1.00",color(black)) ///
	name(nostability, replace)

save "noStabilitySimulation.dta",replace
	
		
		
		
* ----------------
* run pDelta
* ----------------

capture program drop pdelta
capture program define pdelta

use "nostabilitySimulation.dta", clear
quietly reshape wide y,i(id) j(wave)
quietly sample 2, count
foreach var of varlist y* {
	quietly egen rank`var'=rank(`var')
}
quietly gen crosspaths=0
quietly replace crosspaths=1 if 	(ranky1!=ranky2 | ///
									ranky2!=ranky3 | ///
									ranky3!=ranky4 | ///
									ranky4!=ranky5 | ///
									ranky5!=ranky6 | ///
									ranky6!=ranky7 | ///
									ranky7!=ranky8 | ///
									ranky8!=ranky9 | ///
									ranky9!=ranky10)
quietly sum crosspaths
end

* test with 1000 cases 
simulate probCross=r(max), reps(1000) seed(2217) : pdelta
sum	

* ------------------------------------------------------------------------------








































* ------------------------------------------------------------------------------
* 				Perfect Relative Stability for all but one case
*							No Absolute Stability n=10
* ------------------------------------------------------------------------------

drop _all




* ----------------
* generate 110 obs, N=10, waves=11
* ----------------

set obs 110
egen id = seq(),f(1) t(10)
sort id
bysort id: gen wave = _n-1

* generate y to have a predetermined correlation with x, 
* only distinction across ID is the intercept
* i.e., perfect RELATIVE stability
gen 	y = -5+(.3*wave) if id==1
replace y = -4+(.3*wave) if id==2
replace y = -3+(.3*wave) if id==3
replace y = -2+(.3*wave) if id==4
replace y = -1+(.3*wave) if id==5
replace y = 0+(.3*wave) if id==6
replace y = 1+(.3*wave) if id==7
replace y = 2+(.3*wave) if id==8
replace y = 3+(.3*wave) if id==9
replace y = 4+(-.7*wave) if id==10

* show perfect relative stability
bysort id: cor y wave
bysort id: reg y wave

* Multi-level model for change, linear growth
xtmixed y wave || id: wave, mle cov(un)
estat icc
xtmrho

* plot
scatter y wave, ///
	msym(oh) mc(gs10) connect(L) lc(gs10) ///
	lpattern(longdash_dot) graphregion(color(white)) ///
	xlabel(0(1)10) ylabel(-6(4)8) ///
	xtitle("{bf:Time}",height(5)) ytitle("{bf:Y}",height(5)) ///
	title("{it:P} ({&Delta}) = 0.22",color(black)) ///
	name(stabilityButOne, replace)
	
save "stabilitybutOneSimulation.dta", replace	
	
		
		
		
* ----------------
* run pDelta
* ----------------

capture program drop pdelta
capture program define pdelta

use "stabilitybutOneSimulation.dta", clear
quietly reshape wide y,i(id) j(wave)
quietly sample 2, count
foreach var of varlist y* {
	quietly egen rank`var'=rank(`var')
}
quietly gen crosspaths=0
quietly replace crosspaths=1 if 	(ranky1!=ranky2 | ///
									ranky2!=ranky3 | ///
									ranky3!=ranky4 | ///
									ranky4!=ranky5 | ///
									ranky5!=ranky6 | ///
									ranky6!=ranky7 | ///
									ranky7!=ranky8 | ///
									ranky8!=ranky9 | ///
									ranky9!=ranky10)
quietly sum crosspaths
end

* test with 1000 cases 
simulate probCross=r(max), reps(1000) seed(2217) : pdelta
sum	

* ------------------------------------------------------------------------------














































* ------------------------------------------------------------------------------
* 				Perfect Relative Stability for all but two cases
*							No Absolute Stability n=10
* ------------------------------------------------------------------------------

drop _all





* ----------------
* generate 110 obs, N=10, waves=11
* ----------------

set obs 110
egen id = seq(),f(1) t(10)
sort id
bysort id: gen wave = _n-1

* generate y to have a predetermined correlation with x, 
* only distinction across ID is the intercept
* i.e., perfect RELATIVE stability
gen 	y = -5+(1.3*wave) if id==1
replace y = -4+(.3*wave) if id==2
replace y = -3+(.3*wave) if id==3
replace y = -2+(.3*wave) if id==4
replace y = -1+(.3*wave) if id==5
replace y = 0+(.3*wave) if id==6
replace y = 1+(.3*wave) if id==7
replace y = 2+(.3*wave) if id==8
replace y = 3+(.3*wave) if id==9
replace y = 4+(-.7*wave) if id==10

* show perfect relative stability
bysort id: cor y wave
bysort id: reg y wave

* Multi-level model for change, linear growth
xtmixed y wave || id: wave, mle cov(un)
estat icc
xtmrho

* plot
scatter y wave, ///
	msym(oh) mc(gs10) connect(L) lc(gs10) ///
	lpattern(longdash_dot) graphregion(color(white)) ///
	xlabel(0(1)10) ylabel(-6(4)8) ///
	xtitle("{bf:Time}",height(5)) ytitle("{bf:Y}",height(5)) ///
	title("{it:P} ({&Delta}) = 0.39",color(black)) ///
	name(stabilityButTwo, replace)

gr combine stability nostability stabilityButOne stabilityButTwo, graphregion(color(white))
graph export "StabilitySimulation.pdf", replace
	
save "stabilitybutTwoSimulation.dta", replace	

		
		
		
* ----------------
* run pDelta
* ----------------

capture program drop pdelta
capture program define pdelta

use "stabilitybutTwoSimulation.dta", clear
quietly reshape wide y,i(id) j(wave)
quietly sample 2, count
foreach var of varlist y* {
	quietly egen rank`var'=rank(`var')
}
quietly gen crosspaths=0
quietly replace crosspaths=1 if 	(ranky1!=ranky2 | ///
									ranky2!=ranky3 | ///
									ranky3!=ranky4 | ///
									ranky4!=ranky5 | ///
									ranky5!=ranky6 | ///
									ranky6!=ranky7 | ///
									ranky7!=ranky8 | ///
									ranky8!=ranky9 | ///
									ranky9!=ranky10)
quietly sum crosspaths
end

* test with 1000 cases 
simulate probCross=r(max), reps(1000) seed(2217) : pdelta
sum	

* ------------------------------------------------------------------------------

	
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

* ------------------------------------------------------------------------------
* 				Perfect Relative Stability for all but two cases
*							No Absolute Stability  n=40
* ------------------------------------------------------------------------------

drop _all

* generate 4400 obs, N=40, waves=11
set obs 440
egen id = seq(),f(1) t(40)
sort id
bysort id: gen wave = _n-1

* generate y to have a predetermined correlation with x, 
* only distinction across ID is the intercept
* i.e., perfect RELATIVE stability
gen 	y = -5+(1.3*wave) 	if id==1
replace y = -4.75+(.3*wave) if id==2
replace y = -4.5+(.3*wave) 	if id==3
replace y = -4.25+(.3*wave) if id==4
replace y = -4+(.3*wave) 	if id==5
replace y = -3.75+(.3*wave)	if id==6
replace y = -3.5+(.3*wave) 	if id==7
replace y = -3.25+(.3*wave) if id==8
replace y = -3+(.3*wave) 	if id==9
replace y = -2.75+(.3*wave) if id==10
replace y = -2.5+(.3*wave) 	if id==11
replace y = -2.25+(.3*wave) if id==12
replace y = -2+(.3*wave) 	if id==13
replace y = -1.75+(.3*wave) if id==14
replace y = -1.5+(.3*wave) 	if id==15
replace y = -1.25+(.3*wave) if id==16
replace y = -1+(.3*wave) 	if id==17
replace y = -0.75+(.3*wave) if id==18
replace y = -0.5+(.3*wave) 	if id==19
replace y = -0.25+(.3*wave) if id==20
replace y = 0+(.3*wave) 	if id==21
replace y = 0.25+(.3*wave) 	if id==22
replace y = 0.5+(.3*wave) 	if id==23
replace y = 0.75+(.3*wave) 	if id==24
replace y = 1+(.3*wave) 	if id==25
replace y = 1.25+(.3*wave) 	if id==26
replace y = 1.5+(.3*wave) 	if id==27
replace y = 1.75+(.3*wave) 	if id==28
replace y = 2+(.3*wave) 	if id==29
replace y = 2.25+(.3*wave) 	if id==30
replace y = 2.5+(.3*wave) 	if id==31
replace y = 2.75+(.3*wave) 	if id==32
replace y = 3+(.3*wave) 	if id==33
replace y = 3.25+(.3*wave) 	if id==34
replace y = 3.5+(.3*wave) 	if id==35
replace y = 3.75+(.3*wave) 	if id==36
replace y = 4+(.3*wave) 	if id==37
replace y = 4.25+(.3*wave) if id==38
replace y = 4.5+(.3*wave) 	if id==39
replace y = 4.75+(-.7*wave)	if id==40

* show perfect relative stability
bysort id: cor y wave
bysort id: reg y wave

* Multi-level model for change, linear growth
xtmixed y wave || id: wave, mle cov(un)
estat icc
xtmrho

* plot
scatter y wave, ///
	msym(oh) mc(gs10) connect(L) lc(gs10) ///
	lpattern(longdash_dot) graphregion(color(white)) ///
	xlabel(0(1)10) ylabel(-6(4)8) ///
	xtitle("{bf:Time}",height(5)) ytitle("{bf:Y}",height(5)) ///
	title("{bf:Relative Stability Except for Two}",color(black)) ///
	name(stabilityN40, replace)
graph export "StabilitybutTwoSimulationN40.pdf", replace
save "stabilitybutTwoSimulationN40.dta", replace	
	


	
		
* ----------------
* run pDelta
* ----------------

capture program drop pdelta
capture program define pdelta

use "stabilitybutTwoSimulationN40.dta", clear
quietly reshape wide y,i(id) j(wave)
quietly sample 2, count
foreach var of varlist y* {
	quietly egen rank`var'=rank(`var')
}
quietly gen crosspaths=0
quietly replace crosspaths=1 if 	(ranky1!=ranky2 | ///
									ranky2!=ranky3 | ///
									ranky3!=ranky4 | ///
									ranky4!=ranky5 | ///
									ranky5!=ranky6 | ///
									ranky6!=ranky7 | ///
									ranky7!=ranky8 | ///
									ranky8!=ranky9 | ///
									ranky9!=ranky10)
quietly sum crosspaths
end

* test with 1000 cases 
simulate probCross=r(max), reps(1000) seed(2217) : pdelta
sum	
* ------------------------------------------------------------------------------

