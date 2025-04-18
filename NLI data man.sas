/****************************************************************************************
* PROJECT       : 	NatureIndex_Nature
*****************************************************************************************/



option nofmterr;

proc datasets library=work kill;
run;
quit;


/*************************************************************************************/


PROC IMPORT DATAFILE= "\\ad.bu.edu\bumcfiles\SPH\Projects\SC\06Methods_and_Specifications\05CWBI2020\Internal\03Analytic\ModeAdj_Scoring_Ranks\Brochu\11202024\Nature_Disparities.xlsx" 
OUT= Nature_Disparities
DBMS=XLSX
REPLACE;
GETNAMES=YES;
RUN; /*N=1561*/

proc contents data=Nature_Disparities; run;

/*************************************************************************************/

PROC IMPORT DATAFILE= "\\ad.bu.edu\bumcfiles\SPH\Projects\SC\06Methods_and_Specifications\05CWBI2020\Internal\03Analytic\ModeAdj_Scoring_Ranks\Brochu\11202024\LST2019_Nature_Tracts_Cleaned.csv" 
OUT= Nature_Disparities_Cleaned
DBMS=csv
REPLACE;
GETNAMES=YES;
RUN; /*N=538*/

proc means data=Nature_Disparities_Cleaned n nmiss mean std min max; var
m7_f1 m7_f2 m7_f3 M7_NatureI lst_meanc lst_maxc;
run;

/*
confirm the natural index variables

data tmp_; set tmp;
f1=NDVI2019_500m+PCT_OS+INV_PCT_IMP_2016+PCT_TC+CropCnt; 
f2=NPARKS_16KM+INV_DIST_PARK_M+PctAccess402m_Parks;      
f3=INV_DIST_BLUE_M+PCT_Water+PctAccess402m_BlueSpace;    
f=NDVI2019_500m+PCT_OS+INV_PCT_IMP_2016+PCT_TC+CropCnt+
NPARKS_16KM+INV_DIST_PARK_M+PctAccess402m_Parks+
INV_DIST_BLUE_M+PCT_Water+PctAccess402m_BlueSpace;       
run;

proc means data=tmp_; var f1 f2 f3 f ; run;

(greenness)
(park)
(bluespace)
(natural index)
*/

data Nature_Disparities_Cleaned_; 
label m7_f1="Greenness"
m7_f2="Park"
m7_f3="Bluespace"
M7_NatureI="Natural Index";
set Nature_Disparities_Cleaned;
m7_=m7_f1+m7_f2+m7_f3;
if NDVI2019_5=. then delete;
run; /*N=526*/

data Nature_Disparities_Cleaned_1; set Nature_Disparities_Cleaned_;
array x1(*) NDVI2019_5 PCT_OS INV_PCT_IM	PCT_TC	CropCnt;
array x2(*) NPARKS_16K INV_DIST_P PctAccess4;
array x3(*) INV_DIST_B	PCT_Water PctAcces_1;
f1=mean(of x1(*));
f2=mean(of x2(*));
f3=mean(of x3(*));
run;

/*confirm the same varibale used in total scores*/
proc corr data=Nature_Disparities_Cleaned_1; var f1 f2 f3; 
with m7_f1 m7_f2 m7_f3;
run;

proc corr data=Nature_Disparities_Cleaned_1 alpha;
var NDVI2019_5 PCT_OS INV_PCT_IM	PCT_TC	CropCnt;
run;/*alpha=0.85 green*/
proc corr data=Nature_Disparities_Cleaned_1 alpha;
var NPARKS_16K INV_DIST_P PctAccess4;
run;/*alpha=0.77 park*/
proc corr data=Nature_Disparities_Cleaned_1 alpha;
var INV_DIST_B	PCT_Water PctAcces_1;
run;/*alpha=0.72 blue*/
proc corr data=Nature_Disparities_Cleaned_1 alpha;
var
NDVI2019_5 PCT_OS INV_PCT_IM	PCT_TC	CropCnt 
NPARKS_16K INV_DIST_P PctAccess4
INV_DIST_B	PCT_Water PctAcces_1;
run;/*alpha=0.56*/

/*table X, the numbers are exact the same*/

proc means data=Nature_Disparities_Cleaned_ n nmiss mean std min max; var
m7_f1 m7_f2 m7_f3 M7_NatureI lst_meanc lst_maxc;
run;

/*table 2*/

proc corr spearman pearson data=Nature_Disparities_Cleaned_;
var lst_meanc ; 
with 
m7_f1
m7_f2
m7_f3
M7_NatureI
NDVI2019_5
CropCnt
PCT_OS
INV_PCT_IM
PCT_TC
NPARKS_16K
INV_DIST_P
INV_DIST_B
PCT_Water
EVI2019_50
PctAccess4
PctAcces_1
;
run;


/*************************************************************************************/

PROC IMPORT DATAFILE= "\\ad.bu.edu\bumcfiles\SPH\Projects\SC\06Methods_and_Specifications\05CWBI2020\Internal\03Analytic\ModeAdj_Scoring_Ranks\Brochu\11202024\LST2015_2019_Nature_Tracts_Final.csv" 
OUT= tmp_15_19
DBMS=csv
REPLACE;
GETNAMES=YES;
RUN; /*N=538*/

/*the correltions are the sams as in table 2*/
proc corr spearman pearson data=tmp_15_19;
var meanlst_2015_2019 ; 
with 
m7_f1
m7_f2
m7_f3
M7_NatureIndex
;
run;

proc means data=tmp_15_19; var meanlst_2015_2019 ; run;

/*************************************************************************************/

data dat1; set tmp_15_19; keep 
m7_f1 m7_f2 m7_f3 M7_NatureIndex geoid_data;
run; 

data dat2; set Nature_Disparities; keep
geoid_data pctnhwhite pctnhblack rrs;
run;

proc sort data=dat1; by geoid_data;
proc sort data=dat2; by geoid_data;
data dat_all; merge dat1(in=t) dat2; by geoid_data; if t;
proc freq data=dat_all; tables rrs; run;
data dat_all; set dat_all;
if M7_NatureIndex<140 then M7_NatureIndex_c=1;
else if M7_NatureIndex<147 then M7_NatureIndex_c=2;
else if M7_NatureIndex<153 then M7_NatureIndex_c=3;
else if M7_NatureIndex<161 then M7_NatureIndex_c=4;
else M7_NatureIndex_c=5;

if rrs<-0.5 then rrs_c=1;
else if rrs<-0.1 then rrs_c=2;
else if rrs<0.1 then rrs_c=3;
else if rrs<0.5 then rrs_c=4;
else rrs_c=5;
run;

proc sort data=dat_all; by M7_NatureIndex_c;
proc means data=dat_all; var pctnhwhite pctnhblack;
by M7_NatureIndex_c;
run;

proc freq data=dat_all; tables rrs_c*M7_NatureIndex_c; 
run;

*ods pdf file="anova_model_for_races.pdf";
proc glm data=dat_all; class M7_NatureIndex_c; model pctnhwhite=M7_NatureIndex_c/solution; 
lsmeans M7_NatureIndex_c/adjust=tukey pdiff cl; quit;
proc glm data=dat_all; class M7_NatureIndex_c; model pctnhblack=M7_NatureIndex_c/solution; 
lsmeans M7_NatureIndex_c/adjust=tukey pdiff cl; quit;
*ods pdf close;

proc contents data=Nature_Disparities_Cleaned varnum; run;

/*
(greenness)

NDVI2019_5		:DVI2019_500m
CropCnt			:CropCnt
PCT_OS			:PCT_OS 
INV_PCT_IM		:INV_PCT_IMP_2016 
PCT_TC			:PCT_TC 

(park)

NPARKS_16K		:NPARKS_16KM
INV_DIST_P		:INV_DIST_PARK_M 
PctAccess4		:PctAccess402m_Parks

(bluespace)

INV_DIST_B		:INV_DIST_BLUE_M 
PCT_Water		:PCT_Water 
PctAcces_1		:PctAccess402m_BlueSpace
*/


*ods pdf file="Y:\Brochu\11202024\logistic_rrs.pdf";
proc logistic data=dat_all desc; /*aic: 1672.056*/
class rrs_c(ref="1") /param=ref;
model M7_NatureIndex_c(ref="1")= rrs_c ;
run;
*ods pdf close;


proc means data=dat_all; var rrs; run;

proc logistic data=dat_all desc; /*aic: 1664.399 */
model M7_NatureIndex_c(ref="1")= rrs ;
run;

proc logistic data=dat_all desc; /*aic: 1674.477*/
class rrs_c(ref="1") /param=ref;
model M7_NatureIndex_c(ref="1")= pctnhwhite pctnhblack rrs_c;
run;

data tmp; set dat_all; t=pctnhwhite-pctnhblack;
proc corr data=tmp; var t rrs pctnhwhite pctnhblack; run;

proc sgplot data=dat_all;
vbox rrs/group=M7_NatureIndex_c;
quit;


/****************************************************/

data d526; set tmp_15_19; keep geoid_data; run;

PROC IMPORT DATAFILE= "\\ad.bu.edu\bumcfiles\SPH\Projects\SC\06Methods_and_Specifications\05CWBI2020\Internal\03Analytic\ModeAdj_Scoring_Ranks\Brochu\11202024\StatewideNatureMetrics_Final.xls" 
OUT= data_all
DBMS=xls
REPLACE;
GETNAMES=YES;
RUN; /*N=1474*/

proc contents data=data_all varnum; run;

/*for cropcnt, missing as 0, conver DIST_OCEAN_M to km*/

proc sort data=data_all; by geoid_data;
proc sort data=d526; by geoid_data;
data data_all_; merge data_all d526(in=t); by geoid_data; if t;
data data_all_; set data_all_; if CropCnt=. then CropCnt=0;
DIST_OCEAN_M=DIST_OCEAN_M/1000;
run;



proc contents data=data_all_ varnum; run;


ods pdf file="\\ad.bu.edu\bumcfiles\SPH\Projects\SC\06Methods_and_Specifications\05CWBI2020\Internal\03Analytic\ModeAdj_Scoring_Ranks\Brochu\11202024\Table_for_all.pdf";
/*Greenness*/
proc means data=data_all_ n nmiss mean std; /*11 items*/
var 
NDVI_2019 NDVI2019_250m NDVI2019_500m
EVI2019 EVI2019_250m EVI2019_500m
PCT_OS     PctCrop 
CropCnt PCT_TC  PCT_IMP_2016;
run;

/*total park and recreation*/
proc means data=data_all_ n nmiss mean std; /*10 items*/
var 
NPARKS_W_TRACT NPARKS_300M NPARKS_1KM NPARKS_16KM
PCT_ParkArea DIST_PARK_M PctAccess402m_Parks
PctAccess1609m_Parks DIST_TRAILS_M
Trailkm_w_in_1km;
run;

/*total bluespace checked*/
proc means data=data_all_ n nmiss mean std; /*8 items*/
var 
DIST_BLUE_M FreshW_M DIST_OCEAN_M
PctAccess402m_BlueSpace PctAccess1000m_BlueSpace
PctAccess1609m_BlueSpace PCT_Water PCT_Water1km
;
run;
ods pdf close;

proc corr data=data_all_ spearman noprob nomiss;
var 
NDVI_2019 NDVI2019_250m NDVI2019_500m
EVI2019 EVI2019_250m EVI2019_500m
PCT_OS     PctCrop 
CropCnt PCT_TC  PCT_IMP_2016
NPARKS_W_TRACT NPARKS_300M NPARKS_1KM NPARKS_16KM
PCT_ParkArea DIST_PARK_M PctAccess402m_Parks
PctAccess1609m_Parks DIST_TRAILS_M
Trailkm_w_in_1km
DIST_BLUE_M FreshW_M DIST_OCEAN_M
PctAccess402m_BlueSpace PctAccess1000m_BlueSpace
PctAccess1609m_BlueSpace PCT_Water PCT_Water1km
;
run;

