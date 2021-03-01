*! version 1.0.0 11Nov2013 femlogit example 2
clear all
set more off
set linesize 79

* British election data
*
* from
*
* Rabe-Hesketh, S., & Skrondal, A. (2012). Multilevel and longitudinal modeling
*   using Stata (3. ed, Vol. 2). College Station, Tex: Stata Press, p.680f..
*
* taken from
*
* Heath, A. F., Jowell, R. M., Curtice, J. K., Brand, J. A., & Mitchell, J. C. 
*   (1993). British General Election Panel Survey, 1987-1992. Arbor, MI: Inter-
*   university Consortium for Political and Social Research.
*
* Skrondal, A., & Rabe-Hesketh, S. (2003). Multilevel logistic regression for
*   polytomous data and rankings. Psychometrika, 68(2), 267–287.
*   doi:10.1007/BF02294801  

use occ serialno party rank rldist yr87 yr92 male age manual inflation /*
*/ using "http://www.stata-press.com/data/mlmus3/elections.dta"

* Reshape wide:
* Cases are alternatives within persons within elections
* ->
* Cases are persons within elections
reshape i serialno occ
reshape j party
reshape xij rank rldist
reshape wide

* Dependent variable: Vote for party
gen choice=.
forvalues j=1/3 {
  replace choice=`j' if rank`j'==1
}
drop rank*

* Generate relative difference for alternative specific variable rldist
* to basecategory
replace rldist2=rldist2-rldist1
replace rldist3=rldist3-rldist1

* Keep relevant variables
keep choice rldist2 rldist3 inflation yr92 male age manual serialno
compress

* Labels
label var choice "Recalled vote for party"
label def choice 1 "Conservative" 2 "Labour" 3 "Liberal"
label val choice choice
label var rldist2 "Dist(Labour)-Dist(Conservative)"
label var rldist3 "Dist(Liberal)-Dist(Conservative)"
label var inflation "Perceived inflation"
label var yr92 "1992 election indicator"
label var male "Male"
label var age "Age in 10 yr units"
label var manual "Manual worker"
label var serialno "Respondent number"

* Describe data
sjlog using femlogit2, replace
describe
sjlog close, replace
sjlog using femlogit3, replace
xtset serialno yr92
xtdes
sjlog close, replace

* Constraints
constraint 1 [Labour]rldist3=0
constraint 2 [Liberal]rldist2=0
constraint 3 [Labour]rldist2=[Liberal]rldist3
constraint 4 _b[2.choice:rldist3]=0
constraint 5 _b[3.choice:rldist2]=0
constraint 6 _b[2.choice:rldist2]-_b[3.choice:rldist3]=0

* Models
* femlogit
sjlog using femlogit4, replace
femlogit choice rldist2 rldist3 inflation yr92, group(serialno) const(1/3) b(1)
sjlog close, replace
estimates store femlogit
* pooled
mlogit choice rldist2 rldist3 inflation yr92 male age manual, const(1/3) b(1) /*
*/ vce(cluster serialno)
estimates store mlogit
* random effects
gsem (2.choice <- rldist2 rldist3 inflation yr92 male age manual /*
*/ M1[serialno]) (3.choice <- rldist2 rldist3 inflation yr92 male /*
*/ age manual M2[serialno]), mlogit const(4/6)
estimates store remlogit

* Raw version of Latex-table (needs post-processing)
log using "femlogit_example2_2.log", replace
* estout (version 3.13 06aug2009) modified to process gsem-results with other models
* prefixed "version 12:" in line 2691 (taken from est_table.ado (version 1.3.1 15jan2013))
estout mlogit remlogit femlogit, equation(2:2:1,3:3:2) /*
*/ keep(#1:rldist2 #1:inflation #1:yr92 #1:male #1:age #1:manual #1:_cons /*
*/ #2:rldist3 #2:inflation #2:yr92 #2:male #2:age #2:manual #2:_cons /*
*/ var*: cov*:, relax) cells(b(star fmt(3) vacant("\multicolumn{2}{c}{}")) /*
*/ se(fmt(3) par  vacant("\multicolumn{2}{c}{}"))) /*
*/ transform(#1: exp(@) exp(@) #2: exp(@) exp(@)) stats(ll N, fmt(3 0) /*
*/ layout(@ @)) style(tex) dmarker("&")
log close
