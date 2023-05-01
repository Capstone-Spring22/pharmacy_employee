// ignore_for_file: public_member_api_docs, sort_constructors_first
class DetailPharmacist {
  String? id;
  String? username;
  String? code;
  String? fullname;
  String? roleId;
  String? roleName;
  String? siteID;
  String? siteName;
  String? phoneNo;
  String? email;
  String? cityID;
  String? districtID;
  String? wardID;
  String? homeNumber;
  String? addressID;
  String? fullyAddress;
  String? imageUrl;
  num? status;
  String? dob;
  num? gender;

  DetailPharmacist(
      {this.id,
      this.username,
      this.code,
      this.fullname,
      this.roleId,
      this.roleName,
      this.siteID,
      this.siteName,
      this.phoneNo,
      this.email,
      this.cityID,
      this.districtID,
      this.wardID,
      this.homeNumber,
      this.addressID,
      this.fullyAddress,
      this.imageUrl,
      this.status,
      this.dob,
      this.gender});

  DetailPharmacist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    code = json['code'];
    fullname = json['fullname'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    siteID = json['siteID'];
    siteName = json['siteName'];
    phoneNo = json['phoneNo'];
    email = json['email'];
    cityID = json['cityID'];
    districtID = json['districtID'];
    wardID = json['wardID'];
    homeNumber = json['homeNumber'];
    addressID = json['addressID'];
    fullyAddress = json['fullyAddress'];
    imageUrl = json['imageUrl'];
    status = json['status'];
    dob = json['dob'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['code'] = code;
    data['fullname'] = fullname;
    data['roleId'] = roleId;
    data['roleName'] = roleName;
    data['siteID'] = siteID;
    data['siteName'] = siteName;
    data['phoneNo'] = phoneNo;
    data['email'] = email;
    data['cityID'] = cityID;
    data['districtID'] = districtID;
    data['wardID'] = wardID;
    data['homeNumber'] = homeNumber;
    data['addressID'] = addressID;
    data['fullyAddress'] = fullyAddress;
    data['imageUrl'] = imageUrl;
    data['status'] = status;
    data['dob'] = dob;
    data['gender'] = gender;
    return data;
  }

  @override
  String toString() {
    return 'DetailPharmacist(id: $id, username: $username, code: $code, fullname: $fullname, roleId: $roleId, roleName: $roleName, siteID: $siteID, siteName: $siteName, phoneNo: $phoneNo, email: $email, cityID: $cityID, districtID: $districtID, wardID: $wardID, homeNumber: $homeNumber, addressID: $addressID, fullyAddress: $fullyAddress, imageUrl: $imageUrl, status: $status, dob: $dob, gender: $gender)';
  }
}
