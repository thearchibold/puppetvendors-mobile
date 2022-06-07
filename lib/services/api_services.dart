import 'dart:convert';
import 'package:http/http.dart' as http;

const BASE_URL = "https://6360-41-210-10-64.ngrok.io";

Future<Map<String, dynamic>> authenticate(var shopName, var pin) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST',
      Uri.parse(
          '$BASE_URL/api/vendor/authenticate-vendor-pin'));
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

void saveVendorToken(var vendorId, var token) async {
  print("Saving token for $vendorId $token");
  var headers = {
    'Content-Type': 'application/json',
  };
  var request = http.Request('POST', Uri.parse('$BASE_URL/api/vendor/save-vendor-token'));
  request.body = json.encode({
    "vendorId": vendorId,
    "token": token
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  }
  else {
    print(response.reasonPhrase);
  }


}