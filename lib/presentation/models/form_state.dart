
//* ==================== MODELOS LOCALES PARA EL FORMULARIO ITEMS ====================
import 'package:fluent_ui/fluent_ui.dart';

class SectionState {
  final TextEditingController nameController;
  final List<ItemState> items;

  SectionState({String initialName = ''})
      : nameController = TextEditingController(text: initialName),
        items = [];
}

class ItemState {
  final TextEditingController nameController;
  final TextEditingController pkgCostController; // precio por kg (double)
  final TextEditingController countController;   // cantidad (int)

  ItemState()
      : nameController = TextEditingController(),
        pkgCostController = TextEditingController(),
        countController = TextEditingController();
}

//* ==================== FIN MODELOS LOCALES PARA EL FORMULARIO PROTEINA PRINCIPAL ====================
class PrincipalProtein {

  final TextEditingController shrinkagePercentageController;
  final TextEditingController proteinController;
  final TextEditingController buyWeightController;
  final TextEditingController buyKgWeightController;
  final TextEditingController weightPortionController;

  PrincipalProtein({
    String initialName = ''
  }) : proteinController = TextEditingController(text: initialName),
        buyWeightController = TextEditingController(),
        buyKgWeightController = TextEditingController(),
        shrinkagePercentageController = TextEditingController(),
        weightPortionController = TextEditingController();
}
