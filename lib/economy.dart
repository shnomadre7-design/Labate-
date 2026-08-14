import 'dart:async';

class EconomyManager {
  int coins = 0;
  int coinsPerSecond = 1;
  Timer? _timer;
  final Function onUpdate; // لتحديث الشاشة عند تغير الأرقام

  EconomyManager({required this.onUpdate});

  void startEarning() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      coins += coinsPerSecond;
      onUpdate();
    });
  }

  void stopEarning() {
    _timer?.cancel();
  }

  // دالة تطوير الإنتاج
  bool upgradeEconomy() {
    if (coins >= 50) {
      coins -= 50;
      coinsPerSecond += 2;
      onUpdate();
      return true; // تمت الترقية بنجاح
    }
    return false; // لا يوجد رصيد كافٍ
  }
}
