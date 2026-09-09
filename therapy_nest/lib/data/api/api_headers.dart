/// HTTP header builders for API requests.
class ApiHeaders {
  ApiHeaders._();

  static Map<String, String> json() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> auth(String token) => {
        ...json(),
        'Authorization': 'Bearer $token',
      };
}
