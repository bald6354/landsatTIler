function [tx,ty] = pix2tiles(px, py, model)
tx = px./model.tileSize;
ty = py./model.tileSize;
