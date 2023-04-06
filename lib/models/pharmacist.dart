// ignore_for_file: public_member_api_docs, sort_constructors_first
class Pharmacist {
  String? id;
  String? name;
  String? email;
  int? status;
  String? roleName;
  String? roleId;
  String? token;
  String? imageURL;

  Pharmacist(
      {this.id,
      this.name,
      this.email,
      this.status,
      this.roleName,
      this.roleId,
      this.token,
      this.imageURL});

  Pharmacist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    status = json['status'];
    roleName = json['roleName'];
    roleId = json['roleId'];
    token = json['token'];
    imageURL = json['imageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['status'] = status;
    data['roleName'] = roleName;
    data['roleId'] = roleId;
    data['token'] = token;
    data['imageURL'] = imageURL;
    return data;
  }

  @override
  String toString() {
    return 'Pharmacist(id: $id, name: $name, email: $email, status: $status, roleName: $roleName, roleId: $roleId, token: $token, imageURL: $imageURL)';
  }
}
