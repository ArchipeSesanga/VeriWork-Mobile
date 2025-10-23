import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  String? departmentId;
  String? email;
  String? idNumber;
  String? name;
  String? surname;
  String? password;
  String? phone;
  String? imageUrl;
  String? role;
  String? employeeId;
  String? position;
  bool? isVerified;
  String? verificationStatus;
  DateTime? verificationDate;
  String? address;
  String? city;
  String? country;
  List<String>? documentUrls;

  String? gender;
  DateTime? hireDate;
  String? postalCode;
  String? province;

  ProfileModel({
    this.departmentId,
    this.email,
    this.idNumber,
    this.name,
    this.surname,
    this.password,
    this.phone,
    this.imageUrl,
    this.role,
    this.employeeId,
    this.position,
    this.isVerified,
    this.verificationStatus,
    this.verificationDate,
    this.address,
    this.gender,
    this.hireDate,
    this.postalCode,
    this.province,
  });

  Map<String, dynamic> toMap() {
    return {
      'DepartmentId': departmentId,
      'Email': email,
      'IdNumber': idNumber,
      'Name': name,
      'Surname': surname,
      'Password': password,
      'Phone': phone,
      'PhotoUrl': imageUrl, // Note: Firestore uses PhotoUrl, not ImageUrl
      'Role': role,
      'EmployeeId': employeeId,
      'Position': position,
      'Address': address,
      'City': city,
      'Country': country,
      'DocumentUrls': documentUrls,
      'Gender': gender,
      'HireDate': hireDate,
      'PostalCode': postalCode,
      'Province': province,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      departmentId: map['DepartmentId'],
      email: map['Email'],
      idNumber: map['IdNumber'],
      name: map['Name'],
      surname: map['Surname'],
      password: map['Password'],
      phone: map['Phone'],
      imageUrl: map['PhotoUrl'], // Firestore uses PhotoUrl
      role: map['Role'],
      employeeId: map['EmployeeId'],
      position: map['Position'],
      address: map['Address'],
      gender: map['Gender'],
      hireDate: map['HireDate'] != null
          ? (map['HireDate'] as Timestamp).toDate()
          : null,
      postalCode: map['PostalCode'],
      province: map['Province'],
      isVerified: map['IsVerified'] ?? false,
      verificationStatus: map['VerificationStatus'] ?? 'Pending Review',
      verificationDate: map['VerificationDate'] != null
          ? (map['VerificationDate'] as Timestamp).toDate()
          : null,
    );
  }

  ProfileModel copyWith({
    String? departmentId,
    String? email,
    String? idNumber,
    String? name,
    String? surname,
    String? password,
    String? phone,
    String? imageUrl,
    String? role,
    String? employeeId,
    String? position,
    bool? isVerified,
    String? verificationStatus,
    DateTime? verificationDate,
    String? address,
    String? city,
    String? country,
    List<String>? documentUrls,
    String? emergencyName,
    String? emergencyPhone,
    String? gender,
    DateTime? hireDate,
    String? postalCode,
    String? province,
  }) {
    return ProfileModel(
      departmentId: departmentId ?? this.departmentId,
      email: email ?? this.email,
      idNumber: idNumber ?? this.idNumber,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      position: position ?? this.position,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDate: verificationDate ?? this.verificationDate,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      hireDate: hireDate ?? this.hireDate,
      postalCode: postalCode ?? this.postalCode,
      province: province ?? this.province,
    );
  }
}
