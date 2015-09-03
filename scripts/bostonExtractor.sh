#!/bin/bash
echo Starting Extraction
for f in /home/wes/landsat/downloads/*.bz;
do 
echo Extracting "$f";
tar -xjf "$f" -C ~/landsat/landsatExtracted;
done
echo Closing Extraction
