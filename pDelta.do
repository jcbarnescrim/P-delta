
set more off
cd "USER/PATH"
capture log using "pDelta/pdelta.smcl", replace

use "data.dta",clear
quietly keep CASEID S*IMPULS

* drop cases with any missing data so that only complete cases are analyzed
quietly drop if S0IMPULS==. | S1IMPULS==. | S2IMPULS==. | S3IMPULS==. | S4IMPULS==. | ///
		S5IMPULS==. | S6IMPULS==. | S7IMPULS==. | S8IMPULS==. | S9IMPULS==. | ///
		S10IMPULS==. 

* -------------------------
* Christensen & Mendoza's RCI
* where RCI = (t2-t1)/sdiff
* note, numerator is the diff in score between two measurement periods
* denominator is standard error of measurement (SEM), 
* which accounts for measurement error (i.e., alpha reliability)
* -------------------------

* gen variables holding info needed for denominator
foreach var of varlist S*IMPULS {
quietly sum `var'
quietly gen sd`var'=`r(sd)'
}
capture gen alpha0=.76
capture gen alpha1=.78
capture gen alpha2=.79
capture gen alpha3=.81
capture gen alpha4=.80
capture gen alpha5=.80
capture gen alpha6=.82
capture gen alpha7=.81
capture gen alpha8=.82
capture gen alpha9=.84
capture gen alpha10=.84

* calculate the RCI for each wave-to-wave comparison
* w1-w0
gen RCI_1_0=(S1IMPULS-S0IMPULS)/sqrt([sdS1IMPULS*sqrt(1-alpha1)]^2+[sdS0IMPULS*sqrt(1-alpha0)]^2)
sum RCI_1_0, d

* w2-w1
gen RCI_2_1=(S2IMPULS-S1IMPULS)/sqrt([sdS2IMPULS*sqrt(1-alpha2)]^2+[sdS1IMPULS*sqrt(1-alpha1)]^2)
sum RCI_2_1, d

* w3-w2
gen RCI_3_2=(S3IMPULS-S2IMPULS)/sqrt([sdS3IMPULS*sqrt(1-alpha3)]^2+[sdS2IMPULS*sqrt(1-alpha2)]^2)
sum RCI_3_2, d

* w4-w3
gen RCI_4_3=(S4IMPULS-S3IMPULS)/sqrt([sdS4IMPULS*sqrt(1-alpha4)]^2+[sdS3IMPULS*sqrt(1-alpha3)]^2)
sum RCI_4_3, d

* w5-w4
gen RCI_5_4=(S5IMPULS-S4IMPULS)/sqrt([sdS5IMPULS*sqrt(1-alpha5)]^2+[sdS4IMPULS*sqrt(1-alpha4)]^2)
sum RCI_5_4, d

* w6-w5
gen RCI_6_5=(S6IMPULS-S5IMPULS)/sqrt([sdS6IMPULS*sqrt(1-alpha6)]^2+[sdS5IMPULS*sqrt(1-alpha5)]^2)
sum RCI_6_5, d

* w7-w6
gen RCI_7_6=(S7IMPULS-S6IMPULS)/sqrt([sdS7IMPULS*sqrt(1-alpha7)]^2+[sdS6IMPULS*sqrt(1-alpha6)]^2)
sum RCI_7_6, d

* w8-w7
gen RCI_8_7=(S8IMPULS-S7IMPULS)/sqrt([sdS8IMPULS*sqrt(1-alpha8)]^2+[sdS7IMPULS*sqrt(1-alpha7)]^2)
sum RCI_8_7, d

* w9-w8
gen RCI_9_8=(S9IMPULS-S8IMPULS)/sqrt([sdS9IMPULS*sqrt(1-alpha9)]^2+[sdS8IMPULS*sqrt(1-alpha8)]^2)
sum RCI_9_8, d

* w10-w9
gen RCI_10_9=(S10IMPULS-S9IMPULS)/sqrt([sdS10IMPULS*sqrt(1-alpha10)]^2+[sdS9IMPULS*sqrt(1-alpha9)]^2)
sum RCI_10_9, d

sum RCI*,d
centile  RCI*, centile(2.5 97.5)

* save data w/RCI values stored
save "_pDeltaData.dta",replace




* -------------------------
* write pDelta program
* -------------------------

drop _all
capture program drop pdelta
capture program define pdelta

* open data file
quietly use "_pDeltaData.dta",clear

* sample 2 cases at random
quietly sample 2, count

* look for reliable changes first, must first generate new variable to id reliable changes
foreach var of varlist RCI_1_0 - RCI_10_9 {
quietly gen `var'reliableChange=0
}

* "tag" reliable changes for case 1
foreach var of varlist RCI_1_0 - RCI_10_9 {
replace `var'reliableChange=1 if `var' >=abs(1.96) in 1
} 

* "tag" reliable changes for case 2
foreach var of varlist RCI_1_0 - RCI_10_9 {
replace `var'reliableChange=1 if `var' >=abs(1.96) in 2
} 

* code rankings at baseline
quietly egen rankBaseline=rank(S0IMPULS)

* now, generate rankings at all other waves, but only 
* allow rankings to change from previous wave if reliable changes were observed
* w1-w0
quietly egen rank1 		= rank(S1IMPULS) 	if RCI_1_0reliableChange==1
quietly replace rank1 	= rankBaseline 		if RCI_1_0reliableChange==0
* w2-w1
quietly egen rank2 		= rank(S2IMPULS) 	if RCI_2_1reliableChange==1
quietly replace rank2 	= rank1 			if RCI_2_1reliableChange==0
* w3-w2
quietly egen rank3 		= rank(S3IMPULS) 	if RCI_3_2reliableChange==1
quietly replace rank3 	= rank2 			if RCI_3_2reliableChange==0
* w4-w3
quietly egen rank4 		= rank(S4IMPULS) 	if RCI_4_3reliableChange==1
quietly replace rank4 	= rank3 			if RCI_4_3reliableChange==0
* w5-w4
quietly egen rank5 		= rank(S5IMPULS) 	if RCI_5_4reliableChange==1
quietly replace rank5 	= rank4 			if RCI_5_4reliableChange==0
* w6-w5
quietly egen rank6 		= rank(S6IMPULS) 	if RCI_6_5reliableChange==1
quietly replace rank6 	= rank5 			if RCI_6_5reliableChange==0
* w7-w6
quietly egen rank7 		= rank(S7IMPULS) 	if RCI_7_6reliableChange==1
quietly replace rank7 	= rank6 			if RCI_7_6reliableChange==0
* w8-w7
quietly egen rank8 		= rank(S8IMPULS) 	if RCI_8_7reliableChange==1
quietly replace rank8 	= rank7 			if RCI_8_7reliableChange==0
* w9-w8
quietly egen rank9		= rank(S9IMPULS) 	if RCI_9_8reliableChange==1
quietly replace rank9 	= rank8 			if RCI_9_8reliableChange==0
* w10-w9
quietly egen rank10 	= rank(S10IMPULS) 	if RCI_10_9reliableChange==1
quietly replace rank10 	= rank9 			if RCI_10_9reliableChange==0


* finally, tabulate whether the two cases ever change rankings
quietly gen rankChange=0
quietly replace rankChange = 1	///
	if (						///
	rankBaseline != rank1 | 	///
	rank1 != rank2 | 			///
	rank2 != rank3 | 			///
	rank3 != rank4 | 			///
	rank4 != rank5 | 			///
	rank5 != rank6 | 			///
	rank6 != rank7 | 			///
	rank7 != rank8 | 			///
	rank8 != rank9 | 			///
	rank9 != rank10 )

quietly sum rankChange
end



* test with 300 cases first
*simulate pDelta=r(max), reps(300) seed(2217) : pdelta
*sum 
*capture log close

* up the reps for "full" model
simulate pDelta=r(max), reps(35000) seed(2217) : pdelta
sum
capture log close
* ------------------------------------------------------------------------------
