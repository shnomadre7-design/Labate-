import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash.dart';
import 'economy.dart';
import 'army.dart';
import 'network.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // إجبار التطبيق على العمل بالعرض (Landscape) فقط
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const CastleWarApp());
  });
}

class CastleWarApp extends StatelessWidget {
  const CastleWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حرب القلعة',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.amber,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final ipController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('حرب القلعة - الشبكة المحلية'), centerTitle: true),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: true))),
              child: const Text('إنشاء معركة (أنت القلعة)', style: TextStyle(fontSize: 20)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل IP صاحب القلعة...',
                      filled: true,
                      fillColor: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: () {
                    if (ipController.text.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(isHost: false, hostIP: ipController.text)));
                    }
                  },
                  child: const Text('الانضمام كـ مملكة', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isHost;
  final String? hostIP;
  const GameScreen({super.key, required this.isHost, this.hostIP});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late EconomyManager economy;
  late ArmyManager army;
  late NetworkManager network;
  
  String connectionStatus = "جاري إعداد الشبكة...";
  int castleHealth = 1000;
  String castleOwner = "محايدة";

  @override
  void initState() {
    super.initState();
    economy = EconomyManager(onUpdate: () => setState(() {}));
    army = ArmyManager(onUpdate: () => setState(() {}));
    network = NetworkManager(onMessageReceived: handleNetworkMessage);
    
    economy.startEarning();

    if (widget.isHost) {
      network.startHost();
    } else {
      network.joinGame(widget.hostIP!);
    }
  }
  
  void handleNetworkMessage(String msg) {
    setState(() {
      if (msg.startsWith("HOST_IP:")) {
        connectionStatus = "الـ IP الخاص بك: ${msg.split(":")[1]} (أعطه لأصدقائك)";
      } else if (msg == "CONNECTED") {
        connectionStatus = "متصل بالقلعة وجاهز للهجوم!";
      } else if (msg == "CONNECTION_FAILED") {
        connectionStatus = "فشل الاتصال! تأكد من الـ IP والشبكة.";
      } else if (msg.startsWith("ATTACK:")) {
        // استلام جيش من لاعب آخر
        int incomingTroops = int.parse(msg.split(":")[1]);
        castleHealth -= (incomingTroops * 5); // كل جندي ينقص 5 من صحة القلعة
        if (castleHealth <= 0) {
          castleHealth = 0;
          castleOwner = "تم الاحتلال!";
        }
      }
    });
  }

  @override
  void dispose() {
    economy.stopEarning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // القسم الأيسر: ساحة المعركة (65% من الشاشة)
            Expanded(
              flex: 65,
              child: Container(
                color: const Color(0xFF2E4D34), // لون عشبي لساحة المعركة
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(top: 5, child: Text(connectionStatus, style: const TextStyle(backgroundColor: Colors.black87, color: Colors.white, padding: EdgeInsets.all(5)))),
                    
                    // القلعة المركزية
                    Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(color: Colors.grey[850], border: Border.all(color: Colors.amber, width: 4), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.castle, size: 45, color: Colors.amber),
                          Text(castleOwner, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("صحة: $castleHealth", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    // الممالك الأربعة
                    Positioned(top: 20, left: 20, child: kingdomAvatar("مملكة 1", Colors.blue)),
                    Positioned(top: 20, right: 20, child: kingdomAvatar("مملكة 2", Colors.red)),
                    Positioned(bottom: 20, left: 20, child: kingdomAvatar("مملكة 3", Colors.purple)),
                    Positioned(bottom: 20, right: 20, child: kingdomAvatar("مملكة 4", Colors.orange)),
                  ],
                ),
              ),
            ),
            
            // القسم الأيمن: لوحة التحكم (35% من الشاشة)
            Expanded(
              flex: 35,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('الدراهم: ${economy.coins} 💰', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('(+${economy.coinsPerSecond}/ثانية)', style: const TextStyle(color: Colors.grey)),
                    const Divider(color: Colors.white30),
                    Text('الجيش المجهز: ${army.troops} ⚔️', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: economy.upgradeEconomy,
                          child: const Text('تطوير\n(50)', textAlign: TextAlign.center),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: () {
                            army.buyTroops(10, (cost) {
                              if (economy.coins >= cost) { economy.coins -= cost; return true; }
                              return false;
                            });
                          },
                          child: const Text('شراء\n(10)', textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                        onPressed: widget.isHost ? null : () { // صاحب القلعة لا يهاجم نفسه حالياً
                          if (army.troops > 0) {
                            int sent = army.sendTroops();
                            network.sendData("ATTACK:$sent");
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال $sent جندي للقلعة!'), duration: const Duration(seconds: 1)));
                          }
                        },
                        child: const Text('إرسال للهجوم! 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget kingdomAvatar(String name, Color color) {
    return Column(
      children: [
        Icon(Icons.shield, color: color, size: 35),
        Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
