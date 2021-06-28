import 'package:dio/dio.dart';

void sendNotification(title, body, deviceToken, msg_id) async {
  print('notif sent with'+msg_id);
  Response response;
  var dio = Dio();
  response = await dio.post('https://fcm.googleapis.com/fcm/send',
      options: Options(contentType: Headers.jsonContentType, headers: {
        'Authorization':
        'key=AAAApAlpRLw:APA91bEAcC4e2hFp8eLBySFM0EClfC5Vc51Csr8Uc-D0tmR3-f_XWx9hFIb6KZqK_Qa-f86Yq_NddVVNn4-xAVvHecz5hc9dGHoNN5bf3JB9zdpJkYh6qBZSawD0j1Kd5PH5VsCeiPGy'
      }),
      data: {
        "registration_ids": deviceToken,
        "notification": {"title": title, "body": body},
        "data": {"msgId": msg_id}
      })
      .whenComplete(() => print('notif sent'))  ;
}
