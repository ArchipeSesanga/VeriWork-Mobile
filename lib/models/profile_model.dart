import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? uid;
  final String? name;
  final String? surname;
  final String? email;
  final String? employeeId;
  final String? position;
  final String? departmentId;
  final String? role;
  final String? phone;
  final String? verificationStatus;
  final bool? isVerified;
  final String? address;
  final String? city;
  final String? country;
  final String? emergencyName;
  final String? emergencyPhone;
  final List<String>? documentUrls;
  final String? imageUrl;

  ProfileModel({
    this.uid,
    this.name,
    this.surname,
    this.email,
    this.employeeId,
    this.position,
    this.departmentId,
    this.role,
    this.phone,
    this.verificationStatus,
    this.isVerified,
    this.address,
    this.city,
    this.country,
    this.emergencyName,
    this.emergencyPhone,
    this.documentUrls,
    this.imageUrl,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProfileModel.fromMap(data);
  }

  factory ProfileModel.fromMap(Map<String, dynamic> data) {
    // FIX: Safe DocumentUrls handling
    List<String>? documentUrls;
    if (data['DocumentUrls'] != null) {
      if (data['DocumentUrls'] is List) {
        //  Safe conversion with toString() to prevent type errors
        documentUrls = List<String>.from(
            data['DocumentUrls'].map((item) => item.toString()));
      }
    }

    return ProfileModel(
      uid: data['Uid']?.toString() ?? '', //  Added safe string conversion
      name: data['Name']?.toString() ?? '',
      surname: data['Surname']?.toString() ?? '',
      email: data['Email']?.toString() ?? '',
      employeeId:
          data['EmployeeId']?.toString() ?? data['IdNumber']?.toString() ?? '',
      position: data['Position']?.toString() ?? '',
      departmentId: data['DepartmentId']?.toString() ?? '',
      role: data['Role']?.toString() ?? '',
      phone: data['Phone']?.toString() ?? '',
      verificationStatus: data['VerificationStatus']?.toString() ?? 'Pending',
      isVerified: data['IsVerified'] == true ||
          data['IsVerified'] == 'true', //  Handle both bool and string
      address: data['Address']?.toString() ?? '',
      city: data['City']?.toString() ?? '',
      country: data['Country']?.toString() ?? '',
      emergencyName: data['EmergencyName']?.toString() ?? '',
      emergencyPhone: data['EmergencyPhone']?.toString() ?? '',
      documentUrls: documentUrls ?? [], //  Use the safely processed list
      imageUrl:
          data['ImageUrl']?.toString() ?? data['PhotoUrl']?.toString() ?? '',
    );
  }

  // REMOVED copyWith - users can't edit profile
}
