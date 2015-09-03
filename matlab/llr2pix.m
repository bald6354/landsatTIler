function [px, py] = llr2pix(lat, lon, res, model)
px = (lon - model.minX)./res;
py = (lat - model.minY)./res;
