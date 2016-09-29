# Bulk-Density-PTF

Here are some commands to use the machine learning random forest model.

Download library:
library(randomForestSRC)

Load rf model:
load("rfsrc_09122016.Rdata")


Obtain a single prediction: 
predict.rfsrc(rfsrc_BD, data.frame(soc=1.2, ph_h2o=7.6, sand=45, clay=12, depth=20, structsize= "fine", structtype= "subangular blocky", surf_geology= "alluvial sediments, thick", province="chihuahuan semi-desert province", hzn_desg= "C"))$predicted


Obtain a dataframe of predictions:
bd_predict <- predict.rfsrc(rfsrc_BD, newdata = )
