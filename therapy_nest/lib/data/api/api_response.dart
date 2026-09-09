/// Generic response wrapper for API results.
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool isSuccess;

  const ApiResponse._({
    this.data,
    required this.statusCode,
    this.message,
    required this.isSuccess,
  });

  factory ApiResponse.success({required T data, int statusCode = 200}) {
    return ApiResponse._(
      data: data,
      statusCode: statusCode,
      isSuccess: true,
    );
  }

  factory ApiResponse.error({required int statusCode, String? message}) {
    return ApiResponse._(
      statusCode: statusCode,
      message: message,
      isSuccess: false,
    );
  }
}
