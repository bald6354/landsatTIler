%% Tools for processing landsat data into a fixed grid of stacked images
%landsat-util and all the required packages are needed

%jsonlab for matlab also required
addpath('/home/wes/Dropbox/WesDocs/MATLAB/jsonlab-1.1/jsonlab/')

%% Define a grid similar to MrGeo and based on the Tile Mapping System (TMS) concept described in Tile-Based Geospatial Information Systems - Principles and Practices, John T. Sample & Elias Ioup
model = createModel();

%% Download data from AWS
%Boston
targetLL = [42.348313 -71.083263];

%Get list from AWS - save to json
[status,result] = system(['landsat search --lat ' num2str(targetLL(1)) ' --lon ' num2str(targetLL(2)) ' --limit 1000 >> /tmp/landsat.json']);

%Edit any extra characters from the .json and then load
data = loadjson('/tmp/landsat.json');

%Create a bash script to download all the files
fileID = fopen('bostonDownload.sh','w');
fprintf(fileID,'#!/bin/bash\n');
fprintf(fileID,'%s\n','echo Starting Downloader');
for loop = 1:numel(data.results)
    fprintf(fileID,'%s%d%s\n','echo ', numel(data.results)-loop+1,' files left to download');
    fprintf(fileID,'%s%s\n','echo landsat download ', data.results{loop}.sceneID);
    fprintf(fileID,'%s%s\n','landsat download ', data.results{loop}.sceneID);
    fprintf(fileID,'%s\n','echo Download complete');
end
fprintf(fileID,'%s\n','echo Closing Downloader');
fclose(fileID);

% sh ./bostonDownloader.sh

% Extract .tar.bz
% cd ~/landsat/downloads
% for f in ./*bz; do tar -xjf "$f" -C ~/landsatExtracted; done
% bash script

% Convert utm to wgs84 using gdalwarp
% bash script

%% Process a single landsat geotiff into the grid
inputDir = '/home/wes/landsat/landsatExtracted';
outputDir = '/home/wes/landsat/tiles/B2';
processList = dir([inputDir filesep '*_B2_wgs84.TIF']);

for fLoop = 1:numel(processList)
    
    %Read in data
    inputFile = [inputDir filesep processList(fLoop).name];
    [fp, fn, fe] = fileparts(inputFile);
    fn
    [baseIm, cmap, R, bbox] = geotiffread(inputFile);
    
    %% Chip out tile from an image
    lonVec = single(R(2,1).*[0:(size(baseIm,2)-1)] + R(3,1));
    latVec = single(R(1,2).*[0:(size(baseIm,1)-1)] + R(3,2));
    [lonMesh, latMesh] = meshgrid(lonVec,latVec);
    
    for zoom = model.maxZoom:-1:1
        
        zoomDir = [outputDir filesep num2str(zoom)];
        
        if ~exist(zoomDir, 'dir')
            mkdir(zoomDir)
        end
        
        [pxMin, pyMin] = llr2pix(min(latVec), min(lonVec), zoom2res(zoom,model), model);
        [txMin, tyMin] = pix2tiles(pxMin, pyMin, model);
        txMin = floor(txMin);
        tyMin = floor(tyMin);
        [tLatMin, tLonMin] = pix2ll(txMin*model.tileSize, tyMin*model.tileSize, zoom2res(zoom,model), model);
        
        [pxMax, pyMax] = llr2pix(max(latVec), max(lonVec), zoom2res(zoom,model), model);
        [txMax, tyMax] = pix2tiles(pxMax, pyMax, model);
        txMax = floor(txMax);
        tyMax = floor(tyMax);
        [tLatMax, tLonMax] = pix2ll((txMax+1)*model.tileSize-1, (tyMax+1)*model.tileSize-1, zoom2res(zoom,model), model);
        
        [pxMinI, pyMinI] = tile2minPix(floor(txMin), floor(tyMin), model);
        [pxMaxI, pyMaxI] = tile2maxPix(floor(txMax), floor(tyMax), model);
        
        [pxMeshI, pyMeshI] = meshgrid(single(pxMinI:pxMaxI), single(pyMaxI:-1:pyMinI));
        [latMeshI, lonMeshI] = pix2ll(pxMeshI, pyMeshI, zoom2res(zoom,model), model);
        
        clear pxMeshI pyMeshI
        
        singleImage = interp2(lonMesh, latMesh, single(baseIm), lonMeshI, latMeshI, 'linear', NaN);
        
        clear latMeshI lonMeshI
        
        singleImage(singleImage==0) = NaN;
        
        subplot(121)
        imagesc(singleImage,[7000 11000])
        title(['Zoom: ' num2str(zoom)])
        axis image
        hold on
        pause(.1)
        
        for yLoop = tyMin:tyMax
            for xLoop = txMin:txMax
                disp(['TileID: ' num2str(tileID(xLoop, yLoop, zoom))])
                pxMinChip = model.tileSize*(xLoop - txMin) + 1;
                pxMaxChip = model.tileSize*(xLoop - txMin + 1);
                pyMinChip = size(singleImage,1) - model.tileSize*(yLoop - tyMin + 1) + 1;
                pyMaxChip = size(singleImage,1) - model.tileSize*(yLoop - tyMin);
                tileIm = singleImage(pyMinChip:pyMaxChip,pxMinChip:pxMaxChip);
                subplot(122)
                imagesc(tileIm,[7000 11000])
                axis image
                title(['X:' num2str(xLoop) ' Y:' num2str(yLoop)])
                subplot(121)
                if sum(~isnan(tileIm(:)))
                    %Has data
                    rectangle('Position',[pxMinChip pyMinChip (pxMaxChip-pxMinChip) (pyMaxChip-pyMinChip)],'EdgeColor',[0 1 0])
                    [px, py] = tile2minPix(xLoop, yLoop, model);
                    [minLat, minLon] = pix2ll(px, py, zoom2res(zoom, model), model);
                    R = makerefmat(double(minLon), double(minLat), zoom2res(zoom, model), zoom2res(zoom, model));
                    outPath = [zoomDir filesep num2str(xLoop) filesep num2str(yLoop)];
                    if ~exist(outPath, 'dir')
                        mkdir(outPath)
                    end
                    geotiffwrite([outPath filesep fn], uint16(tileIm), R)
                else
                    %No data
                    rectangle('Position',[pxMinChip pyMinChip (pxMaxChip-pxMinChip) (pyMaxChip-pyMinChip)],'EdgeColor',[1 0 0])
                end
                pause(.1)
            end
        end
        if (zoom ~= 1)
            subplot(121)
            clf
            subplot(122)
            clf
        end
    end
end
