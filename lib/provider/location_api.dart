import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import '../models/place.dart';

class Delay {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Delay({required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class LocationApi extends ChangeNotifier {
  List<Place> places = [];
  List<Place> savedPlaces = []; // Danh sách vị trí được lưu
  var addressController = TextEditingController();
  var _delay = Delay(milliseconds: 500);
  final _controller = StreamController<List<Place>>.broadcast();
  Stream<List<Place>> get controllerOut =>
      _controller.stream.asBroadcastStream();
  StreamSink<List<Place>> get controllerIn => _controller.sink;

  /// Thêm Place vào danh sách tìm kiếm
  void addPlace(Place place) {
    places.add(place);
    controllerIn.add(places);
    notifyListeners();
  }

  /// Lưu một Place vào danh sách savedPlaces
  void savePlace(Place place) {
    if (!savedPlaces.contains(place)) {
      savedPlaces.add(place);
      notifyListeners();
      print("Place saved: ${place.name}, ${place.street}");
    } else {
      print("Place already saved: ${place.name}, ${place.street}");
    }
  }

  /// Lưu địa điểm từ TextField
  void saveCurrentLocation() {
    final currentText = addressController.text;
    if (currentText.isEmpty) {
      print("No location to save");
      return;
    }

    final matchingPlace = places.firstWhere(
      (place) =>
          currentText.contains(place.name) &&
          currentText.contains(place.street) &&
          currentText.contains(place.country),
      orElse: () => Place(
        name: "Unknown",
        street: "Unknown",
        country: "Unknown",
        locality: "Unknown",
      ),
    );

    savePlace(matchingPlace);
  }

  /// Xử lý tìm kiếm địa điểm
  void handleSearch(String query) async {
    if (query.length > 3) {
      _delay.run(() async {
        try {
          print("Searching for: $query");
          List<Location> locations = await locationFromAddress(query);
          print("Locations: $locations");
          if (locations.isEmpty) {
            print("No locations found for query: $query");
            return;
          }

          places.clear(); // Xóa dữ liệu cũ
          for (var location in locations) {
            print("Location: ${location.latitude}, ${location.longitude}");
            List<Placemark> placeMarks = await placemarkFromCoordinates(
                location.latitude, location.longitude);
            print("PlaceMarks: $placeMarks");
            for (var placeMark in placeMarks) {
              addPlace(Place(
                name: placeMark.name ?? '',
                street: placeMark.street ?? '',
                locality: placeMark.locality ?? '',
                country: placeMark.country ?? '',
              ));
            }
          }
        } catch (e) {
          print("Error during search: $e");
        }
      });
    } else {
      print("Query too short: $query");
      places.clear();
      controllerIn.add(places); // Xóa dữ liệu trong Stream
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}
