import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/tree.dart';
import '../l10n/l10n.dart';

Color markerColor(int daysToHarvest) {
  if (daysToHarvest <= 14) return Colors.red;
  if (daysToHarvest <= 30) return Colors.orange;
  return Colors.green;
}

BitmapDescriptor markerIcon(int daysToHarvest) {
  final hue = daysToHarvest <= 14
      ? BitmapDescriptor.hueRed
      : daysToHarvest <= 30
          ? BitmapDescriptor.hueOrange
          : BitmapDescriptor.hueGreen;
  return BitmapDescriptor.defaultMarkerWithHue(hue);
}

Marker buildTreeMarker({
  required AppLocalizations l10n,
  required TreeDashboard tree,
  required VoidCallback onTap,
}) {
  final harvestLabel = tree.earliestHarvestDate != null
      ? DateFormat('d MMM', l10n.localeName).format(tree.earliestHarvestDate!)
      : l10n.treeMarkerNoFruit;

  return Marker(
    markerId: MarkerId(tree.treeNumber),
    position: LatLng(tree.gpsLat!, tree.gpsLng!),
    icon: markerIcon(tree.daysToHarvest),
    infoWindow: InfoWindow(
      title: tree.treeNumber,
      snippet: l10n.treeMarkerSnippet(tree.fruitCount, harvestLabel),
    ),
    onTap: onTap,
  );
}
