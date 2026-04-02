

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gym_admin/data/models/calculated_cost_model.dart';
import 'package:gym_admin/data/models/data_to_calculated.dart' hide AdditionalSection;

/// Clase que representa un monto en dos monedas
class Amount {
  final double bs;
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


  /// Helper para crear el objeto de monto double
  /// value: valor en bolívares
  Amount _getAmount(double value) {
    return Amount(
      bs: double.parse((value * usdExchangeRate).toStringAsFixed(2)),
      // usd: double.parse((value / usdExchangeRate).toStringAsFixed(2)),
      usd: double.parse(value.toStringAsFixed(2)),
    );
  }

  /// Función principal de cálculo
  RecipeCalculation calculateRecipeCosts(RecipeRequestModel input) {

    debugPrint('input: $input');
    // 1. CALCULAR INGREDIENTES PRINCIPALES (Proteínas)
    double totalMainIngredientsCost = 0;

    var fixed = input.fixedCostsAndMargin;
    debugPrint('fixed: $fixed');

    double totalCostMainIngredients = 0;
    
    List<MainIngredientResult> mainIngredientsResults = (input.mainIngredients).map((ing) {
      
      debugPrint('pruchaseWeightKg: ${ing.purchaseWeightKg}');
      debugPrint('purchasePricePerKg: ${ing.purchasePricePerKg}');
      debugPrint('wastePercentage: ${ing.wastePercentage}');
      debugPrint('weightPerPortionKg: ${ing.weightPerPortionKg}');

      double totalPurchaseCost = ing.purchaseWeightKg * ing.purchasePricePerKg;
      debugPrint('totalPurchaseCost: $totalPurchaseCost');
      double usableWeight = ing.purchaseWeightKg - ((ing.wastePercentage * ing.purchaseWeightKg) / 100);
      double realPricePerKg = totalPurchaseCost / usableWeight;
      
      debugPrint('totalPurchaseCost: $totalPurchaseCost');
      debugPrint('usableWeight: $usableWeight');
      debugPrint('realPricePerKg: $realPricePerKg');

      double portionCost = ing.weightPerPortionKg * realPricePerKg;

      totalCostMainIngredients += totalPurchaseCost;
      debugPrint('totalCostMainIngredients: $totalCostMainIngredients'); 
      totalMainIngredientsCost += portionCost;

      return MainIngredientResult(
        name: ing.name,
        wasteCalculations: WasteCalculations(
          initialWeightKg: ing.purchaseWeightKg,
          wastePercentage: (ing.wastePercentage).toDouble(),
          usableWeightKg: double.parse(usableWeight.toStringAsFixed(3)),
          realPricePerKg: _getAmount(realPricePerKg),
        ),
        portion: Portion(
          // weightUsedKg: ing.weightPerPortionKg,
          weightUsedKg: double.parse((usableWeight / ing.weightPerPortionKg).toStringAsFixed(2)),
          cost: _getAmount(portionCost),
        ),
      );

    }).toList();

    // 2. CALCULAR SECCIONES ADICIONALES (Marinadas, Rellenos, etc.)
    double totalAdditionalCost = 0;
    double additionalBenefit = 0;
    double additionalIngredientsTotal = 0;
    
    List<AdditionalSection> additionalSectionsResults = input.additionalSectionsRequest.map((section) {
      double sectionTotal = 0;
      
      List<AdditionalItem> itemsResults = section.items.map((item) {
        
        additionalBenefit = (fixed.desiredProfitPercentage / 100);
        double itemSubtotal = (item.pricePerKg * item.quantityKg) + additionalBenefit;
        sectionTotal += itemSubtotal;
        additionalIngredientsTotal += item.pricePerKg;

        return AdditionalItem(
          name: item.name,
          quantityKg: item.quantityKg,
          pricePerKg: _getAmount(item.pricePerKg),
          subtotal: _getAmount(itemSubtotal),
        );

      }).toList();

      totalAdditionalCost += sectionTotal;

      return AdditionalSection(
        sectionName: section.name,
        items: itemsResults,
        sectionTotal: _getAmount(sectionTotal).toString(),
      );
      
    }).toList();

    debugPrint('totalAdditionalCost: $totalAdditionalCost');
    // 3. CONSOLIDACIÓN Y PRECIO DE VENTA
    double totalMainIngredientsCostWithAdditional = totalCostMainIngredients + additionalIngredientsTotal;
    debugPrint('totalMainIngredientsCostWithAdditional: $totalMainIngredientsCostWithAdditional');
    // Costo base: Proteínas + Adicionales + Pan
    double baseIngredientsCost = totalMainIngredientsCost + totalAdditionalCost + fixed.breadUnit;
    debugPrint('baseIngredientsCost: $baseIngredientsCost');

    // Utilidad bruta
    // double profitAmount = baseIngredientsCost * fixed.desiredProfitPercentage;
    // debugPrint('GANANCIAS ESPERADAS: profitAmount: $profitAmount');
    
    // Gastos fijos por unidad
    double unitFixedCosts = fixed.operatingCost + fixed.packagingUnit;

    /// Costo total
    double finalSalesPrice = baseIngredientsCost + unitFixedCosts;
    debugPrint('finalSalesPrice: $finalSalesPrice');

    double netProfitPerUnit = (finalSalesPrice * fixed.desiredProfitPercentage) / 100;
    netProfitPerUnit += additionalBenefit;
    debugPrint('netProfitPerUnit: $netProfitPerUnit');

    //* 4. MANTENIMIENTO (Punto de Equilibrio)
    //* Ganancia limpia por cada unidad vendida
    // double netProfitPerUnit = (finalSalesPrice * expectedAmountToHave) / 100;
    debugPrint('netProfitPerUnit: $netProfitPerUnit');
    debugPrint('unitFixedCosts: $unitFixedCosts');

    //* cantidad minima de venta
    int breakEvenUnits = (totalMainIngredientsCostWithAdditional / finalSalesPrice).ceil().toInt(); //* cantidad de unidades a vender para cubrir los gastos generales (punto de equilibrio)
    debugPrint('breakEvenUnits: $breakEvenUnits');

    log("Tasa de cambio: $usdExchangeRate");
    log("Gastos mensuales: $monthlyFixedExpenses");
    
    return RecipeCalculation(
      recipeName: input.recipeName,
      exchangeRate: usdExchangeRate, 
      mainIngredientResults: mainIngredientsResults,
      additionalSections: additionalSectionsResults, 
      economicSummary: EconomicSummary(
        expectedProfit: _getAmount(netProfitPerUnit).toString(),
        totalIngredientsCost: _getAmount(baseIngredientsCost).toString(),
        unitFixedExpenses: _getAmount(unitFixedCosts).toString(),
        suggestedSalesPrice: _getAmount(finalSalesPrice).toString(),
      ),
      businessMaintenance: BusinessMaintenance( //* agregar esto a la base de datosNO ESTA Y ALI ME GRITO
        monthlyFixedExpenses: _getAmount(monthlyFixedExpenses).toString(), //* gastos generales
        netProfitPerUnit: _getAmount(netProfitPerUnit).toString(), //* Cantidad de dinero que me queda (ganancias)
        unitsForBreakEven: breakEvenUnits.toInt(), //* Cantidad de platillos a vender para obtener el punto de equilibrio
      ),
    );
  }
}