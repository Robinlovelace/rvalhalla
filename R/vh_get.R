#' Get optimized route from Valhalla API
#'
#' @param url A string specifying the URL of the Valhalla API. Default is "http://localhost:8002/optimized_route".
#' @param params Parameters to pass to the Valhalla API as a json object. Default is list().
#' @param resource A string specifying the resource to request from the Valhalla API. Default is "route". Options are:
#' * "route": Guides you between points by car, bike, foot, and multimodal combinations involving walking and riding public transit. Your apps can use the results from the route service to plan multimodal journeys with narratives to guide users by text and by voice. Valhalla draws data from OpenStreetMap for the main graph and from user-supplied GTFS feeds for multimodal routing.
#' * "optimized_route": Computes the times and distances between many origins and destinations and provides you with an optimized path between the locations.
#' * "matrix": Provides a table of the times and distances between points.
#' * "isochrone": Computes areas that are reachable within specified time periods from a location or set of locations.
#' * "map-matching": Matches coordinates to known roads so you can turn a path into a route with narrative instructions and get the attribute values from that matched line.
#' * "elevation": Finds the elevation along a path or at specified locations.
#' * "expansion": Returns a geojson representation of a graph traversal at a given location.
#' * "locate": Provides detailed metadata about the nodes and edges in the graph.
#' * "status": Returns information about the running server or Valhalla instance.
#' * "centroid": Finds the least cost convergence point of routes from multiple locations. 
#' @param ... Additional parameters to pass to the Valhalla API.
#' @return An sf object representing the optimized route.
#' @export
vh_get = function(url = "http://localhost:8002", resource = "route", params = list(), ...) {
  json = httr2::request(url) |> 
    httr2::req_url_path_append(resource) |> 
    httr2::req_body_json(params) |> 
    # req_user_agent("my_package_name (http://my.package.web.site)") |> 
    httr2::req_perform() |> 
    httr2::resp_body_json()
  json
}

vh_sfc = function(json) {
  line = googlePolylines::decode(json)
  line_sf = sfheaders::sf_linestring(line[[1]])
  line_sf
}

#' Get route from Valhalla API
#' 
#' @param from A numeric vector of length 2, specifying the longitude and latitude of the starting point.
#' @param to A numeric vector of length 2, specifying the longitude and latitude of the destination.
#' @param costing A string specifying the costing model to use for route optimization. Default is "auto".
#' @param directions_options A named list.
#'   By default this is list(units = "km") specifying the units to use.
#' @inheritParams vh_get
#' @return An sf object representing the route.
#' @export
#' @examples
#' if (FALSE) {
#'   andorra_la_vella = c(1.5218, 42.5075)
#'   pas_de_la_casa = c(1.7333, 42.5425)
#'   r1 = vh_get(from = andorra_la_vella, to = pas_de_la_casa)
#' }
vh_route = function(
    from,
    to,
    costing = "pedestrian",
    directions_options = list(units = "km"),
    url = "http://localhost:8002",
    ...
    ) {
  params = list(
    locations = list(
      list(lon = from[1], lat = from[2]),
      list(lon = to[1], lat = to[2])
      ),
    costing = costing,
    directions_options = directions_options,
    ...
    )
  json = vh_get(from, to, costing, units, url = url, params = params, resource = "route")
  vh_sfc(json$trip$legs[[1]]$shape)
}