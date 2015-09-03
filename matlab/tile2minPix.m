function [px, py] = tile2minPix(tx, ty, model)
px = tx*model.tileSize+1;
py = ty*model.tileSize+1;