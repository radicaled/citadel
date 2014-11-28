part of citadel_client;

const int pixelsPerTile = 32;

int toPixels(int tiles) =>
  tiles * pixelsPerTile;
