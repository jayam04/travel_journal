import 'package:geocoding/geocoding.dart';

Future<String?> getCityAndCountry(double latitude, double longitude) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  if (placemarks.isNotEmpty) {
    String city = placemarks.first.locality ?? 'Unknown city';
    String country = placemarks.first.country ?? 'Unknown country';
    return '$city, $country';
  }

  return null;
}
