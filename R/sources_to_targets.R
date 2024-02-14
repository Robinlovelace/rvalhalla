#' Get matrix of travel times & distances from Valhalla API
#'
#' @param from a data frame or matrix of source locations with longitude and latitude columns.
#' @param to a data frame or matrix of target locations with longitude and latitude columns.
#' @param costing A string specifying the costing model to use for route optimization. Default is "auto".
#' @param directions_options A named list.
#'   By default this is list(units = "km") specifying the units to use.
#' @inheritParams vh_get
#' @return A tibble of distances & times, with source and destination indices.
#' @export
#'
#' @examples
#' if (FALSE) {
#'   andorra_la_vella <- c(1.5218, 42.5075)
#'   pas_de_la_casa <- c(1.7333, 42.5425)
#'   # Another popular location in andorra:
#'   encamp <- c(1.5763, 42.5343)
#'   from <- rbind(andorra_la_vella, encamp)
#'   to <- rbind(pas_de_la_casa)
#'   sources_to_targets(from, to)
#' }
sources_to_targets <- function(
    from,
    to,
    costing = "pedestrian",
    directions_options = list(units = "km"),
    url = "http://localhost:8002",
    ...) {
  n_from <- nrow(from)
  n_to <- nrow(to)
  params <- list(
    sources = lapply(seq_len(n_from), create_coordinate_list, data = from),
    targets = lapply(seq_len(n_to), create_coordinate_list, data = to),
    costing = costing,
    directions_options = directions_options,
    ...
  )
  json <- vh_get(
    resource = "sources_to_targets",
    from,
    to,
    costing,
    units,
    url = url,
    params = params
  )

  do.call(rbind, lapply(json$sources_to_targets[[1]], function(x) as.data.frame(x))) |>
    # JS indexes from 0. R indexes from 1.
    dplyr::mutate(to_index = to_index + 1) |>
    dplyr::mutate(from_index = from_index + 1) |>
    # pull the coords from the json
    dplyr::mutate(from_lon = from[from_index, 1]) |>
    dplyr::mutate(from_lat = to[from_index, 2]) |>
    dplyr::mutate(to_lon = to[to_index, 1]) |>
    dplyr::mutate(to_lat = to[to_index, 2]) |>
    # remove the indexes
    dplyr::select(-to_index) |>
    dplyr::select(-from_index)
}

create_coordinate_list <- function(data, index) {
  list(lon = data[index, 1], lat = data[index, 2])
}