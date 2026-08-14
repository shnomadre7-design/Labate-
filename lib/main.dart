import 'package:flutter/material.dart';
import 'splash.dart';
import 'economy.dart';
import 'army.dart';

void main() {
  runApp(const CastleWarApp());
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
      home: const SplashScreen(), // جعلنا البداية من شاشة السبلاش
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حرب القلعة - القائمة الرئيسية'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: true))),
              child: const Text('إنشاء معركة (Host)', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: false))),
              child: const Text('الانضمام لمعركة (Join)', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isHost;
  const GameScreen({super.key, required this.isHost});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late EconomyManager economy;
  late ArmyManager army;

  @override
  void initState() {
    super.initState();
    // ربط ملفات الاقتصاد والجيوش بالشاشة
    economy = EconomyManager(onUpdate: () => setState(() {}));
    army = ArmyManager(onUpdate: () => setState(() {}));
    economy.startEarning();
  }

  @override
  void dispose() {
    economy.stopEarning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isHost ? 'القلعة المركزية' : 'مملكة المهاجم')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text('القلعة المركزية\n(مستقرة)', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black45,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('الدراهم: ${economy.coins} 💰\n(+${economy.coinsPerSecond}/ثانية)', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
                      Text('جيوشك: ${army.troops} ⚔️', style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                  const Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: economy.upgradeEconomy,
                        child: const Text('تطوير الدراهم\n(التكلفة: 50)'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () {
                          // شراء الجيش وخصم التكلفة من ملف الاقتصاد
                          army.buyTroops(10, (cost) {
                            if (economy.coins >= cost) {
                              economy.coins -= cost;
                              return true;
                            }
                            return false;
                          });
                        },
                        child: const Text('شراء جيش\n(التكلفة: 10)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      onPressed: () {
                        if (army.troops > 0) {
                          int sent = army.sendTroops();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال $sent جندي للقلعة!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ليس لديك جيش لإرساله!')));
                        }
                      },
                      child: const Text('إرسال الجيوش للهجوم! 🚀', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
