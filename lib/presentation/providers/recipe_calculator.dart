

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gym_admin/data/models/calculated_cost_model.dart';
import 'package:gym_admin/data/models/data_to_calculated.dart' hide AdditionalSection;

/// Clase que representa un monto en dos monedas
class Amount {
  final int bs;
  final double usd;

  Amount({required this.bs, required this.usd});

  @override
  String toString() => "$bs Bs. (\$$usd)";
}

class RecipeCalculator {
  
  // double usdExchangeRate = 446.0;
  //double usdExchangeRate = RateExchangeProvider().getExchangeRate();
  // double monthlyFixedExpenses = 100000.0;
  //double monthlyFixedExpenses = FixedCostProvider().getFixedCost();

  final double usdExchangeRate;
  final double monthlyFixedExpenses;

  RecipeCalculator({
    required this.usdExchangeRate,
    required this.monthlyFixedExpenses,
  });


  /// Helper para crear el objeto de monto doble
  Amount _getAmount(double value) {
    return Amount(
      bs: value.round(),
      usd: double.parse((value / usdExchangeRate).toStringAsFixed(2)),
    );
  }

  /// Función principal de cálculo
  RecipeCalculation calculateRecipeCosts(RecipeRequestModel input) {

    debugPrint('input: $input');
    // 1. CALCULAR INGREDIENTES PRINCIPALES (Proteínas)
    double totalMainIngredientsCost = 0;
    
    List<MainIngredientResult> mainIngredientsResults = (input.mainIngredients).map((ing) {

      double totalPurchaseCost = ing.purchaseWeightKg * ing.purchasePricePerKg;
      double usableWeight = ing.purchaseWeightKg * (1 - ing.wastePercentage);
      double realPricePerKg = totalPurchaseCost / usableWeight;
      double portionCost = ing.weightPerPortionKg * realPricePerKg;

      totalMainIngredientsCost += portionCost;

    //   return {
    //     'name': ing['name'],
    //     'wasteCalculations': {
    //       'initialWeightKg': ing['purchaseWeightKg'],
    //       'wastePercentage': (ing['wastePercentage'] * 100).toInt(),
    //       'usableWeightKg': double.parse(usableWeight.toStringAsFixed(3)),
    //       'realPricePerKg': _getAmount(realPricePerKg),
    //     },
    //     'portion': {
    //       'weightUsedKg': ing['weightPerPortionKg'],
    //       'cost': _getAmount(portionCost),
    //     }
    //   };
    // }).toList();

    return MainIngredientResult(
      name: ing.name,
      wasteCalculations: WasteCalculations(
        initialWeightKg: ing.purchaseWeightKg,
        wastePercentage: (ing.wastePercentage * 100).toDouble(),
        usableWeightKg: double.parse(usableWeight.toStringAsFixed(3)),
        realPricePerKg: _getAmount(realPricePerKg),
      ),
      portion: Portion(
        weightUsedKg: ing.weightPerPortionKg,
        cost: _getAmount(portionCost),
      ),
    );
    }).toList();

    // 2. CALCULAR SECCIONES ADICIONALES (Marinadas, Rellenos, etc.)
    double totalAdditionalCost = 0;
    
    List<AdditionalSection> additionalSectionsResults = input.additionalSectionsRequest.map((section) {
      double sectionTotalBs = 0;
      
      List<AdditionalItem> itemsResults = section.items.map((item) {
        double itemSubtotalBs = item.pricePerKg * item.quantityKg;
        sectionTotalBs += itemSubtotalBs;

        return AdditionalItem(
          name: item.name,
          quantityKg: item.quantityKg,
          pricePerKg: _getAmount(item.pricePerKg),
          subtotal: _getAmount(itemSubtotalBs),
        );
        
        // return {
        //   'name': item['name'],
        //   'quantityKg': item['quantityKg'],
        //   'pricePerKg': _getAmount(item['pricePerKg']),
        //   'subtotal': _getAmount(itemSubtotalBs),
        // };

      }).toList();

      totalAdditionalCost += sectionTotalBs;
      
      // return {
      //   'sectionName': section['sectionName'],
      //   'items': itemsResults,
      //   'sectionTotal': _getAmount(sectionTotalBs),
      // };

      return AdditionalSection(
        sectionName: section.name,
        items: itemsResults,
        sectionTotal: _getAmount(sectionTotalBs).toString(),
      );
      
    }).toList();

    // 3. CONSOLIDACIÓN Y PRECIO DE VENTA
    var fixed = input.fixedCostsAndMargin;
    debugPrint('fixed: $fixed');
    
    // Costo base: Proteínas + Adicionales + Pan
    double baseIngredientsCost = totalMainIngredientsCost + totalAdditionalCost + fixed.breadUnit;
    
    // Utilidad bruta
    double profitAmount = baseIngredientsCost * fixed.desiredProfitPercentage;
    
    // Gastos fijos por unidad
    double unitFixedCosts = fixed.operatingCost + fixed.packagingUnit;

    double finalSalesPrice = baseIngredientsCost + profitAmount + unitFixedCosts;

    // 4. MANTENIMIENTO (Punto de Equilibrio)
    // Ganancia limpia por cada unidad vendida
    double netProfitPerUnit = finalSalesPrice.ceilToDouble() - (baseIngredientsCost + unitFixedCosts);
    int breakEvenUnits = (monthlyFixedExpenses / netProfitPerUnit).ceil();

    log("Tasa de cambio: $usdExchangeRate");
    log("Gastos mensuales: $monthlyFixedExpenses");
    // RETORNO DEL MAPA ESTRUCTURADO
    // return {
    //   'recipeName': input['recipeName'],
    //   'exchangeRate': usdExchangeRate,
    //   'mainIngredients': mainIngredientsResults,
    //   'additionalSections': additionalSectionsResults,
    //   'economicSummary': {
    //     'totalIngredientsCost': _getAmount(baseIngredientsCost),
    //     'expectedProfit': _getAmount(profitAmount),
    //     'unitFixedExpenses': _getAmount(unitFixedCosts),
    //     'suggestedSalesPrice': _getAmount(finalSalesPrice.ceilToDouble()),
    //   },
    //   'businessMaintenance': {
    //     'monthlyFixedExpenses': _getAmount(monthlyFixedExpenses),
    //     'netProfitPerUnit': _getAmount(netProfitPerUnit),
    //     'unitsForBreakEven': breakEvenUnits,
    //   }
    // };

    return RecipeCalculation(
      recipeName: input.recipeName,
      exchangeRate: usdExchangeRate, 
      mainIngredientResults: mainIngredientsResults,
      additionalSections: additionalSectionsResults, 
      economicSummary: EconomicSummary(
        expectedProfit: _getAmount(profitAmount).toString(),
        totalIngredientsCost: _getAmount(baseIngredientsCost).toString(),
        unitFixedExpenses: _getAmount(unitFixedCosts).toString(),
        suggestedSalesPrice: _getAmount(finalSalesPrice.ceilToDouble()).toString(),
      ),
      businessMaintenance: BusinessMaintenance( //* agregar esto a la base de datosNO ESTA Y ALI ME GRITO
        monthlyFixedExpenses: _getAmount(monthlyFixedExpenses).toString(), //* gastos generales
        netProfitPerUnit: _getAmount(netProfitPerUnit).toString(), //* Cantidad de dinero que me queda (ganancias)
        unitsForBreakEven: breakEvenUnits.toInt(), //* Cantidad de platillos a vender para obtener el punto de equilibrio
      ),
    );
  }
}