function [px, py] = tile2maxPix(tx, ty, model)
px = (tx+1)*model.tileSize;
py = (ty+1)*model.tileSize;