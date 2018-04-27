#Table Schema

#date: a string in format YYYY-MM-DD
#lat_bin: the southern edge of the grid cell, in 100ths of a degree -- 101 is the grid cell with a southern edge at 1.01 degrees north
#lon_bin: the western edge of the grid cell, in 100ths of a degree -- 101 is the grid cell with a western edge at 1.01 degrees east
#flag: the flag state of the fishing effort, in iso3 value
#geartype: see our description of geartpyes
#vessel_hours: hours that vessels of this geartype and flag were present in this gridcell on this day
#fishing_hours: hours that vessels of this geartype and flag were fishing in this gridcell on this day
#mmsi_present: number of mmsi of this flag state and geartype that visited this grid cell on this day


#SIX type of fishing vessel:

#drifting_longlines: drifting longlines
#purse_seines: purse seines, both pelagic and demersal
#trawlers: trawlers, all types
#fixed_gear: a category that includes set longlines, set gillnets, and pots and traps
#squid_jigger: squid jiggers, mostly large industrial pelagic operating vessels
#other_fishing: a combination of vessels of unknown fishing gear and other, less common gears such as trollers or pole and line

#===========================WORKSPACE=======================================================================================================================#

#==========================LOAD LIBRARY==================================#


#install.packages("maps")
library(maps)
#install.packages("ggplot2")
library(ggplot2) # to plot barplot
#install.packages("rworldmap")
library(rworldmap) # to plot background
#install.packages("rworldxtra")
library(rworldxtra) # to plot background cont.
#install.packages("plyr")
library(plyr) # for Merging data
#install.packages("dplyr")
library(dplyr) # for filtering data
#install.packages("dbscan")
library(dbscan) # for clustering
#install.packages("class")
library(class) # for data training
#install.packages("sp")
library(sp) # for spatial data
#install.packages("geosphere")
library(geosphere) # to calculate distance from lat and long in KM

#====================READ DATA============================================#

setwd("D:/TIF/RO/Fishing Spot/")  #set working directory
files <- list.files(path = "assets/fishing_effort/daily_csvs/")
f <- list()

#===================Set range of data(per day)============================#
#Set number of days of data
nData <- 56

#Set starting day from file index
fromDay <- 1

toDay <- fromDay + nData

for (i in fromDay:toDay) {  #(i in 1:length(files))
  
  f[[i]] <- read.csv(paste0("assets/fishing_effort/daily_csvs/",files[i]), header = T, sep = ",")
  
  colnames(f[[i]]) <- c(
    "Date", 
    "Latitude", 
    "Longitude", 
    "Nationality", 
    "gearType", 
    "sailingHour", 
    "fishingHour", 
    "MMSIPresent")
  
}

#Combine datas into one dataframe
datas <- ldply(f, data.frame)

#Divides by 100
datas$Latitude <- datas$Latitude/100
datas$Longitude <- datas$Longitude/100

#summary(datas)  to summarzie the datas

#=======================FILTER DATA=======================================#


#datas <- filter(datas, 
#                datas$gearType=="drifting_longlines", 
#                between(datas$fishingHour,2,5))
#                5)

dataFiltered <- filter(datas, 
                       datas$fishingHour>=1,
                       datas$gearType=="drifting_longlines")

#========================SVM===============================================#
#s <- sample(150,100)
#col <- c("Latitude", "Longitude", "gearType", "fishingHour")
#fish_train <- dataFiltered[s,col]
#fish_test <- dataFiltered[-s,col]

#svmfit <- svm(gearType ~ Latitude + Longitude + fishingHour, data = fish_train, kernel = "radial", cost = .1 , scale = FALSE)
#print(svmfit)

#===============================get Distance between Points ===============#


#myData <- dataFiltered[1:5000,]
#sp.myData <- dataFiltered[1:5000,]

#coordinates(sp.myData) <- ~Longitude+Latitude #convert into readable Longitude + Latitude data


#d <- distm(sp.myData) # get the distance
#min.d <- apply(d, 1, function(x) order(x, decreasing=F)[2]) # get the second closest data, the closest is itself

#newData <- cbind(myData[min.d,], apply(d, 1, function(x) sort(x, decreasing=F)[2]))
#colnames(newData) <- c(
#                        "Date",
#                        "Latitude",
#                        "Longitude",
#                        "Nationality",
#                        "gearType",
#                        "sailingHour",
#                        "fishingHour",
#                        "MMSIPresent",
#                        "Distance"
#                     )




t_1 <- dataFiltered[1:5000,2:3]
#t_2 <- newData[1:5000,9]

#=================Normalization========================#
#normalize <- function(x){ #using feature scaling formula
#  num <- x - min(x)
#  denom <- max(x) - min(x)
#  return (num/denom)
#}
#t_norm <- as.data.frame(lapply(t_1[1:5000,1:2], normalize))

#================k-NN classification================#
#t_combined <- cbind(t_norm,t_2)
#colnames(t_combined) <- c(
#                "Latitude",
#                "Longitude",
#                "Distance"
#                )


#set.seed(2)
#ind <- sample(2, nrow(t_combined), replace = TRUE, prob=c(0.67, 0.33))

#t_train <- t_combined[ind==1,1:2]
#t_test <- t_combined[ind==2,1:2]

#t_train_labels <- t_combined[ind==1, 3]
#t_test_labels <- t_combined[ind==2, 3]

#t_pred <- knn(train=t_train, test=t_test, k=11, cl=t_train_labels)

#CrossTable(x = t_test_labels, y = t_pred, prop.chisq=FALSE)

#==================kNN distance to determine epsilon===========================#

kNNdistplot(t_1, k = 3)
abline(h=1.45, col = "red", lty=3, ylim = 3)

#======================Data Clustering====================================#

#Using density-based clustering method
#dataTrimmed <- select(dataFiltered, 2,3,7)
#cluster <- as.matrix(dataTrimmed[,1:3])
#res <- dbscan(cluster, eps = 1, minPts = 5)

#pairs(cluster, col=res$cluster+1L)
#hullplot(cluster, res$cluster)

cluster <- dbscan(select(dataFiltered, Latitude, Longitude), eps = 1.45, minPts=10)

#============================Plot into barChart===========================#

#///////////////////////////clusterID,frequencies barChart
frequencies = c()
clusterID = c()

for(h in 1:max(cluster$cluster)){

  frequencies[h] <- sum(cluster$cluster==h)
  clusterID[h] <- h
  
}

table <- data.frame(clusterID, frequencies)

#Sort by number of frequencies in a cluster
head(table[order(-table$frequencies),])  

g <- ggplot(table, aes(x = table$clusterID, y = table$frequencies))+geom_bar(stat="identity")

g + labs(x = "Cluster ID") + labs(y = "Frequencies")
plot(g) # barchart clusterID by number of points(ship) in the cluster

#===================FIND THE LATITUDE AND LONGITUDE=======================#

LatLong <- data.frame(dataFiltered$Latitude[cluster$cluster==16], dataFiltered$Longitude[cluster$cluster==16])

colnames(LatLong) <- c(
  "Longitude",
  "Latitude"
)

#================LOAD MAP=================================================#

#m <- map('worldHires', plot=FALSE)
#map('worldHires', proj='albers', orient=c(-2.44565,117.8888, 17.92564875), par=c(50,50))
#map.grid(m, col=2, nx=50, ny=50, label=TRUE, lty=3)
#map3 <- plotmap(lat=0,lon=0,maptype="satellite", API="google", zoom=0)

map <- getMap(resolution = "high")
plot(map,asp=1)

desc <- arrange(table, clusterID)

#======================POINTS DATA =======================================#

points(dataFiltered$Longitude[cluster$cluster>0], dataFiltered$Latitude[cluster$cluster>0], col="red", pch=".", cex=3)
#Points specific cluster
#clusterP <- 16
#points(dataFiltered$Longitude[cluster$cluster==clusterP]/100, dataFiltered$Latitude[cluster$cluster==clusterP]/100, col="green", pch=".", cex=3)
