


import 'package:fluent_ui/fluent_ui.dart';

class FixedCostProvider extends ChangeNotifier{
  
  double fixedCost = 0.0;
  double fixedCostInUSD = 0.0;

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
    return totalCost * exchangeRate;
  }

  double setFixedCostInUSD(double value){
    fixedCostInUSD = value;
    notifyListeners();
    return fixedCostInUSD;
  }

  double getFixedCostInUSD(){
    return fixedCostInUSD;
  }

}