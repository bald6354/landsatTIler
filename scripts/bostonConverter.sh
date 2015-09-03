#!/bin/bash
echo Starting Converter
for f in /home/wes/landsat/landsatExtracted/*.TIF;
do 
echo Converting "$f";
echo To "${f%.TIF}_wgs84.TIF";
gdalwarp "$f" "${f%.TIF}_wgs84.TIF" -t_srs "+proj=longlat +ellps=WGS84";
done
echo Closing Converter
