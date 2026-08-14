import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash.dart';
import 'economy.dart';
import 'army.dart';
import 'network.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFF14181D),
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
      appBar: AppBar(
        title: const Text('حرب القلعة - الشبكة المحلية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F242C),
        elevation: 0,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6A23C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.castle, size: 28),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: true))),
              child: const Text('إنشاء معركة (أنت القلعة)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E232B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: ipController,
                      decoration: InputDecoration(
                        hintText: 'أدخل IP صاحب القلعة...',
                        filled: true,
                        fillColor: const Color(0xFF14181D),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF409EFF),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (ipController.text.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(isHost: false, hostIP: ipController.text)));
                      }
                    },
                    child: const Text('الانضمام كـ مملكة', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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
  final int maxCastleHealth = 1000;
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
        connectionStatus = "IP الخاص بك: ${msg.split(":")[1]} (أعطه لأصدقائك)";
      } else if (msg == "CONNECTED") {
        connectionStatus = "متصل بالقلعة وجاهز للهجوم!";
      } else if (msg == "CONNECTION_FAILED") {
        connectionStatus = "فشل الاتصال! تأكد من الـ IP والشبكة.";
      } else if (msg.startsWith("ATTACK:")) {
        int incomingTroops = int.parse(msg.split(":")[1]);
        castleHealth -= (incomingTroops * 5);
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
            // القسم الأيسر: ساحة المعركة
            Expanded(
              flex: 68,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: [Color(0xFF2C3E2D), Color(0xFF162217)],
                  ),
                ),
                child: Stack(
                  children: [
                    // شريط الحالة العلوي
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_tethering, size: 16, color: Colors.greenAccent),
                            const SizedBox(width: 8),
                            Text(
                              connectionStatus,
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // القلعة المركزية
                    Center(
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21252D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withAlpha(200), width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withAlpha(40), blurRadius: 15, spreadRadius: 2),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.castle, size: 40, color: Colors.amber),
                            const SizedBox(height: 4),
                            Text(castleOwner, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (castleHealth / maxCastleHealth).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  castleHealth > 300 ? Colors.greenAccent : Colors.redAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("$castleHealth / $maxCastleHealth", style: const TextStyle(color: Colors.white60, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                    // الممالك الأربعة في الزوايا
                    Positioned(top: 50, left: 16, child: kingdomAvatar("مملكة 1", const Color(0xFF409EFF))),
                    Positioned(top: 50, right: 16, child: kingdomAvatar("مملكة 2", const Color(0xFFF56C6C))),
                    Positioned(bottom: 16, left: 16, child: kingdomAvatar("مملكة 3", const Color(0xFF9B59B6))),
                    Positioned(bottom: 16, right: 16, child: kingdomAvatar("مملكة 4", const Color(0xFFE6A23C))),
                  ],
                ),
              ),
            ),
            
            // القسم الأيمن: لوحة التحكم والعمليات
            Expanded(
              flex: 32,
              child: Container(
                color: const Color(0xFF1A1F26),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    // بطاقة الموارد
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14181D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('💰', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text('${economy.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                            ],
                          ),
                          Text('(+${economy.coinsPerSecond}/ث)', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // بطاقة الجيش
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14181D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Text('⚔️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          const Text('الجيش المجهز:', style: TextStyle(fontSize: 13, color: Colors.white70)),
                          const Spacer(),
                          Text('${army.troops}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    
                    const Spacer(),

                    // أزرار التطوير والشراء
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: economy.upgradeEconomy,
                            child: const Text('تطوير دخل\n(50 💰)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              army.buyTroops(10, (cost) {
                                if (economy.coins >= cost) {
                                  economy.coins -= cost;
                                  return true;
                                }
                                return false;
                              });
                            },
                            child: const Text('تجنيد +10\n(10 💰)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // زر الهجوم الكبير
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6A23C),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 20),
                        onPressed: widget.isHost ? null : () {
                          if (army.troops > 0) {
                            int sent = army.sendTroops();
                            network.sendData("ATTACK:$sent");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم إرسال $sent جندي للقلعة!'),
                                duration: const Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        label: const Text('إرسال للهجوم!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26).withAlpha(220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withAlpha(30), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: color, size: 28),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
