import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String, dynamic>> authenticate(var shopName, var pin) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST',
      Uri.parse(
          'https://fe39-102-176-108-112.ngrok.io/api/vendor/authenticate-vendor-pin'));
  request.body = json.encode({"authPin": pin, "shopName": shopName});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var resp = await response.stream.bytesToString();
    return jsonDecode(resp);
  } else {
    print(response.reasonPhrase);
    throw Exception(response.reasonPhrase);
  }
}