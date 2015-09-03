function res = zoom2res(zoom, model)
res = 180./model.tileSize./(2^(zoom-1));