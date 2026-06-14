import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

List<Marker> buildMarkers({required LatLng office, LatLng? user}) {
  return [
    Marker(
      point: office,
      width: 50,
      height: 25,
      child: const Icon(
        Icons.location_city,
        size: 20,
        color: AppColors.primary,
      ),
    ),
    if (user != null)
      Marker(
        point: user,
        width: 50,
        height: 40,
        child: const Icon(
          Icons.person_pin_circle,
          size: 35,
          color: AppColors.primary,
        ),
      ),
  ];
}
