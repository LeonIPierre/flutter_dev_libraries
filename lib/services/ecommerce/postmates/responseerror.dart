class PostmatesResponseError {
  final String code;
  final String message;

  PostmatesResponseError(this.code, this.message);

  factory PostmatesResponseError.fromJson(Map<String, dynamic> json) =>
      PostmatesResponseError(json['code'], json['message']);

  @override
  String toString() => '{ code: $code, message: $message }';
}
