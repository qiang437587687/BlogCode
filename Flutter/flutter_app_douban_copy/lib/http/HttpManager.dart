import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http ;


typedef InterceptorCallback();
typedef InterceptorErrorCallback(Object e);
typedef InterceptorsSuccessCallback(String body);


void get({@required String url,InterceptorCallback onSend,InterceptorsSuccessCallback onSuccess,InterceptorErrorCallback onError})
async {
  onSend();
  try {
    await http.get(url).then((http.Response response){
      onSuccess(response.body);
    }).catchError(() {
      onError("http get error");
    });
  } catch (e) {
    onError(e);
  }
}