import 'package:equatable/equatable.dart';

class ImageModel extends Equatable {
  final String id;
  final String url;
  final String? caption;

  const ImageModel({
    required this.id,
    required this.url,
    this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'caption': caption,
    };
  }

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      caption: json['caption'],
    );
  }

  @override
  List<Object?> get props => [id, url, caption];
}
