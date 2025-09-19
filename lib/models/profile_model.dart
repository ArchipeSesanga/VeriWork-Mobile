class ProfileModel {
  String? name;
  String? employeeId;
  String? departmentId;
  String? email;
  String? phone;
  String? imageUrl;

  ProfileModel({
    this.name,
    this.employeeId,
    this.departmentId,
    this.email,
    this.phone,
    this.imageUrl,
  });

  ProfileModel copyWith({
    String? name,
    String? employeeId,
    String? departmentId,
    String? email,
    String? phone,
    String? imageUrl,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      departmentId: departmentId ?? this.departmentId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}