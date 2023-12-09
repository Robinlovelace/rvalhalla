# Benchmarks

``` r
remotes::install_cran("opentripplanner")
```

    Skipping install of 'opentripplanner' from a cran remote, the SHA1 (0.5.1) has not changed since last install.
      Use `force = TRUE` to force installation

``` r
library(opentripplanner)
library(sf)
```

    Linking to GEOS 3.11.1, GDAL 3.6.4, PROJ 9.1.1; sf_use_s2() is TRUE

``` r
knitr::opts_chunk$set(eval = FALSE)
```

# opentripplanner

OTP relies on Java 17, which can be installed on Ubuntu as follows:

``` bash
sudo apt install openjdk-17-jdk
# Set the version of Java to use:
sudo update-alternatives --config java
```

``` r
library(opentripplanner)
# Path to a folder containing the OTP.jar file, change to where you saved the file.
path_data <- file.path(tempdir(), "OTP")
dir.create(path_data)
path_otp <- otp_dl_jar(version = "2.2.0")
otp_dl_demo(path_data)
# Build Graph and start OTP
log1 <- otp_build_graph(otp = path_otp, dir = path_data)
log2 <- otp_setup(otp = path_otp, dir = path_data)
otpcon <- otp_connect(timezone = "Europe/London")
```

Following the routing tutorial in
[github.com/itsleeds/TDS](https://github.com/ITSLeeds/TDS/blob/ff0c7346d2f872539faae11224aaa76b79e8c2b6/practicals/6-routing.Rmd),
let’s generate some routes:

``` r
u = "https://github.com/ITSLeeds/TDS/releases/download/22/NTEM_flow.geojson"
desire_lines = read_sf(u)
desire_lines = desire_lines[1:9, ]
fromPlace <- lwgeom::st_startpoint(desire_lines)
toPlace <- lwgeom::st_endpoint(desire_lines)
fromPlace <- st_sf(data.frame(id = desire_lines$from, geometry = fromPlace))
toPlace <- st_sf(data.frame(id = desire_lines$to, geometry = toPlace))
```

Calculate a route as follows:

``` r
route <- otp_plan(otpcon, 
                  fromPlace = c(-1.17502, 50.64590), 
                  toPlace = c(-1.15339, 50.72266))
```

Calculate all routes as follows:

We can do the same with rvalhalla as follows:

``` r
library(osmextract)
iow_url = oe_match("Isle of Wight")
iow_url
dir.create("custom_files_iow", showWarnings = FALSE)
oe_download(
  file_url = iow_url$url,
  file_size = iow_url$file_size,
  download_directory = "custom_files_iow/",
  file_basename = "isle_of_wight"
)
```

``` bash
# Stop the running container:
docker stop valhalla_gis-ops
# Remove the container:
docker rm valhalla_gis-ops
docker rmi ghcr.io/gis-ops/docker-valhalla/valhalla:latest
docker run -dt --name valhalla_gis-ops -p 8002:8002 -v $PWD/custom_files:/custom_files -e tile_urls=https://download.geofabrik.de/europe/great-britain/england/isle-of-wight-latest.osm.pbf ghcr.io/gis-ops/docker-valhalla/valhalla:latest
```

``` r
devtools::load_all()
library(rvalhalla)
route_vh = vh_route(c(-1.17502, 50.64590), c(-1.15339, 50.72266), costing = "pedestrian")
plot(route_vh)
```

``` r
bench = bench::mark(check = FALSE,
  otp = otp_plan(otpcon, 
                  fromPlace = c(-1.17502, 50.64590), 
                  toPlace = c(-1.15339, 50.72266)),
  rvalhalla = vh_route(c(-1.17502, 50.64590), c(-1.15339, 50.72266), costing = "pedestrian")
)
readr::write_csv(bench[c(1, 4, 5)], "bench.csv")
```

``` r
knitr::kable(readr::read_csv("bench.csv"))
```

    Rows: 2 Columns: 3
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: ","
    chr (2): expression, mem_alloc
    dbl (1): itr/sec

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

| expression |  itr/sec | mem_alloc |
|:-----------|---------:|:----------|
| otp        | 22.40628 | 639KB     |
| rvalhalla  | 83.47717 | 110KB     |
