import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';


const BASE_URL = "https://1719-197-251-182-126.ngrok.io";



Future<Map<String, dynamic>> authenticate(var shopName, var pin) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST',
      Uri.parse(
          '$BASE_URL/api/v1/mobile/authenticate-vendor-pin'));
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

  var deviceId = await PlatformDeviceId.getDeviceId;
  print("Saving token for (vendor=$vendorId) (device=$deviceId) (token=$token)");


  var headers = {
    'Content-Type': 'application/json',
  };
  var request = http.Request('POST', Uri.parse('$BASE_URL/api/v1/mobile/save-vendor-token'));
  request.body = json.encode({
    "vendorId": vendorId,
    "token": token,
    "deviceId": deviceId
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