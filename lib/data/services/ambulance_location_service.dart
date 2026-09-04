import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/storage/storage_service.dart';

class AmbulanceLocationService {
  static const String baseUrl =
      'http://localhost:5000/api';

  final StorageService storage =
  Get.find<StorageService>();

  StreamSubscription<Position>?
  _positionSubscription;

  bool _isSendingLocation = false;

  bool get isTracking =>
      _positionSubscription != null;

  // =========================
  // START LIVE TRACKING
  // =========================

  Future<void> startTracking({
    required String ambulanceId,
    String serviceType = 'ambulance',
    required void Function(Position position)
    onLocationUpdated,
    required void Function(String message)
    onError,
  }) async {
    if (isTracking) return;

    try {
      final bool serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Device location بند ہے۔ '
              'پہلے Location آن کریں',
        );
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (
      permission ==
          LocationPermission.denied
      ) {
        permission =
        await Geolocator
            .requestPermission();
      }

      if (
      permission ==
          LocationPermission.denied
      ) {
        throw Exception(
          'Live tracking کے لیے '
              'Location permission ضروری ہے',
        );
      }

      if (
      permission ==
          LocationPermission.deniedForever
      ) {
        throw Exception(
          'Location permission permanently '
              'بند ہے۔ Settings سے اجازت دیں',
        );
      }

      // Tracking شروع ہوتے ہی پہلی location بھیجیں
      final Position currentPosition =
      await Geolocator
          .getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await _sendLocation(
        ambulanceId: ambulanceId,
        serviceType: serviceType,
        position: currentPosition,
      );

      onLocationUpdated(currentPosition);

      // تقریباً 20 میٹر حرکت پر نئی location
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings:
            const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen(
                (Position position) {
              _handleNewPosition(
                ambulanceId: ambulanceId,
                position: position,
                onLocationUpdated:
                onLocationUpdated,
                onError: onError,
              );
            },
            onError: (Object error) {
              onError(
                error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
              );
            },
          );
    } catch (error) {
      await stopTracking();

      onError(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> _handleNewPosition({
    required String ambulanceId,
    required String serviceType,
    required Position position,
    required void Function(Position position)
    onLocationUpdated,
    required void Function(String message)
    onError,
  }) async {
    try {
      await _sendLocation(
        ambulanceId: ambulanceId,
        serviceType: serviceType,
        position: position,
      );

      onLocationUpdated(position);
    } catch (error) {
      onError(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================
  // SEND LOCATION TO BACKEND
  // =========================

  Future<void> _sendLocation({
    required String ambulanceId,
    required Position position,
  }) async {
    if (_isSendingLocation) return;

    _isSendingLocation = true;

    try {
      final String? token =
      storage.readToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token is missing',
        );
      }

      final http.Response response =
      await http.patch(
        Uri.parse(
          serviceType == 'ambulance'
              ? '$baseUrl/ambulances/$ambulanceId/location'
              : '$baseUrl/vehicles/$ambulanceId/location',
        ),
        headers: {
          'Authorization':
          'Bearer $token',
          'Content-Type':
          'application/json',
        },
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      Map<String, dynamic> body = {};

      try {
        body = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Server returned an invalid response',
        );
      }

      if (response.statusCode != 200 ||
          body['success'] != true) {
        throw Exception(
          body['message'] ??
              'Live location update نہیں ہوسکی',
        );
      }
    } finally {
      _isSendingLocation = false;
    }
  }

  // =========================
  // STOP LIVE TRACKING
  // =========================

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isSendingLocation = false;
  }
}