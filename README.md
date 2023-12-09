Vallhala for R
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

This package is based on tests and the demo in the [setup.qmd](setup.md)
file.

## Installation

``` r
devtools::install_github("robinlovelace/rvalhalla")
```

## Usage

``` bash
# download a file to custom_files and start valhalla
mkdir custom_files
wget -O custom_files/andorra-latest.osm.pbf https://download.geofabrik.de/europe/andorra-latest.osm.pbf
docker run -dt --name valhalla_gis-ops -p 8002:8002 -v $PWD/custom_files:/custom_files -e tile_urls=https://download.geofabrik.de/europe/andorra-latest.osm.pbf ghcr.io/gis-ops/docker-valhalla/valhalla:latest
```

After that navigate to <http://localhost:8002/> and you’ll see the
endpoint.

``` r
# library(rvalhalla)
devtools::load_all()
#> ℹ Loading rvallhala
```

Let’s calculate a single route in Andorra, between two well known
places: Andorra la Vella and Pas de la Casa.

``` r
andorra_la_vella = c(1.5218, 42.5075)
pas_de_la_casa = c(1.7333, 42.5425)
```

``` r
# Calculate the route
route1 = vh_route(andorra_la_vella, pas_de_la_casa, costing = "pedestrian")
route2 = vh_route(andorra_la_vella, pas_de_la_casafrom = andorra_la_vella, to = pas_de_la_casa, costing = "bicycle")
route3 = vh_route(from = andorra_la_vella, to = pas_de_la_casa, costing = "bicycle", costing_options = list(bicycle = list(use_roads = 0.9)))
```

We can compare them with `{waldo}`:

``` r
# waldo::compare(route2, route3)
```

Let’s plot them all with `ggplot2`:

``` r
library(ggplot2)
ggplot() +
  geom_sf(data = route1, color = "red") +
  geom_sf(data = route2, color = "blue") +
  geom_sf(data = route3, color = "green")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />