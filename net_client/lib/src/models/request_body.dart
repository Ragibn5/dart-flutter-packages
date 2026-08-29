import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/models/multipart_file_part.dart';
import 'package:net_client/src/models/raw_data.dart';

sealed class RequestBody implements Mappable {
  final String contentType;

  const RequestBody({required this.contentType});
}

final class RawBody extends RequestBody {
  final RawData data;

  const RawBody(this.data, {required super.contentType});

  RawBody copyWith({
    RawData? data,
    String? contentType,
  }) {
    return RawBody(
      data ?? this.data,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'data': data.toMap()};
  }
}

final class JsonBody extends RequestBody {
  final Map<String, dynamic> data;

  const JsonBody(this.data, {super.contentType = 'application/json'});

  JsonBody copyWith({
    Map<String, dynamic>? data,
    String? contentType,
  }) {
    return JsonBody(
      data ?? this.data,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'data': data};
  }
}

final class FormUrlEncodedBody extends RequestBody {
  final Map<String, String> fields;

  const FormUrlEncodedBody(
    this.fields, {
    super.contentType = 'application/x-www-form-urlencoded',
  });

  FormUrlEncodedBody copyWith({
    Map<String, String>? fields,
    String? contentType,
  }) {
    return FormUrlEncodedBody(
      fields ?? this.fields,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'fields': fields};
  }
}

final class MultipartBody extends RequestBody {
  final Map<String, String> fields;
  final List<MultipartFilePart> files;

  const MultipartBody(
    this.fields,
    this.files, {
    super.contentType = 'multipart/form-data',
  });

  MultipartBody copyWith({
    Map<String, String>? fields,
    List<MultipartFilePart>? files,
    String? contentType,
  }) {
    return MultipartBody(
      fields ?? this.fields,
      files ?? this.files,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'fields': fields, 'files': files.map((e) => e.toMap())};
  }
}
