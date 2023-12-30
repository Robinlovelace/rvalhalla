#' Get matrix of travel times & distances from Valhalla API
#'
#' @param from a tibble of source locations, with columns "lat" and "lon" for latitude and longitude.
#' @param to a tibble of destinations, with columns "lat" and "lon" for latitude and longitude.
#' @param costing A string specifying the costing model to use for route optimization. Default is "auto".
#' @param directions_options A named list.
#'   By default this is list(units = "km") specifying the units to use.
#' @inheritParams vh_get
#' @return A tibble of distances & times, with source and destination indices.
#' @export
#'
#' @examples
sources_to_targets = function(
    from,
    to,
    costing = "pedestrian",
    directions_options = list(units = "km"),
    url = "http://localhost:8002",
    ...
) {
  
  params = list(
    sources = 
      purrr::map(seq_len(nrow(from)), function(x) list(lon=from[x,]$lon,lat=from[x,]$lat)),
    targets = 
      purrr::map(seq_len(nrow(to)), function(x) list(lon=to[x,]$lon,lat=to[x,]$lat)),
    costing = costing,
    directions_options = directions_options,
    ...
  )
  json = vh_get(resource="sources_to_targets",
                from, 
                to,
                costing, 
                units,
                url = url, 
                params = params)
  purrr::map_dfr(json$sources_to_targets, function(x) tibble::as_tibble(x[[1]]))
}
  