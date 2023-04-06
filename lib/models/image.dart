class ImageModel {
  String? id;
  String? imageURL;

  ImageModel({this.id, this.imageURL});

  ImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageURL = json['imageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imageURL'] = imageURL;
    return data;
  }

  @override
  String toString() => 'ImageModel(id: $id, imageURL: $imageURL)';
}
