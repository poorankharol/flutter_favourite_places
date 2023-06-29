import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:favourite_places/model/place.dart';
import 'package:favourite_places/screen/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  var _isLoading = false;
  final _dio = Dio();
  PlaceLocation? _pickedLocation;

  String get locationImage {
    if (_pickedLocation == null) {
      return "";
    }
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${_pickedLocation!.latitude},${_pickedLocation!.longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${_pickedLocation!.latitude},${_pickedLocation!.longitude}&key=AIzaSyCqYiks6r7E5FUwM8NDLzx7NiLT2B6ba0Q';
  }

  void _openMap() async {
    final pickerLocation = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(builder: (builder) => const MapScreen()));
    if (pickerLocation == null) {
      return;
    }
    _savePlace(pickerLocation.latitude,pickerLocation.longitude);
  }

  Future<void>  _savePlace(double latitude, double longitude) async {
    Response<String> response = await _dio.get(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyCqYiks6r7E5FUwM8NDLzx7NiLT2B6ba0Q");
    Map data = json.decode(response.data!);
    var address = data['results'][0]['formatted_address'];

    setState(() {
      _isLoading = false;
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      widget.onSelectLocation(_pickedLocation!);
    });
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });

    locationData = await location.getLocation();

    if (locationData.latitude == null || locationData.longitude == null) {
      return;
    }
    _savePlace(locationData.latitude!,locationData.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_pickedLocation != null) {
      content = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isLoading) {
      content = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
            height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: content),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                _getCurrentLocation();
              },
              icon: const Icon(Icons.location_on),
              label: const Text("Get Current Location"),
            ),
            TextButton.icon(
              onPressed: () {
                _openMap();
              },
              icon: const Icon(Icons.map),
              label: const Text("Select on Map"),
            )
          ],
        )
      ],
    );
  }
}
