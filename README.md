# Fishing Spot
  The purpose of this project is to help fisherman finding the popular spot to fish. 
  The spot will be chosen based on the amount of fishing vessels in an area, 
  the amount of time spent by that vessel, and the gear type mounted on the vessel.

## Project Member
1. Albert Antonio
2. Bong Cen Choi
3. Ricky

### Methods
* DBSCAN(Density-Based Spatial Clustering of Applications with Noise)
  * Categorize points in a space based on the number of adjacent points.	
* K-NN(K-Nearest Neighbour)
  * To determine parameter value for Epsilon
    
### Library
* maps
  * To display map
  * https://cran.r-project.org/web/packages/maps/maps.pdf
* ggplot2
  * To plot barplot
  * https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf
* rworldmap
  * To plot background
  * https://cran.r-project.org/web/packages/rworldmap/rworldmap.pdf
* rworldxtra
  * To plot background cont
  * https://cran.r-project.org/web/packages/rworldxtra/rworldxtra.pdf
* plyr
  * For Merging data
  * https://cran.r-project.org/web/packages/plyr/plyr.pdf
* dplyr
  * For filtering data
  * https://cran.r-project.org/web/packages/dplyr/dplyr.pdf
* dbscan
  * For clustering 
  * https://cran.r-project.org/web/packages/dbscan/dbscan.pdf

### Explanation

#### Data Extraction and Cleansing 

The datas are extracted from https://globalfishingwatch.force.com/gfw/s/data-download
The datas range from 2012-01-01 to 2012-02-26

Below are the details regarding the datas:

Table Schema

* *date*: a string in format YYYY-MM-DD
* *lat_bin*: the southern edge of the grid cell, in 100ths of a degree -- 101 is the grid cell with a southern edge at 1.01 degrees north
* *lon_bin*: the western edge of the grid cell, in 100ths of a degree -- 101 is the grid cell with a western edge at 1.01 degrees east
* *flag*: the flag state of the fishing effort, in iso3 value
* *geartype*: see our description of geartypes
* *vessel_hours*: hours that vessels of this geartype and flag were present in this gridcell on this day
* *fishing_hours*: hours that vessels of this geartype and flag were fishing in this gridcell on this day
* *mmsi_present*: number of mmsi of this flag state and geartype that visited this grid cell on this day

There are SIX types of fishing vessel:
1. drifting_longlines: drifting longlines
2. purse_seines: purse seines, both pelagic and demersal
3. trawlers: trawlers, all types
4. fixed_gear: a category that includes set longlines, set gillnets, and pots and traps
5. squid_jigger: squid jiggers, mostly large industrial pelagic operating vessels
6. other_fishing: a combination of vessels of unknown fishing gear and other, less common gears such as trollers or pole and line

Data is filtered based on:
* fishingHour(hour) >= 1 
* gearType : “drifting_longlines”

#### Data Mapping

Our project uses DBSCAN to cluster fishing vessel spot which are fishing in order to find the Fishing Hotspots
DBSCAN will require three arguments to be passed
* Set of Points
	* Which refer to the location of the fishing ships
* ε (Epsilon)
	* specifies how close points should be to each other to be considered a part of a cluster
	* in order to find the correct epsilon value we use the knee point of k-NN Distance 
* Minimal Points (min. 10)
    	* specifies how many neighbors a point should have to be included into a cluster
	* in order to find the correct Minimal Points, "Trial and Error" is used at this point which we fo

#### Code Preview

##### The k-NN Distance : 
```
kNNdistplot(t_1, k = 3)
```
where t_1 is the list of all the long and lat of the points and k is number of the nearest method used

##### The DBSCAN :
```
cluster <- dbscan(select(dataFiltered, Latitude, Longitude), eps = 1.45, minPts=10)
```
where eps is the value we get from the knee point of the k-NN Distance and minPts is the value we get from trial and error.




### Project Preview
![alt text](https://github.com/assasinz88/Fishing_Spot/blob/master/Rplot02.png)
![alt text](https://github.com/assasinz88/Fishing_Spot/blob/master/knee.png)
![alt text](https://github.com/assasinz88/Fishing_Spot/blob/master/worldMap.png)
