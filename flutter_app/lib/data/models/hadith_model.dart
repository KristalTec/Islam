class HadithModel {
  final int id;
  final String book;
  final String bookName;
  final String arabic;
  final String kurdish;
  final String ref;

  const HadithModel({
    required this.id,
    required this.book,
    required this.bookName,
    required this.arabic,
    required this.kurdish,
    required this.ref,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] as int? ?? 0,
      book: json['book'] as String? ?? '',
      bookName: json['bookName'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      kurdish: json['kurdish'] as String? ?? '',
      ref: json['ref'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book': book,
        'bookName': bookName,
        'arabic': arabic,
        'kurdish': kurdish,
        'ref': ref,
      };
}
