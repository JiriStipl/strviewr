#' download_track
#'
#' Downloads two sequances of images from Google Streetview between given coordinates, one in each direction and also can create summary maps.
#' @import jsonlite
#' @import RCurl
#' @import googleway
#' @param start vector c(lat,lng)
#' @param end vector c(lat,lng)
#' @param track_code A number identifying the track to be downloaded, its passed to filenames of images
#' @param map  (map == 0) => downloads only images without map;  (map == 1) =>  downloads images and map of their locations; (map == 2) => downloads only summary map
#' @param folder Defaultly it is current working directory
#' @param pace Number of metres between coordinates used to download images
#' @param fineness number of images with adjusted heading before curve
#' @param pace metres between images
#' @param adjust If TRUE script tryes to adjust headings in curves
#' @param key Your Google Maps API key
#' @return Returnes vector of deviances between calculated and real location of downloaded images. Values bellow 70 are considered a sufficient match.
#' @details This function first finds the route between two corrdinates using Google Directions api, then it calculates positions of images to be downloaded alongside the route so they are in predefined spacing.
#' afterwards it downloads the images and creates summary map. In the map the bigger red marks with letters stand for calculated positions of images and the smaller blue marks, that are connected with green line
#'  to the red marks, are positions of the actualy downloaded images.
#'  @
#' @export
#' @examples
#' download_track(c(50.080266, 14.447034), c(50.081416, 14.447790), 1, key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
#' download_track(c(50.064281, 14.509821), c(50.065542, 14.507479), 2, pace = 30, map = 2, key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
#' download_track(c(50.065476, 14.512228), c(50.065001, 14.514193), 3, adjust = TRUE, fineness = 7,key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
#' download_track(c(-16.704637, -49.262431),c(-16.702592, -49.263336), 4,key = "AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")

download_track <- function(start, end, track_code, folder=getwd(), pace=20, fineness=5, map=1, adjust=FALSE,key) {
  library(googleway)
  library(jsonlite)
  library(RCurl)
  # start/end = vector c(lat,lng); pace = metres between photos; fineness = number of photos with adjusted heading before curve
  # map == 0 = download only photos; map == 1 = download photos and map of their locations; map == 2 = download only map
  errors<- vector()
  # creates dataframe containing coordinates of all photos
  callback <- google_directions(start, end, key = key)
  places_n <- (sum(callback$routes$legs[[1]]$steps[[1]]$distance$value) / pace)
  past <- c(0, callback$routes$legs[[1]]$steps[[1]]$distance$value)
  i <- 0
  last <- 1
  steps <- callback$routes$legs[[1]]$steps
  
  posits <- data.frame(matrix(ncol = 4, nrow = 0))
  
  while (i < places_n) {
    if (i * pace < sum(callback$routes$legs[[1]]$steps[[1]]$distance$value[1:last])) {
      posits[i + 1, ] <- c(pointInDist(steps[[1]]$start_location[last, ], steps[[1]]$end_location[last, ], (i * pace) - sum(past[1:last]), steps[[1]]$distance$value[last]), last, steps[[1]]$distance$value[last])
    } else {
      last <- last + 1
      posits[i + 1, ] <- c(pointInDist(steps[[1]]$start_location[last, ], steps[[1]]$end_location[last, ], (i * pace) - sum(past[1:last]), steps[[1]]$distance$value[last]), last, steps[[1]]$distance$value[last])
    }
    i <- i + 1
  }
  # downloads photos and map
  if (adjust == TRUE) {
    posits <- addHeadings(posits)
  }
  else {
    posits <- lineHeadings(posits)
  }
  mapquerry <- "https://maps.googleapis.com/maps/api/staticmap?size=600x600&maptype=hybrid&scale=false"
  if (is.numeric(track_code)) {
    track_code <- sprintf("%04s", track_code)
  }
  fn_template <- file.path(folder, "track_%s_%d_%03d_%04d.jpg")
  fn_template_map <- file.path(folder, "track_%s_map.jpg")
  for (s in seq(1, nrow(posits))) {
    for (d in c(0, 1)) {
      loc <- posits[s, ]
      dir <- posits[s, 5]
      fn <- sprintf(fn_template, track_code, d, s, dir)
      u <- stview_query(
        loc = loc, size = c(600, 600),
        heading = (dir + d * 180) %% 360, key = key
      )
      cat(u, "\n")
      if (map == 2) {} else {
        download.file(u, fn, mode = "wb")
      }
      if ((map == 1 | map == 2) & d == 0) {
        trueloc<-metloc(loc)
        mapquerry <- paste0(mapquerry, addpoint(loc, trueloc, rank = (s) %% 26))
        errors[length(errors)+1]<- round(distloc(loc,trueloc)*1000,0)
        
      }
    }
  }
  download.file(paste0(mapquerry, "&key=", key), sprintf(fn_template_map, track_code), mode = "wb")
  return(unlist(errors))
}
alphabet <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")

stview_query <- function(loc, heading, pitch=0, size=c(600, 300), fov=120, key=key) {
  loc<-unlist(loc)
  if (is.numeric(size)) {
    if (length(size) == 2) {
      qsize <- sprintf("%dx%d", size[1], size[2])
    }
    if (length(size) == 1) {
      qsize <- sprintf("%dx%d", size[1], size[1])
    }
  }
  if (is.character(size)) {
    qsize <- size
  }
  url <- "https://maps.googleapis.com/maps/api/streetview?"
  query <- sprintf(
    "size=%s&location=%f,%f&heading=%d&pitch=%f&fov=%d&key=%s",
    qsize, # WxH
    loc[1], loc[2], # lng,lat
    heading, # heading 0-360 (0=N, 90=E)
    round(pitch, 0), # 90..-90 = up..down
    fov, # fov
    key = key
  )
  final_query <- paste0(url, query)
  final_query
}

addpoint <- function(loc, metloc, rank) {
  
  # creates mapApi text representing markers for computed and real location of photo and path linking them
  
  loc <- paste0(loc[1], ",", loc[2])
  metloc <- paste0(metloc[1], ",", metloc[2])
  loc_marker <- paste0("&markers=size:small%7ccolor:blue%7Clabel:", alphabet[rank], "%7C", loc)
  metloc_marker <- paste0("&markers=size:mid%7ccolor:red%7Clabel:", alphabet[rank], "%7C", metloc)
  path <- paste0("&path=color:green|weight:4|", loc, "|", metloc)
  paste0(metloc_marker, loc_marker, path)
}
metloc <- function(loc) {
  
  # returnes real location of streetview image closest to given coordinates
  
  loc <- paste0(loc[1], ",", loc[2])
  url <- paste0("https://maps.googleapis.com/maps/api/streetview/metadata?size=600x600&location=", loc, "&key=", key)
  metadata <- fromJSON(getURL(url, ssl.verifyhost = FALSE, ssl.verifypeer = FALSE))
  metloc <- c(metadata$location$lat, metadata$location$lng)
  metloc
}

parse_gmap_url_single <- function(u) {
  u2 <- gsub("^.*@", "", u)
  u3 <- unlist(strsplit(u2, ","))[1:2]
  as.numeric(u3)
}

parse_gmap_url <- function(u) {
  n <- length(u)
  uu <- data_frame(lat = rep(0, n), lng = rep(0, n))
  for (i in 1:n) {
    latlng <- parse_gmap_url_single(u[i])
    uu$lat[i] <- latlng[1]
    uu$lng[i] <- latlng[2]
  }
  uu
}

lng <- function(loc) {
  # expects c(lat, lng) or names
  loc <- as.numeric(loc)
  if (!is.null(names(loc))) {
    loc["lng"]
  } else {
    loc[2]
  }
}
lat <- function(loc) {
  # expects c(lat, lng) or names
  loc <- as.numeric(loc)
  if (!is.null(names(lat))) {
    loc["lat"]
  } else {
    loc[1]
  }
}


pointInDist <- function(start, end, dist, length) {
  
  # returnes position in certain distance from one position in direction towards second position
  
  as.numeric(c(start[1] + (end[1] - start[1]) * (dist / length), start[2] + (end[2] - start[2]) * (dist / length)))
}

addHeadings <- function(frame, fineness=4) {
  
  # adds curves adjusted headings to dataframe
  
  fineness <- fineness + 1
  frame <- cbind(frame, vector(length = nrow(frame)))
  frame <- lineHeadings(frame)
  startangle <-
    for (i in seq(1, nrow(frame))) {
      if (frame[i, 3] == tail(frame, 1)[3]) {
      } else if (frame[i, 3] != frame[i + 1, 3]) {
        diff <- (frame[i, 5] - frame[i + 1, 5]) / fineness
        startangle <- frame[i, 5]
        for (x in seq(1, fineness)) {
          frame[i - x + 1, 5] <- round(startangle - diff * (fineness - x), 0)
        }
      }
    }
  frame
}


lineHeadings <- function(frame) {
  # adds unadjusted headings to frame
  frame<- cbind(frame,vector(length = nrow(frame)))
  lines <- unique(frame[, 3])
  for (i in seq(1, length(lines))) {
    a <- as.numeric(frame[frame[, 3] == lines[i], ][1, ])
    b <- as.numeric(frame[frame[, 3] == lines[i], ][2, ])
    dir <- 90 - round(atan2(b[1] - a[1], b[2] - a[2]) / pi * 180)
    frame[frame[, 3] == lines[i], ][, 5] <- dir
    frame
  }
  frame
}
distloc <- function (loc,trueloc)
{
  lat<-loc[1] - trueloc[1]
  lng<-loc[2] -trueloc[2]
  return(sqrt(lat*lat + lng*lng)*1000)
}
