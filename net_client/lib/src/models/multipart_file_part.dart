import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/models/file_source.dart';

class MultipartFilePart implements Mappable {
  final String fieldName;

  final String fileName;
  final FileSource source;

  final String? contentType;
  final Map<String, String>? headers;

  const MultipartFilePart({
    required this.fieldName,
    required this.fileName,
    required this.source,
    this.contentType,
    this.headers,
  });

  MultipartFilePart copyWith({
    String? fieldName,
    String? fileName,
    FileSource? source,
    String? contentType,
    Map<String, String>? headers,
  }) {
    return MultipartFilePart(
      fieldName: fieldName ?? this.fieldName,
      fileName: fileName ?? this.fileName,
      source: source ?? this.source,
      contentType: contentType ?? this.contentType,
      headers: headers ?? this.headers,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'fieldName': fieldName,
      'fileName': fileName,
      'source': source.toMap(),
      'contentType': contentType,
      'headers': headers,
    };
  }
}
