function id = tileID(tx, ty, zoom)
id = tx+ty.*2^zoom;