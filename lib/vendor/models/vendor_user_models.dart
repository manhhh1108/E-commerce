class VendorUserModel {
  final bool apporoved;
  final String? vendorId;
  final String? businessName;
  final String? email;
  final String? phoneNumber;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;
  final String? storeImage;
  final String? taxNumber;
  final String? taxRegistered;

  VendorUserModel(
      {required this.apporoved,
      required this.vendorId,
      required this.businessName,
      required this.email,
      required this.phoneNumber,
      required this.countryValue,
      required this.stateValue,
      required this.cityValue,
      required this.storeImage,
      required this.taxNumber,
      required this.taxRegistered});

  VendorUserModel.fromJson(Map<String, dynamic> json)
      : apporoved = json['approved'] as bool? ?? false,
        vendorId = json['vendorId'] as String?,
        businessName = json['businessName'] as String?,
        email = json['email'] as String?,
        phoneNumber = json['phoneNumber'] as String?,
        countryValue = json['countryValue'] as String?,
        stateValue = json['stateValue'] as String?,
        cityValue = json['cityValue'] as String?,
        storeImage = json['image'] as String?, // Sửa tên trường nếu cần
        taxNumber = json['taxNumber'] as String?,
        taxRegistered = json['taxRegistered'] as String?;

  Map<String, dynamic> toJson() {
    return {
      'apporoved': apporoved,
      'vendorId': vendorId,
      'businessName': businessName,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryValue': countryValue,
      'stateValue': stateValue,
      'cityValue': cityValue,
      'storeImage': storeImage,
      'taxRegistered': taxRegistered,
      'taxNumber': taxNumber,
    };
  }
}
