#' Get optimized route from Valhalla API
#'
#' @param from A numeric vector of length 2, specifying the longitude and latitude of the starting point.
#' @param to A numeric vector of length 2, specifying the longitude and latitude of the destination.
#' @param costing A string specifying the costing model to use for route optimization. Default is "auto".
#' @param units A string specifying the units to use for the route distance. Default is "miles".
#' @param url A string specifying the URL of the Valhalla API. Default is "http://localhost:8002/optimized_route".
#' @param ... Additional arguments to pass to httr2::GET.
#' @return An sf object representing the optimized route.
#' @export
#' @examples
#' if (FALSE) {
#'   andorra_la_vella = c(1.5218, 42.5075)
#'   pas_de_la_casa = c(1.7333, 42.5425)
#'   r1 = vh_get(from = andorra_la_vella, to = pas_de_la_casa)
#' }
vh_get = function(from, to, costing = "pedestrian", units = "miles", url = "http://localhost:8002", ..., resource = "optimized_route") {
  params = list(
    locations = list(
        list(lon = from[1], lat = from[2]),
        list(lon = to[1], lat = to[2])
      ),
      costing = costing,
      ...
    )
#   names(params) = paste0("_", names(params))
  
  json = httr2::request(url) |> 
    httr2::req_url_path_append(resource) |> 
    httr2::req_body_json(params) |> 
    # req_user_agent("my_package_name (http://my.package.web.site)") |> 
    httr2::req_perform() |> 
    httr2::resp_body_json()
  vh_sfc(json$trip$legs[[1]]$shape)
}

vh_sfc = function(json) {
  line = googlePolylines::decode(json)
  line_sf = sfheaders::sf_linestring(line[[1]])
  line_sf
}
