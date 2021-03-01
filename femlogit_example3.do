*! version 1.0.0 11Nov2013 femlogit example 3
clear *
capture log close
set more off
set linesize 79
set scheme sj
version 13.0


sjlog using "femlogit_example3", replace

* Smoking-birthweight data
*
* from
*
* Rabe-Hesketh, S., & Skrondal, A. (2012). Multilevel and longitudinal modeling
*   using Stata (3. ed, Vol. 2). College Station, Tex: Stata Press, p.61f..
*
* taken from
*
* Abrevaya, J. (2006). Estimating the effect of smoking on birth outcomes using
* a matched panel data approach. Journal of Applied Econometrics, 21(4), 489–519.
* 
* More information at http://qed.econ.queensu.ca/jae/datasets/abrevaya001/

use momid idx gestat year kessner2 kessner3 smoke novisit black married hsgrad /*
*/ somecoll collgrad using "http://www.stata-press.com/data/mlmus3/smoking.dta"

* Generate discrete dependent variable of preterm, term, and postterm birth
* from continuous variable length of gestation (in weeks)
* following WHO-Defintion (ICD10, p.151)
* http://www.who.int/classifications/icd/ICD10Volume2_en_2010.pdf
* preterm 36w6d <37w
* term >=37w <42w
* postterm >=42w
gen gestage=.
replace gestage=1 if gestat>0 & gestat<37
replace gestage=2 if gestat>=37 & gestat<42
replace gestage=3 if gestat>=42 & gestat<.

* Dummies for year of birth
quietly tab year, gen(y)

* Kessner1
gen kessner1=kessner2==0 & kessner3==0 if kessner2!=. & kessner3!=.

* Keep relevant variables
keep gestage smoke kessner1 novisit y1-y8 black married hsgrad somecoll /*
*/ collgrad momid idx
compress

* Labels
label var momid "Mother id"
label var idx "Child number"
label var gestage "Categorial gestation age at birth"
label def gestage 1 "pre-term" 2 "full term" 3 "post-term"
label val gestage gestage
label var smoke "Smoke"
label var kessner1 "Adequate prenatal care (Kessner index)"
label var novisit "No prenatal visit to doctor"
label var y1 "1990 birth cohort"
label var y2 "1991 birth cohort"
label var y3 "1992 birth cohort"
label var y4 "1993 birth cohort"
label var y5 "1994 birth cohort"
label var y6 "1995 birth cohort"
label var y7 "1996 birth cohort"
label var y8 "1997 birth cohort"
label var black "African-American"
label var married "Married"
label var hsgrad "12 years of education"
label var somecoll "13-15 years of education"
label var collgrad "16+ years of education"

* Describe data
des
xtset momid idx
xtdes

* Models
mlogit gestage smoke kessner1 novisit y1-y8 black married hsgrad somecoll /*
*/ collgrad, b(2) vce(cluster momid)
estimates store mlogit

femlogit gestage smoke kessner1 novisit y1-y8, /*
*/ b(2) group(momid) difficult
estimates store femlogit

* random effects
gsem (1.gestage <- smoke kessner1 novisit y1-y8 black married hsgrad somecoll /*
*/  collgrad M1[momid]) (3.gestage  <- smoke kessner1 novisit y1-y8 black /*
*/ married hsgrad somecoll collgrad M3[momid]), mlogit
estimates store remlogit
sjlog close, replace

* Raw version of Latex-table (needs post-processing)
log using "femlogit_example3_2.log", replace
* estout (version 3.13 06aug2009) modified to process gsem-results with other models
* prefixed "version 12:" in line 2691 (taken from est_table.ado (version 1.3.1 15jan2013))
estout mlogit remlogit femlogit, equation(1:1:1,3:3:2) /*
*/ keep(#1:smoke #1:kessner1 #1:novisit #1:black #1:married #1:hsgrad /*
*/ #1:somecoll #1:collgrad #1:_cons #2:smoke #2:kessner1 #2:novisit #2:black /*
*/ #2:married #2:hsgrad #2:somecoll #2:collgrad #2:_cons  var*: cov*:, relax) /*
*/ cells(b(star fmt(3) /*
*/ vacant("\multicolumn{2}{c}{}")) se(fmt(3) par /*
*/ vacant("\multicolumn{2}{c}{}"))) /*
*/ transform(#1: exp(@) exp(@) #2: exp(@) exp(@)) stats(ll N, fmt(3 0) /*
*/ layout(@ @)) style(tex) dmarker("&")

log close
exit
