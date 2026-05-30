class FarmImage {
  final int id;
  final String url;
  final String thumbUrl;
  final String? caption;

  const FarmImage({required this.id, required this.url, required this.thumbUrl, this.caption});

  factory FarmImage.fromJson(Map<String, dynamic> j) => FarmImage(
        id: j['id'] as int,
        url: j['url'] as String,
        thumbUrl: j['thumb_url'] as String? ?? j['url'] as String,
        caption: j['caption'] as String?,
      );
}
