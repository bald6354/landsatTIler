# landsatTiler
Tiles out landsat data into a fixed grid of smaller stacked images

Current version was written and tested in Matlab Linux 2015b

Requires
1. http://landsat-util.readthedocs.org/en/latest/#
2. GDAL
3. jsonlab for Matlab

Need to convert to Python and take better advantage of landsat-util and remove Matlab requirement

Main script: /matlab/landsatGrid.m

1. Get list of files for download that match AOI
2. Build and execute download script (bostonDownload.sh)
3. Run extraction script (bostonExtractor.sh)
4. Run conversion script (bostonConverter.sh)
5. Run matlab tiler script
