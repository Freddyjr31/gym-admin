
import 'package:fluent_ui/fluent_ui.dart';

class ShowContentDialogDynamic{

  static Future showContentDialogDynamic(BuildContext context, Widget content) async {
    return await showDialog(
      context: context,
      builder: (context) => content,
    );
  }
}

