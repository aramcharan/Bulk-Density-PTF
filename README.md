# Bulk-Density-PTF

*Global Root Mean Square Prediction error (n = 22,960) = 0.13 g/cm3*

*Mean Prediction Error (n = 22,887) = -0.001 g/cm3*

![validation table]
(https://github.com/aramcharan/Bulk-Density-PTF/blob/master/Validation.JPG)

Ecoregion map: http://www.fs.fed.us/rm/ecoregions/products/map-ecoregions-united-states/
Surficial Materials map: http://pubs.usgs.gov/ds/425/
Soil Structure classification: https://www.nrcs.usda.gov/Internet/FSE_DOCUMENTS/nrcs142p2_052523.pdf

Here are some commands to use the machine learning random forest model in R.

Download library:
```
library(randomForestSRC)
```
Load rf model:
```
load("rfsrc_09122016.Rdata")
```

Obtain a single prediction: 
```
predict.rfsrc(rfsrc_BD, data.frame(soc=1.2, ph_h2o=7.6, sand=45, clay=12, depth=20, structsize= "fine", structtype= "subangular blocky", surf_geology= "alluvial sediments, thick", province="chihuahuan semi-desert province", hzn_desg= "C"))$predicted
```

Obtain a dataframe of predictions (you can use valid10242016.csv as an example):
```
valid_df <- read.csv("valid_10242016.csv")
bd_predict <- predict.rfsrc(rfsrc_BD, newdata = valid_df)
```
