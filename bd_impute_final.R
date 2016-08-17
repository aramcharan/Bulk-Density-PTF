## Pedotransfer function for Bulk Density 


rm(list=ls())
setwd("C:/Users/amr418/Google Drive/Dissertation Research/Final DATA/")

set.seed (12567)

library(randomForestSRC)
library(ggRandomForests)
library(ggplot2)
library(scales)
library(rgdal)
library(grid)
library(gridExtra)
library(clhs)
library(caret)

load("Geo_Peds06132016.Rda")
str(Geo_Peds)
names(Geo_Peds)


#Subset pedons for depth less than 200 cm
Peds_200 <- subset(Geo_Peds, Geo_Peds$depth <= 200)
#Subset pedons for SOC greater than zero wt%
Peds_200 <- subset(Peds_200, Peds_200$soc > 0)

# Extract BD model variables, along with pedon key and great group for visualization
fm = bd ~ soc + ph_cacl2 + sand + clay + depth + structsize + structtype + surf_geology + province + hzn_desg


## Missing values distribution:
sel <- (Peds_200[,all.vars(fm)])
summary(sel)


# Extract complete cases for comparison
sel.complete <- complete.cases(sel)
summary(sel.complete)
## 41,878 complete (or 20%)
Peds_complete <- sel[sel.complete,]


cs <- clhs(Peds_complete, size  = nrow(Peds_complete)/2, progress = FALSE, simple = FALSE)
write.csv(cs$sampled_data,"cs_08082016_2.csv")
plot.cLHS_result(cs)
s <- cs$index_samples


lhcs_df <- cs$sampled_data

#Create data partition
rf_train <- createDataPartition(y=lhcs_df$bd, p=0.7,list = FALSE, groups = 8)

train1 <- lhcs_df[rf_train,]
test1 <- lhcs_df[-rf_train,]

rfsrc_BD <- rfsrc(fm, data=train1, importance = TRUE, ntree=150)
save(rfsrc_BD, file = "rfsrc_08082016_2.Rdata")

bd_predict <- predict.rfsrc(rfsrc_BD, newdata = test1)

test_df <- bd_predict$xvar
test_df$predict <- bd_predict$predicted
test_df$y <- bd_predict$yvar
test_df$RMSPE <- round(sqrt((test_df$y - test_df$predict)^2),2)
test_df$MPE <- (test_df$y - test_df$predict)

ME <- (1/(nrow(test_df)))*sum(test_df$MPE)

#sqrt((1/(nrow(test_df)))*sum((test_df$y - test_df$predict)^2))
RMSE(test_df$predict, test_df$y)

save(test_df, file = "test_df08082016.Rdata")
