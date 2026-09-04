class AmbulanceModel {
  final String id;
  final String driverName;
  final String driverPhone;
  final String whatsappNumber;
  final String driverImage;
  final String ambulanceImage;
  final String vehicleNumber;
  final String ambulanceType;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final List<String> facilities;
  final bool isVerified;
  final double rating;
  final int ratingCount;
  final int totalTrips;

  AmbulanceModel({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.whatsappNumber,
    required this.driverImage,
    required this.ambulanceImage,
    required this.vehicleNumber,
    required this.ambulanceType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.facilities,
    required this.isVerified,
    required this.rating,
    required this.ratingCount,
    required this.totalTrips,
  });

  factory AmbulanceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AmbulanceModel(
      id: json['_id']?.toString() ?? '',

      driverName:
      json['driverName']?.toString() ?? '',

      driverPhone:
      json['phone']?.toString() ??
          json['driverPhone']?.toString() ??
          '',

      whatsappNumber:
      json['whatsappNumber']?.toString() ??
          json['phone']?.toString() ??
          '',

      driverImage:
      json['driverImage']?.toString() ?? '',

      ambulanceImage:
      json['ambulanceImage']?.toString() ?? '',

      vehicleNumber:
      json['vehicleNumber']?.toString() ?? '',

      ambulanceType:
      json['ambulanceType']?.toString() ??
          'Basic Life Support',

      address:
      json['address']?.toString() ??
          'Location not available',

      latitude:
      double.tryParse(
        json['latitude']?.toString() ?? '',
      ) ??
          0,

      longitude:
      double.tryParse(
        json['longitude']?.toString() ?? '',
      ) ??
          0,

      status:
      json['status']?.toString() ?? 'offline',

      facilities: json['facilities'] is List
          ? List<String>.from(
        json['facilities'].map(
              (item) => item.toString(),
        ),
      )
          : <String>[],

      isVerified: json['isVerified'] == true,

      rating:
      double.tryParse(
        json['rating']?.toString() ?? '',
      ) ??
          0,

      ratingCount:
      int.tryParse(
        json['ratingCount']?.toString() ?? '',
      ) ??
          0,

      totalTrips:
      int.tryParse(
        json['totalTrips']?.toString() ?? '',
      ) ??
          0,
    );
  }
}