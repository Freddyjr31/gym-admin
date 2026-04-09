import 'package:cook_ledger/data/datasource/Local/boxes.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TotalRecipesCount extends StatefulWidget {

  const TotalRecipesCount({super.key});

  @override
  State<TotalRecipesCount> createState() => _TotalRecipesCountState();
}

class _TotalRecipesCountState extends State<TotalRecipesCount> {
  @override
  Widget build(BuildContext context) {

    //* Obtenemos el total de recetas
    final total = recipeBox.length;

    //* tamaño de la tarjeta
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.3,
      child: Card(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Recetas guardadas', style: FluentTheme.of(context).typography.bodyLarge),
              ],
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(total == 0 ? '0' : '$total', style: FluentTheme.of(context).typography.display),
              ],
            ),
          ],
        ),
      ),
    );
  }
}