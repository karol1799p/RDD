//Tarea # 3 karol paez//
clear 
cd "C:\Users\Karol\Documents\GitHub\RDD"
use "C:\Users\Karol\Documents\GitHub\RDD\Data\hansen_dwi.dta", clear
br

*3.) CREATE A DUMMY VARIABLE FOR DIU 
gen DIU=0
replace DIU=1 if bac1>=0.08
tab DIU 

*4) TEST MANIPULATION 
*McCrary test 
DCdensity bac1, breakpoint(0.08) generate(Xj Yj r0 fhat se_fhat) graphname(DCdensity_test.eps)
*Calonico test 
net install rdrobust, from(https://sites.google.com/site/rdpackages/rdrobust/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity bac1, c(0.08) plot all
*histogram
hist bac1, width (0.0001) xline (0.08) xtitle("BAC") ytitle ("Frecuency") title ("BAC histogram") bcolor(gray)

*5.) BALANCE TEST 

gen BAC_D=(bac1*DIU)
xi: reg aged DIU bac1 BAC_D, r 
est store Age
xi: reg white DIU bac1 BAC_D, r
est store White
xi: reg male DIU bac1 BAC_D, r
est store Male

outreg2 [Male White Age] using balancetest.doc 
rename DIU DUI

*6.)PANELS 
ssc install cmogram
cmogram acc bac1, cut(0.08) scatter line(0.08) lfitci
cmogram male bac1 , cut(0.08) scatter line(0.08) lfitci
cmogram aged bac1 , cut(0.08) scatter line(0.08) lfitci
cmogram white bac1, cut(0.08) scatter line(0.08) lfitci

*7.) ESTIMATE EQUATION 1

*Panel A: bandwidth of 0.05
gen bac_s= bac1^2
xi: reg recidivism DUI bac1 $aged white male $year if bac1>0.03 & bac1<0.13, r
est store control
xi: reg recidivism DUI##c.bac1 $aged white male $year if bac1>0.03 & bac1<0.13, r
est store interact
xi: reg recidivism DUI##c.(bac1 bac_s) $aged white male $year if bac1>0.03 & bac1<0.13, r
est store squad

*Panel B: bandwidth of 0.025
xi: reg recidivism i.DUI bac1 $aged white male $year if bac1>0.055 & bac1<0.105, r
est store control2
xi: reg recidivism DUI##c.bac1 $aged white male $year if bac1>0.055 & bac1<0.105, r
est store interact2
xi: reg recidivism DUI##c.(bac1 bac_s) $aged white male $year if bac1>0.055 & bac1<0.105, r
est store squad2
outreg2 [control interact squad control2 interact2 squad2] using reg.doc, title("Table 2-Regression Discontinuity Estimates For The Effect of Exceeding The 0.08 BAC Threshold On Recidivism")

//8. TOP PANEL FIGURE 3 
cmogram recidivism bac1 if bac1<0.15, cut(0.08) scatter line(0.08) lfitci title("Panel A. All offenders") graphopts(xline(0.08) lc(black))



