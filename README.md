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
Note: if you would like to acquire coordinates from link to point on Google Maps, for example "https://www.google.com/maps/place/50%C2%B004'50.2%22N+14%C2%B026'31.3%22E/@50.080717,14.4420109,19z/data=!4m6!3m5!1s0x0:0x0!7e2!8m2!3d50.0806176!4d14.4420349" always use the coordinates at the end of the link (not the coordinates right after the "@") converted to format c(lat,lng) => c(50.0806176,14.4420349)

#### download_place(loc, place_code, folder = getwd(), step = 30, key)
Downloads 360 degrees panorama sequence of images with defined change in angle of view

|Parameter|Description|
|:---|:---|
|`loc`         |Location as vector `c(lat,lng)`|  
|`place_code`|  A number identifying the place to be downloaded, its passed to filenames of images|  
|`folder`|      Download location as path to a folder, defaultly it is the current working directory|  
|`step`|        The angle between two images in degrees, defaultly it is set to 30|  
|`key`|         Your Google Maps API key|  

**Output:** Returns nothing.

**Example:**
Key in this example is only ilustrational, in order to use the package you will have to acquire your own, see chapter **Prerequisites**,
```
download_place(loc=c(50.089360, 14.415233),place_code=1, step=35, key="AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
```
<br />

#### download_track(start, end, track_code, folder=getwd(), pace=20, fineness=5, map=1, adjust=FALSE,key)
Downloads two sequances of images from Google Streetview between given coordinates, one in each direction and also can create summary maps. Filenames creation: sprintf(track_%s_%d_%03d.jpg, track_code, direction, order), track_code from user input, direction is 1 for one direction and 0 for the opposite one (both are downloaded), order = number documenting succesion of the images

| Parameter | Description |
|:---|:---|
|`start`       |Start location as vector `c(lat,lng)`|  
|`end`        |End location as vector `c(lat,lng)`|
|`track_code`  |A number identifying the track to be downloaded, it is passed to filenames of images|  
|`folder`|      Download location as path to a folder, defaultly it is the current working directory|  
|`pace`|        Number of metres between coordinates used to download images, defaultly it is 20|  
|`fineness`|    Number of images with adjusted heading before curve, defaultly it is 5|  
|`adjust`|      If TRUE script tryes to adjust headings in curves, defaultly set to FALSE|  
|`map`|      map == 0 => downloads only photos; map == 1 => downloads photos and map of their locations(default); map == 2 => downloads only map|  
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
