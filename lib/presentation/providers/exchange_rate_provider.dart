
import 'package:fluent_ui/fluent_ui.dart' show ChangeNotifier;

class RateExchangeProvider extends ChangeNotifier {

  double exhangeRate = 0.0;
  
  double getExchangeRate(){
    return exhangeRate;
  }

  void setExhangeRate(double value){
    exhangeRate = value;
    notifyListeners();
  }
}