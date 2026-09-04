class VehicleModel {
  final String id;
  final String serviceType;
  final String driverName;
  final String phone;
  final String whatsappNumber;
  final String driverImage;
  final String vehicleImage;
  final String vehicleNumber;
  final String vehicleType;
  final String address;

  final double latitude;
  final double longitude;

  final DateTime? locationUpdatedAt;

  final List<String> features;

  final double capacityKg;

  final bool isVerified;
  final bool isOnline;

  final String status;

  final double rating;
  final int ratingCount;
  final int totalTrips;

  const VehicleModel({
    required this.id,
    required this.serviceType,
    required this.driverName,
    required this.phone,
    required this.whatsappNumber,
    required this.driverImage,
    required this.vehicleImage,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.locationUpdatedAt,
    required this.features,
    required this.capacityKg,
    required this.isVerified,
    required this.isOnline,
    required this.status,
    required this.rating,
    required this.ratingCount,
    required this.totalTrips,
  });

  factory VehicleModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return VehicleModel(
      id: json['_id']?.toString() ?? '',

      serviceType:
      json['serviceType']?.toString() ??
          '',

      driverName:
      json['driverName']?.toString() ??
          'Unknown Driver',

      phone:
      json['phone']?.toString() ?? '',

      whatsappNumber:
      json['whatsappNumber']
          ?.toString() ??
          '',

      driverImage:
      json['driverImage']?.toString() ??
          '',

      vehicleImage:
      json['vehicleImage']?.toString() ??
          '',

      vehicleNumber:
      json['vehicleNumber']?.toString() ??
          '',

      vehicleType:
      json['vehicleType']?.toString() ??
          '',

      address:
      json['address']?.toString() ?? '',

      latitude: _toDouble(
        json['latitude'],
      ),

      longitude: _toDouble(
        json['longitude'],
      ),

      locationUpdatedAt: _toDateTime(
        json['locationUpdatedAt'],
      ),

      features: _toStringList(
        json['features'],
      ),

      capacityKg: _toDouble(
        json['capacityKg'],
      ),

      isVerified:
      json['isVerified'] == true,

      isOnline:
      json['isOnline'] == true,

      status:
      json['status']?.toString() ??
          'offline',

      rating: _toDouble(
        json['rating'],
      ),

      ratingCount: _toInt(
        json['ratingCount'],
      ),

      totalTrips: _toInt(
        json['totalTrips'],
      ),
    );
  }

  bool get isAvailable {
    return isOnline &&
        status == 'available';
  }

  bool get isBooked {
    return status == 'booked';
  }

  bool get hasLocation {
    return latitude != 0 &&
        longitude != 0;
  }

  bool get isAmbulance {
    return serviceType == 'ambulance';
  }

  bool get isRickshaw {
    return serviceType == 'rickshaw';
  }

  bool get isMazda {
    return serviceType == 'mazda';
  }

  String get displayServiceName {
    switch (serviceType) {
      case 'ambulance':
        return 'Ambulance';

      case 'rickshaw':
        return 'Rickshaw';

      case 'mazda':
        return 'Mazda';

      case 'pickup':
        return 'Pickup';

      case 'truck':
        return 'Truck';

      default:
        return 'Vehicle';
    }
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static List<String> _toStringList(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) => item.toString(),
    )
        .toList();
  }

  static DateTime? _toDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}