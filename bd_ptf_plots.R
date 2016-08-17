rm = list(ls())
setwd("C:/Users/amr418/Google Drive/Dissertation Research/R/Bulk Density Results/")

library(randomForestSRC)
library(ggplot2)
library(scales)
library(rgdal)
library(grid)
library(gridExtra)
library(ggRandomForests)
library(caret)

# Load model
load("rfsrc_08082016_2.RData")

plot.rfsrc(rfsrc_BD)

# Variable Importance plot
gg_dta <- gg_vimp(rfsrc_BD)

# Plot VIMP
plot(gg_dta) +
  theme(axis.text=element_text(size=16), legend.text=element_text   (size=16), axis.title=element_text(size=16)) +
  ylab("Variable Importance") + theme_pub()

# Load test dataset
test1 <- read.csv("test1.csv")

# Extract predictions
bd_predict <- predict.rfsrc(rfsrc_BD, newdata = test1)

#Make dataframe of predictor variables, response, and prediction
#Predictor variables
xvar <- bd_predict$xvar
#Response
xvar$y_var <- bd_predict$yvar
#Model predictions
xvar$predict <- bd_predict$predicted


xvar$RMSPE <- round(sqrt((xvar$y - xvar$predict)^2),2)
xvar$MPE <- (xvar$y - xvar$predict)

ME <- (1/(nrow(xvar)))*sum(xvar$MPE)

#sqrt((1/(nrow(test_df)))*sum((test_df$y - test_df$predict)^2))
RMSPE <- RMSE(xvar$predict, xvar$y)


### Alternative setup of dataframe to help boxplots
df1 <- bd_predict$xvar
df1$y_resp <- bd_predict$yvar
df2 <- bd_predict$xvar
df2$y_resp <- bd_predict$predicted

df1$y_type <- "Observed"
df2$y_type <- "Predicted"

df_bd <- rbind(df1,df2)

#Plot 1: Predicted versus observed bulk density

plt1 <- ggplot(xvar, aes(y_var, predict)) +
          stat_binhex(bins = 20) +
          geom_abline(intercept = 0, slope = 1) + xlim(0,2.2) + ylim(0,2.2) +
          scale_fill_continuous(guide = guide_legend(title = "Count")) +
          theme(axis.text=element_text(size=16), legend.text=element_text(size=16),
          axis.title=element_text(size=16)) +
          xlab("Observed bulk density g" ~ cm^{-3}) + ylab("Predicted bulk density g" ~ cm^{-3}) +           theme_pub() + scale_fill_gradientn(colours = grey.colors(5)) +
         theme(legend.position = c(0.8,0.3), legend.title=element_blank())

plt1

#Plot 2: Boxplots of bulk density by horizon; observed versus predicted
horizon_sub <- subset(df_bd, df_bd$hzn_desg == "O"| df_bd$hzn_desg == "A" | df_bd$hzn_desg == "B" | df_bd$hzn_desg == "Bt" | df_bd$hzn_desg == "Bx" | df_bd$hzn_desg == "BC"| df_bd$hzn_desg == "C")


plt2 <- ggplot(horizon_sub, aes(x = hzn_desg,y = y_resp, fill = y_type)) +
        geom_boxplot(outlier.colour = NULL, lwd =0.75, position = "dodge")  +
        labs(color="Legend") + theme(axis.text=element_text(size=16),
        legend.text=element_text(size=16)) +
        ylab("Bulk density g" ~cm^{-3}) + xlab("") + theme_pub() +
        scale_fill_grey(start = 0.35, end = .9) +
        theme(legend.position = c(0.89,0.87), legend.title=element_blank(),legend.key = element_rect(fill = "transparent"))
plt2

#Plot 3: Boxplots of structural categories; observed versus predicted

struct_sub <- subset(df_bd, df_bd$structtype == "crumb" | df_bd$structtype == "granular" | df_bd$structtype == "subangular blocky" | df_bd$structtype == "blocky" | df_bd$structtype == "platy")

plt3 <- ggplot(struct_sub, aes(x = reorder(structtype, y_resp, FUN = median),
        y = y_resp, fill = y_type)) +
        geom_boxplot(outlier.colour = NULL, lwd =0.75, position = "dodge") +
        labs(color="Legend") +
        theme(axis.text=element_text(size=16),
        legend.text=element_text(size=14))  +
        ylab("Bulk density g" ~cm^{-3}) + xlab("") + theme_pub() +
        scale_fill_grey(start = 0.35, end = .9) +
        theme(legend.position = c(0.7,0.92), legend.title=element_blank())


plt3
#RMSE Analysis
#Plot 4:
#How does model error change with depth?
depth_err <- ggplot(xvar, aes(depth,RMSPE)) + stat_binhex(bins = 30) +
             theme(axis.title=element_text(size = 16),
             axis.text=element_text(size=16),
             legend.text=element_text(size=14)) + xlab("Depth (m)") + ylab("RMSPE g" ~ cm^{-3}) +
             theme_pub() + scale_fill_gradientn(colours = grey.colors(5)) + theme(legend.position = c(0.8,0.7), legend.title=element_blank(), legend.key = element_rect(size=0.5)) + ggtitle("(a)")

#How does model error change with clay?
clay_err <- ggplot(xvar, aes(clay,RMSPE))+ stat_binhex(bins = 30) +
            theme(axis.title=element_text(size = 16), axis.text=element_text(size=16),legend.text=element_text(size=14)) + xlab("% Clay") + ylab("RMSPE g" ~ cm^{-3}) +
  theme_pub() + scale_fill_gradientn(colours = grey.colors(5)) + theme(legend.position = c(0.8,0.7), legend.title=element_blank(), legend.key = element_rect(size=0.5))+ ggtitle("(d)")

#How does model error change with sand?
sand_err <- ggplot(xvar, aes(sand,RMSPE)) + stat_binhex(bins = 30) +
            theme(axis.title=element_text(size = 16), axis.text=element_text(size=16),legend.text=element_text(size=14)) + xlab("% Sand") + ylab("RMSPE g" ~ cm^{-3}) +
  theme_pub() + scale_fill_gradientn(colours = grey.colors(5)) + theme(legend.position = c(0.8,0.7), legend.title=element_blank(), legend.key = element_rect(size=0.5)) + ggtitle("(c)")
#How does model error change with soc?
soc_err <- ggplot(xvar, aes(soc,RMSPE))+ stat_binhex(bins = 30) +
           theme(axis.title=element_text(size = 16), axis.text=element_text(size=16),legend.text=element_text(size=14)) + xlab("SOC %wt") + ylab("RMSPE g" ~ cm^{-3}) +
  theme_pub() + xlim(0,30) + scale_fill_gradientn(colours = grey.colors(5)) + theme(legend.position = c(0.8,0.7), legend.title=element_blank(), legend.key = element_rect(size=0.5)) + ggtitle("(b)")


depth_err
soc_err
sand_err
clay_err
#Plot all 4 variables together
multiplot(depth_err,sand_err,soc_err,clay_err, cols = 2)


# Calculate the 5% error for the mean SOC stock of 146 Mh/ha
## National US SOC stock Mg C/ha
US_avg <- 146
# 5% error limit
max_err <- (US_avg/100)*5
#Set concentrations of SOC in %wt
SOC<- seq(from = 0.001, to = 40, by = 0.05)

#Predict BD interval
pos_bdpred_intvl1 <- round(max_err/((SOC/100)*10000),2)
pos_bdpred_intvl2 <- round(max_err*2/((SOC/100)*10000),2)


bd_df <- as.data.frame(cbind(SOC,pos_bdpred_intvl1,pos_bdpred_intvl2))
names(bd_df) <- c("SOC","BD1","BD2")


#Randomly sample data frame to reduce clutter in graphs
samp <- sample.int(nrow(xvar), 1000, replace = FALSE)
xvar_samp <- xvar[samp,]


#Plot 5:
#How does prediction error change with soc and clay content?
plt5 <- ggplot(xvar_samp, aes(soc,RMSPE)) + geom_point(aes( alpha = clay), size = 5) +
        geom_smooth(data = bd_df, aes(SOC,BD1,color="5% Prediction Error"),
        size = 1, se = FALSE) +
        geom_smooth(data = bd_df, aes(SOC,BD2,color="10% Prediction Error"),
        size = 1, se = FALSE) +
        labs(color="Legend") + theme(axis.text=element_text(size=16),
        axis.title=element_text(size=16), legend.text=element_text(size=16),
        legend.title=element_text(size=16)) +
  ylab("RMSPE g" ~ cm^{-3}) + xlab("SOC % weight") + xlim(0,5) + ylim(0,0.5) +
        theme_pub() + theme(legend.position = c(0.8,0.7)) + scale_color_grey(start = 0.01, end = .5) + ggtitle("(a)")


#Plot 6:
#How frequently does the prediction error exceed the 5% or 10% limit in the dataset??
plt6 <- ggplot(xvar_samp, aes(soc,RMSPE)) + geom_count() +
        geom_smooth(data = bd_df, aes(SOC,BD1,color="5% Prediction Error"),
        size = 1, se = FALSE) +
        geom_smooth(data = bd_df, aes(SOC,BD2,color="10% Prediction Error"),
        size = 1, se = FALSE) +
        labs(color="Legend") + theme(axis.text=element_text(size=16),
        axis.title=element_text(size=16), legend.text=element_text(size=16),
        legend.title=element_text(size=16)) +  ylab("RMSPE g" ~ cm^{-3}) +
        xlab("SOC % weight") + xlim(0,5) + ylim(0,0.5) + theme_pub() +
        theme(legend.position = c(0.8,0.7)) +
        scale_color_grey(start = 0.01, end = .5) + ggtitle("(b)")



multiplot(plt5, plt6, cols = 1)
#Size of graph 500 x 850

#Size of graph 500 x 500


O_hzn <- subset(xvar, xvar$hzn_desg == "O")
