#' download_place
#'
#' Downloads 360 degrees panorama sequence of images with defined change in angle of view
#' @param loc vector c(lat,lng)
#' @param place_code A number identifying the place to be downloaded, its passed to filenames of images
#' @param folder Defaultly it is current working directory
#' @param step Difference in angle between two images in degrees
#' @param key Your Google Maps API key 
#' @return Returnes nothing.
#' @export
#' @example
#' download_place(loc=c(50.089360, 14.415233),place_code=1, step=35, key="AIzaSyCIPkCIWA0ZDQ4dDS45kiZcKpasd-t-Q3E")
download_place <- function(loc, place_code, folder = getwd(), step = 30, key) {
  if (is.numeric(place_code)) {
    place_code <- sprintf("%04d", place_code)
  }
  fn_template <- file.path(folder, "place_%s_%03d.jpg")
  for (dir in seq(0, 360 - step, step)) {
    fn <- sprintf(fn_template, place_code, dir)
    u <- stview_query(loc = loc, size = c(600, 600), heading = dir, key = key)
    download.file(u, fn, mode = "wb")
  }
}

