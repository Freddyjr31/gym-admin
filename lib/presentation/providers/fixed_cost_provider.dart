


import 'package:fluent_ui/fluent_ui.dart';

class FixedCostProvider extends ChangeNotifier{
  
  double fixedCost = 0.0;

  void setFixedCost(double value){
    fixedCost = value;
    notifyListeners();
  }

  double getFixedCost(){
    return fixedCost;
  }

  double calculatedFixedCost(
    double totalCost, 
    double exchangeRate
    ){

      debugPrint('Total cost: $totalCost');
      debugPrint("Exchange rate: $exchangeRate");
      debugPrint("Total cost: ${totalCost * exchangeRate}");

    return totalCost * exchangeRate;
  }

}