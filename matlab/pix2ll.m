function [lat, lon] = pix2ll(px, py, res, model)
lon = px.*res + model.minX;
lat = py.*res + model.minY;
