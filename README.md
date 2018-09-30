# strviewr
R package for downloading sequences of photos from Google Streetview.

### Prerequisites
This package uses Google Maps API. In order to be able to use this package you have to use your own API key, if you do not have Google Maps API key yet, you can create one [here](https://developers.google.com/maps/documentation/streetview/get-api-key). While creating the key, when you are asked to "Pick product(s) below" please check all three boxes - Maps, Routes and Places. Using Google Maps API is free up to 25000 map loads per 24 hours and the free plan has also limited resolution to 640 x 640.

### Installing

To install the package from Github I recommend the devtools function intall_github. 
You can just copy the code below to the console and execute it.

```
if(!is.element("devtools", installed.packages()[,1])) {install.packages("devtools")} 
library(devtools)
install_github("jiristipl/strviewr")
```

### Documentation
You can view the documentation in RStudio by executing `?download_place` or `?download_track`. <br />

#### download_place(loc, place_code, folder = getwd(), step = 30, key)
Downloads 360 degrees panorama sequence of images with defined change in angle of view

|Parameter|Description|
|:---|:---|
|`loc`         |Location as vector `c(lat,lng)`|  
|`place_code`|  A number identifying the place to be downloaded, its passed to filenames of images|  
|`folder`|      Defaultly it is the current working directory|  
|`step`|        The angle between two images in degrees|  
|`key`|         Your Google Maps API key|  

**Output:** Returns nothing.

**Example:**
Key in this example is only ilustrational, in order to use the package you will have to acquire your own, see chapter **Prerequisites**,
```
download_place(loc=c(50.089360, 14.415233),place_code=1, step=35, key="AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
```
<br />

#### download_track(start, end, track_code, folder=getwd(), pace=20, fineness=5, map=1, adjust=FALSE,key)
Downloads two sequances of images from Google Streetview between given coordinates, one in each direction and also can create summary maps.

| Parameter | Description |
|:---|:---|
|`start`       |Start location as vector `c(lat,lng)`|  
|`end`        |End location as vector `c(lat,lng)`|
|`track_code`  |A number identifying the track to be downloaded, its passed to filenames of images|  
|`folder`|      Defaultly it is current working directory|  
|`pace`|        Number of metres between coordinates used to download images|  
|`fineness`|    Number of images with adjusted heading before curve|  
|`pace`|        Number of metres between images|  
|`adjust`|      If TRUE script tryes to adjust headings in curves|  
|`key`|         Your Google Maps API key|  

**Output:** Returns a vector of deviances between a calculated and real location of downloaded images. Values below 70 are considered a sufficient match.

**Details:** This function first finds the route between two coordinates using Google Directions API, then it calculates positions of images to be downloaded alongside the route so they are in predefined spacing.
afterwards, it downloads the images and creates a summary map. In the map the bigger red marks with letters stand for calculated positions of images and the smaller blue marks, that are connected with a  green line
to the red marks, are positions of the actually downloaded images.

**Example:**
Key in this example is only ilustrational, in order to use the package you will have to acquire your own, see chapter **Prerequisites**,
```
#' download_track(c(50.080266, 14.447034), c(50.081416, 14.447790),track_code = 1, key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
#' download_track(c(50.064281, 14.509821), c(50.065542, 14.507479), track_code = 2, pace = 30, key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
#' download_track(c(50.065476, 14.512228), c(50.065001, 14.514193), track_code = 3, adjust = TRUE, fineness = 7,key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
```
## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
