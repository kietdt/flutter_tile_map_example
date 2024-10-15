import 'dart:io';

class BResponse {
  final Map<String, dynamic> body;
  int? statusCode;

  BResponse(
    this.body,
    this.statusCode,
  );

  bool get isTimeOut => statusCode == HttpStatus.requestTimeout;
}
