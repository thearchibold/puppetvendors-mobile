import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:puppetvendors_mobile/services/constants.dart';


var base_url = AppConstants.APP_URL;



Future authenticate(var shopName, var pin) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST',
      Uri.parse(
          '$base_url/api/v1/mobile/authenticate-vendor-pin'));
  request.body = json.encode({"authPin": pin, "shopName": shopName});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var resp = await response.stream.bytesToString();
    return jsonDecode(resp);
  } else {
    throw Exception(response.reasonPhrase);
  }
}

void saveVendorToken(var vendorId, var token) async {

  if(GetStorage().read("token") == token)
    return;

  var deviceId = await PlatformDeviceId.getDeviceId;
  print("Saving token for (vendor=$vendorId) (device=$deviceId) (token=$token)");


  var headers = {
    'Content-Type': 'application/json',
  };
  var request = http.Request('POST', Uri.parse('$base_url/api/v1/mobile/save-vendor-token'));
  request.body = json.encode({
    "vendorId": vendorId,
    "token": token,
    "deviceId": deviceId
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
    GetStorage().write("token", token);
  }
  else {
    print(response.reasonPhrase);
  }


}