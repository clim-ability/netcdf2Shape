###---### Erstellen des xyz-Vertice-Layers für Nils ###---###

#install.packages("ncdf4") #netCDF-Package
#install.packages("rgdal")
library(ncdf4)
library(rgdal)
#setwd("S:/Daten/Klimatische_Daten/vom_DWD/neu/7 eca diverse Berechnungen/consecutive dry day periods/ens_mean") #working directory, ggf. aendern

### Festlegen der zu lesenden Datei, habe mal die Testdatei von Andreas Walter genommen.
ncpath <- "C:/Code/climability/netcdf2shape"
ncsubpath <- "nc/rx1day"
ncfile <- "eca_rx1day_pr_yearDiff_ensmean_EUR-11_rcp45_day_2021-2050minus1971-2000_bas_rhin_neu.nc"
ncname = paste (ncpath, ncsubpath, ncfile, sep = "/")
nc_file <- nc_open(ncname, write = T)

### Export der Koordinaten (Raster-Zentroide): muessen im Prinzip nur einmal angelegt werden
#und koennen dann fuer alle nc-Dateien wiederverwendet werden (Koords identisch)
lon <- ncvar_get(nc_file, "lon")
lat <- ncvar_get(nc_file, "lat")
lonlat <- project(array(c(lon, lat), dim = c(450, 2), dimnames = list(NULL, c("lon", "lat"))), "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")
#erstellt xy-dataframe und konvertiert Koordinaten in EPSG:25832

### Export der Modellvariable (im bsp. tas = mean surface air temperature)
nc_varname <- nc_file$var[[5]][2]  #"highest_one_day_precipitation_amount_per_time_period"
nc_variable <- data.frame(cddp = as.vector(ncvar_get(nc_file, ncvarname)))
#WICHTIG: tas & "tas" muss an Datei angepasst werden (siehe Kuerzel im netCDF-Dateinamen)

#wenn du nicht sicher bist, wie die nc-Variable heißt benutze...
#print(nc_file$var[[5]][2]) #für das Kürzel und...
#print(nc_file$var[[5]][9]) #für den longname. SOllte eigentlich für alle files so funktionieren

### Kombination von Koordinaten und Variable als shape, CRS wird mitgegeben
nc_spdf <- SpatialPointsDataFrame(lonlat, nc_variable, proj4string = CRS("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"))

### Export der Koordinaten für Vertice-Layer
outDir <- paste(ncpath, "shp", sep="/")
setwd(outDir) #working directory, ggf. aendern
writeOGR(obj=nc_spdf, dsn="cddp", layer="eca_cddp_pr_yearDiff_ensmean_EUR-11_rcp85_day_2071-2100minus1971-2000_bas_rhin_neu.nc", driver="ESRI Shapefile", overwrite = T)
#auch hier: Dateinamen stets anpassen, dsn="nc2csv" ist der Unterordner im wd, in den gespeichert wird