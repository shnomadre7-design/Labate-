class ArmyManager {
  int troops = 0;
  final Function onUpdate;

  ArmyManager({required this.onUpdate});

  // دالة شراء الجيوش
  bool buyTroops(int cost, Function(int) deductCoins) {
    if (deductCoins(cost)) {
      troops += 5; // كل نقرة تشتري 5 جنود
      onUpdate();
      return true;
    }
    return false;
  }
  
  // دالة إرسال الجيوش للهجوم
  int sendTroops() {
    int sentTroops = troops;
    troops = 0; // تصفير الجيش بعد إرساله
    onUpdate();
    return sentTroops;
  }
}
