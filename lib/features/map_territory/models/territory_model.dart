class TerritoryModel {
  final String id;
  final String name;
  final String shortLabel;
  final String description;
  final String landmark;
  final int activeCatsCount;
  final String imageAsset;
  final List<String> residentCatIds;
  final double latitude;
  final double longitude;
  final double mapDx;
  final double mapDy;

  const TerritoryModel({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.description,
    required this.landmark,
    required this.activeCatsCount,
    required this.imageAsset,
    required this.residentCatIds,
    required this.latitude,
    required this.longitude,
    required this.mapDx,
    required this.mapDy,
  });
}
