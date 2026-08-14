import 'package:flutter/material.dart';
import 'dart:async';

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
      home: const MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// شاشة البداية (اختيار إنشاء غرفة أو الانضمام)
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حرب القلعة - الشبكة المحلية'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: true)));
              },
              child: const Text('إنشاء معركة (أنت القلعة والمملكة الأولى)', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isHost: false)));
              },
              child: const Text('الانضمام لمعركة', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// شاشة اللعب والعدادات
class GameScreen extends StatefulWidget {
  final bool isHost;
  const GameScreen({super.key, required this.isHost});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int coins = 0;
  int coinsPerSecond = 1;
  int troops = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // تشغيل العداد لإضافة الدراهم كل ثانية
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        coins += coinsPerSecond;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void upgradeEconomy() {
    if (coins >= 50) {
      setState(() {
        coins -= 50;
        coinsPerSecond += 2; // تطوير الدخل
      });
    }
  }

  void buyTroops() {
    if (coins >= 10) {
      setState(() {
        coins -= 10;
        troops += 5; // شراء 5 جنود
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isHost ? 'القلعة المركزية (المضيف)' : 'مملكة المهاجم')),
      body: Column(
        children: [
          // عرض القلعة المركزية وحالتها
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
          
          // لوحة تحكم اللاعب (دراهم وجيوش)
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
                      Text('الدراهم: $coins 💰\n(+$coinsPerSecond/ثانية)', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
                      Text('جيوشك: $troops ⚔️', style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                  const Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: upgradeEconomy,
                        child: const Text('تطوير الدراهم\n(التكلفة: 50)'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: buyTroops,
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
                        // هنا سنضع كود إرسال الجيوش للقلعة عبر الشبكة
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الجيش للقلعة! (سيتم برمجة الاتصال لاحقاً)')));
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
