import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Map<String, String>> getAddressFromLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return {};
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, return empty.
      return {};
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, return empty.
    return {};
  }

  // If we reach here, permissions are granted and we can get the position.
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  // Reverse geocode the coordinates.
  List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude);

  if (placemarks.isNotEmpty) {
    Placemark place = placemarks.first;
    print('Placemark Data:');
    print('Name: ${place.name}');
    print('Locality: ${place.locality}');
    print('SubLocality: ${place.subLocality}');
    print('Admin Area: ${place.administrativeArea}');
    print('SubAdmin Area: ${place.subAdministrativeArea}');
    print('Country: ${place.country}');
    print('Postal Code: ${place.postalCode}');
    print('ISO Country Code: ${place.isoCountryCode}');
    print('Thoroughfare: ${place.thoroughfare}');
    print('SubThoroughfare: ${place.subThoroughfare}');
    String village =  place.subLocality ?? ''; // Use subLocality or fallback to locality
    String taluka = place.thoroughfare ?? ''; // Attempt to get the taluka
    String district = place.locality ?? ''; // Get the district

    return {
      'village': village,
      'taluka': taluka,
      'district': district,
    };
  }

  return {};
}
