import 'dart:io';
import 'dart:convert';
import 'dart:async';

class NetworkManager {
  ServerSocket? serverSocket;
  Socket? clientSocket;
  final Function(String) onMessageReceived;
  bool isServer = false;

  NetworkManager({required this.onMessageReceived});

  // جلب رقم الـ IP الخاص بالهاتف ليعطيه صاحب الغرفة لأصدقائه
  Future<String> getLocalIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      return "خطأ في جلب الـ IP";
    }
    return "127.0.0.1";
  }

  // تشغيل الخادم (صاحب القلعة المركزية)
  Future<void> startHost() async {
    isServer = true;
    String ip = await getLocalIP();
    onMessageReceived("HOST_IP:$ip"); // إرسال الـ IP للشاشة ليعرضه للاعبين
    
    // فتح منفذ 8080 لاستقبال اتصالات الأصدقاء
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
    serverSocket!.listen((Socket client) {
      client.listen((List<int> data) {
        final message = utf8.decode(data);
        onMessageReceived(message); // استلام هجمات اللاعبين
      });
    });
  }

  // الانضمام كلاعب (مملكة مهاجمة)
  Future<void> joinGame(String ip) async {
    isServer = false;
    try {
      clientSocket = await Socket.connect(ip, 8080);
      clientSocket!.listen((List<int> data) {
        final message = utf8.decode(data);
        onMessageReceived(message);
      });
      onMessageReceived("CONNECTED");
    } catch (e) {
      onMessageReceived("CONNECTION_FAILED");
    }
  }

  // إرسال جيش أو رسالة
  void sendData(String message) {
    if (!isServer && clientSocket != null) {
      clientSocket!.add(utf8.encode(message));
    }
  }
}
