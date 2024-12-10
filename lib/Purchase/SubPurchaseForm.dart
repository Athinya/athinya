import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';

class PurchaseDiscountForm extends StatefulWidget {
  final Function clearTableData;
  final Function recordonorefresh;

  final List<Map<String, dynamic>> tableData;
  final Function(List<Map<String, dynamic>>) getProductCountCallback;
  final Function(List<Map<String, dynamic>>) getTotalQuantityCallback;
  final Function(List<Map<String, dynamic>>) getTotalTaxableCallback;
  final Function(List<Map<String, dynamic>>) getTotalFinalTaxableCallback;

  final Function(List<Map<String, dynamic>>) getTotalCGSTAmtCallback;
  final Function(List<Map<String, dynamic>>) getTotalSGSTAMtCallback;
  final Function(List<Map<String, dynamic>>) getTotalFinalAmtCallback;
  final Function(List<Map<String, dynamic>>) getTotalAmtCallback;

  final Function(List<Map<String, dynamic>>) getProductDiscountCallBack;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST0callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST25callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST6callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST9callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtCGST14callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST0callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST25callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST6callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST9callback;
  final Function(List<Map<String, dynamic>>) gettaxableAmtSGST14callback;

  final Function(List<Map<String, dynamic>>) getFinalAmtCGST0callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST25callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST6callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST9callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtCGST14callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST0callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST25callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST6callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST9callback;
  final Function(List<Map<String, dynamic>>) getFinalAmtSGST14callback;

  final TextEditingController purchaseRecordNoController;
  final TextEditingController purchaseInvoiceNoController;
  final TextEditingController purchaseGSTMethodController;
  final TextEditingController purchaseContactController;
  final TextEditingController purchaseSupplierAgentidController;
  final TextEditingController purchaseSuppliergstnoController;
  final TextEditingController ProductCategoryController;

  final TextEditingController purchaseSupplierNameController;
  final FocusNode finaldiscountPercFocusNode;

  // final String purchaseSupplierNameController;

  final DateTime selectedDate;

  PurchaseDiscountForm(
      {required this.tableData,
      required this.recordonorefresh,
      required this.getProductCountCallback,
      required this.getTotalQuantityCallback,
      required this.getTotalTaxableCallback,
      required this.getTotalFinalTaxableCallback,
      required this.getTotalCGSTAmtCallback,
      required this.getTotalSGSTAMtCallback,
      required this.getTotalFinalAmtCallback,
      required this.getTotalAmtCallback,
      required this.getProductDiscountCallBack,
      required this.gettaxableAmtCGST0callback,
      required this.gettaxableAmtCGST25callback,
      required this.gettaxableAmtCGST6callback,
      required this.gettaxableAmtCGST9callback,
      required this.gettaxableAmtCGST14callback,
      required this.gettaxableAmtSGST0callback,
      required this.gettaxableAmtSGST25callback,
      required this.gettaxableAmtSGST6callback,
      required this.gettaxableAmtSGST9callback,
      required this.gettaxableAmtSGST14callback,
      required this.getFinalAmtCGST0callback,
      required this.getFinalAmtCGST25callback,
      required this.getFinalAmtCGST6callback,
      required this.getFinalAmtCGST9callback,
      required this.getFinalAmtCGST14callback,
      required this.getFinalAmtSGST0callback,
      required this.getFinalAmtSGST25callback,
      required this.getFinalAmtSGST6callback,
      required this.getFinalAmtSGST9callback,
      required this.getFinalAmtSGST14callback,
      required this.purchaseRecordNoController,
      required this.purchaseSupplierNameController,
      required this.purchaseInvoiceNoController,
      required this.purchaseGSTMethodController,
      required this.purchaseContactController,
      required this.purchaseSupplierAgentidController,
      required this.purchaseSuppliergstnoController,
      required this.ProductCategoryController,
      required this.selectedDate,
      required this.finaldiscountPercFocusNode,
      required this.clearTableData});
  @override
  State<PurchaseDiscountForm> createState() => _PurchaseDiscountFormState();
}

class _PurchaseDiscountFormState extends State<PurchaseDiscountForm> {
  void initState() {
    super.initState();
    purchaseDisAMountController.text = "0.0";
    purchaseDisPercentageController.text = "0";
  }

  TextEditingController purchaseDisAMountController = TextEditingController();
  TextEditingController purchaseDisPercentageController =
      TextEditingController();

  late String finalTaxableAmountinitialValue;

  // FocusNode finaldiscountPercFocusNode = FocusNode();
  FocusNode FinalDiscountAmtFocusNode = FocusNode();
  FocusNode RoundOffFocusNode = FocusNode();
  FocusNode FinalAmountFocusNode = FocusNode();
  FocusNode FinalTotalAmountFocusNode = FocusNode();
  FocusNode saveallButtonFocusNode = FocusNode();

  TextEditingController purchaseRoundOffController =
      TextEditingController(text: '0');
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    TextEditingController CGSTPercent0 = TextEditingController();

    TextEditingController CGSTPercent25 = TextEditingController();

    TextEditingController CGSTPercent6 = TextEditingController();

    TextEditingController CGSTPercent9 = TextEditingController();

    TextEditingController CGSTPercent14 = TextEditingController();
    TextEditingController SGSTPercent0 = TextEditingController();

    TextEditingController SGSTPercent25 = TextEditingController();

    TextEditingController SGSTPercent6 = TextEditingController();

    TextEditingController SGSTPercent9 = TextEditingController();

    TextEditingController SGSTPercent14 = TextEditingController();

    String TaxableAmountinitialValue =
        widget.getTotalTaxableCallback(widget.tableData).toString();
    TextEditingController TaxableController =
        TextEditingController(text: TaxableAmountinitialValue);

    String FinalTaxableAmountinitialValue =
        widget.getTotalFinalTaxableCallback(widget.tableData).toString();
    TextEditingController finalTaxableController =
        TextEditingController(text: FinalTaxableAmountinitialValue);

    String CGSTAmountInitialvalue =
        widget.getTotalCGSTAmtCallback(widget.tableData).toString();
    TextEditingController CGSTAmountController =
        TextEditingController(text: CGSTAmountInitialvalue);

    String SGSTAmountInitialvalue =
        widget.getTotalSGSTAMtCallback(widget.tableData).toString();
    TextEditingController SGSTAmountController =
        TextEditingController(text: SGSTAmountInitialvalue);

    String totalAmountInitialvalue =
        widget.getTotalAmtCallback(widget.tableData).toString();
    TextEditingController TotalAmountController =
        TextEditingController(text: totalAmountInitialvalue);

    String FinalTotalAmtInitialValue =
        widget.getTotalFinalAmtCallback(widget.tableData).toString();
    TextEditingController FinalTotalAmountController =
        TextEditingController(text: FinalTotalAmtInitialValue);

    void _fieldFocusChange(
        BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    void calculateDiscountAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        double cgst0 = double.tryParse(widget
                .gettaxableAmtCGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .gettaxableAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(widget
                .gettaxableAmtCGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst9 = double.tryParse(widget
                .gettaxableAmtCGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .gettaxableAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        purchaseDisAMountController.text = discountAmount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double cgst0 = double.tryParse(
                widget.getFinalAmtCGST0callback(widget.tableData).toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .getFinalAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(
                widget.getFinalAmtCGST6callback(widget.tableData).toString()) ??
            0.0;
        double cgst9 = double.tryParse(
                widget.getFinalAmtCGST9callback(widget.tableData).toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .getFinalAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double part1 = cgst0 * disPercentage / 100;
        double part2 = cgst25 * disPercentage / 100;
        double part3 = cgst6 * disPercentage / 100;
        double part4 = cgst9 * disPercentage / 100;
        double part5 = cgst14 * disPercentage / 100;

        // Calculate total discount amount
        double discountAmount = part1 + part2 + part3 + part4 + part5;

        // Update the discount amount in the text controller
        purchaseDisAMountController.text = discountAmount.toStringAsFixed(2);
        // print("DiscountAmount : ${purchaseDisAMountController.text}");
      } else {
        double taxableamount = double.tryParse(widget
                .getTotalFinalTaxableCallback(widget.tableData)
                .toString()) ??
            0.0;

        double discountamount = taxableamount * disPercentage / 100;

        purchaseDisAMountController.text = discountamount.toStringAsFixed(2);
      }
    }

    void calculateDiscountPercentage() {
      // Get the discount amount from the controller
      double discountAmount =
          double.tryParse(purchaseDisAMountController.text) ?? 0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        purchaseDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalTaxable = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;

        // Calculate the discount percentage
        double discountPercentage = (discountAmount * 100) / totalTaxable;

        // Update the discount percentage in the appropriate controller
        purchaseDisPercentageController.text =
            discountPercentage.toStringAsFixed(2);
      } else {
        double taxableamount = double.tryParse(widget
                .getTotalFinalTaxableCallback(widget.tableData)
                .toString()) ??
            0.0;

        double discountamount = discountAmount * 100 / taxableamount;

        purchaseDisPercentageController.text =
            discountamount.toStringAsFixed(2);
      }
    }

    void CalculateCGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        double cgst0 = double.tryParse(widget
                .gettaxableAmtCGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .gettaxableAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(widget
                .gettaxableAmtCGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst9 = double.tryParse(widget
                .gettaxableAmtCGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .gettaxableAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / 100;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / 100;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / 100;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / 100;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / 100;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double cgst0 = double.tryParse(
                widget.getFinalAmtCGST0callback(widget.tableData).toString()) ??
            0.0;
        double cgst25 = double.tryParse(widget
                .getFinalAmtCGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double cgst6 = double.tryParse(
                widget.getFinalAmtCGST6callback(widget.tableData).toString()) ??
            0.0;
        double cgst9 = double.tryParse(
                widget.getFinalAmtCGST9callback(widget.tableData).toString()) ??
            0.0;
        double cgst14 = double.tryParse(widget
                .getFinalAmtCGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double cgst0part1 = cgst0 * disPercentage / 100;
        double cgst25part2 = cgst25 * disPercentage / 100;
        double cgst6part3 = cgst6 * disPercentage / 100;
        double cgst9part4 = cgst9 * disPercentage / 100;
        double cgst14part5 = cgst14 * disPercentage / 100;

        double finalcgst0amt = cgst0 - cgst0part1;
        double finalcgst25amt = cgst25 - cgst25part2;
        double finalcgst6amt = cgst6 - cgst6part3;
        double finalcgst9amt = cgst9 - cgst9part4;
        double finalcgst14amt = cgst14 - cgst14part5;

        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaCGST0 = finalcgst0amt * 0 / denominator0;
        double FinameFormulaCGST25 = finalcgst25amt * 2.5 / denominator25;
        double FinameFormulaCGST6 = finalcgst6amt * 6 / denominator6;
        double FinameFormulaCGST9 = finalcgst9amt * 9 / denominator9;
        double FinameFormulaCGST14 = finalcgst14amt * 14 / denominator14;

        CGSTPercent0.text = FinameFormulaCGST0.toStringAsFixed(2);
        CGSTPercent25.text = FinameFormulaCGST25.toStringAsFixed(2);
        CGSTPercent6.text = FinameFormulaCGST6.toStringAsFixed(2);
        CGSTPercent9.text = FinameFormulaCGST9.toStringAsFixed(2);
        CGSTPercent14.text = FinameFormulaCGST14.toStringAsFixed(2);

        // print("cgsttttttt 00000 : ${CGSTPercent0.text}");
        // print("cgsttttttt 25555 : ${CGSTPercent25.text}");
        // print("cgsttttttt 6666 : ${CGSTPercent6.text}");
        // print("cgsttttttt 999 : ${CGSTPercent9.text}");
        // print("cgsttttttt 14444 : ${CGSTPercent14.text}");

        double FinalCGSTAmounts = FinameFormulaCGST0 +
            FinameFormulaCGST25 +
            FinameFormulaCGST6 +
            FinameFormulaCGST9 +
            FinameFormulaCGST14;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      } else {
        CGSTPercent0.text = 0.toStringAsFixed(2);
        CGSTPercent25.text = 0.toStringAsFixed(2);
        CGSTPercent6.text = 0.toStringAsFixed(2);
        CGSTPercent9.text = 0.toStringAsFixed(2);
        CGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalCGSTAmounts = 0;

        CGSTAmountController.text = FinalCGSTAmounts.toStringAsFixed(2);
      }
    }

    void CalculateSGSTFinalAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;

      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Ensure that the values obtained from callbacks are converted to doubles
        double sgst0 = double.tryParse(widget
                .gettaxableAmtSGST0callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst25 = double.tryParse(widget
                .gettaxableAmtSGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst6 = double.tryParse(widget
                .gettaxableAmtSGST6callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst9 = double.tryParse(widget
                .gettaxableAmtSGST9callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst14 = double.tryParse(widget
                .gettaxableAmtSGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double FinameFormulaSGST0 = finalsgst0amt * 0 / 100;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / 100;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / 100;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / 100;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / 100;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        // Ensure that the values obtained from callbacks are converted to doubles
        double sgst0 = double.tryParse(
                widget.getFinalAmtSGST0callback(widget.tableData).toString()) ??
            0.0;
        double sgst25 = double.tryParse(widget
                .getFinalAmtSGST25callback(widget.tableData)
                .toString()) ??
            0.0;
        double sgst6 = double.tryParse(
                widget.getFinalAmtSGST6callback(widget.tableData).toString()) ??
            0.0;
        double sgst9 = double.tryParse(
                widget.getFinalAmtSGST9callback(widget.tableData).toString()) ??
            0.0;
        double sgst14 = double.tryParse(widget
                .getFinalAmtSGST14callback(widget.tableData)
                .toString()) ??
            0.0;

        // Perform calculations
        double sgst0part1 = sgst0 * disPercentage / 100;
        double sgst25part2 = sgst25 * disPercentage / 100;
        double sgst6part3 = sgst6 * disPercentage / 100;
        double sgst9part4 = sgst9 * disPercentage / 100;
        double sgst14part5 = sgst14 * disPercentage / 100;

        double finalsgst0amt = sgst0 - sgst0part1;
        double finalsgst25amt = sgst25 - sgst25part2;
        double finalsgst6amt = sgst6 - sgst6part3;
        double finalsgst9amt = sgst9 - sgst9part4;
        double finalsgst14amt = sgst14 - sgst14part5;
        double denominator0 = 100 + 0;
        double denominator25 = 100 + 5;
        double denominator6 = 100 + 12;
        double denominator9 = 100 + 18;
        double denominator14 = 100 + 28;

        double FinameFormulaSGST0 = finalsgst0amt * 0 / denominator0;
        double FinameFormulaSGST25 = finalsgst25amt * 2.5 / denominator25;
        double FinameFormulaSGST6 = finalsgst6amt * 6 / denominator6;
        double FinameFormulaSGST9 = finalsgst9amt * 9 / denominator9;
        double FinameFormulaSGST14 = finalsgst14amt * 14 / denominator14;

        SGSTPercent0.text = FinameFormulaSGST0.toStringAsFixed(2);
        SGSTPercent25.text = FinameFormulaSGST25.toStringAsFixed(2);
        SGSTPercent6.text = FinameFormulaSGST6.toStringAsFixed(2);
        SGSTPercent9.text = FinameFormulaSGST9.toStringAsFixed(2);
        SGSTPercent14.text = FinameFormulaSGST14.toStringAsFixed(2);

        double FinalSGSTAmounts = FinameFormulaSGST0 +
            FinameFormulaSGST25 +
            FinameFormulaSGST6 +
            FinameFormulaSGST9 +
            FinameFormulaSGST14;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      } else {
        SGSTPercent0.text = 0.toStringAsFixed(2);
        SGSTPercent25.text = 0.toStringAsFixed(2);
        SGSTPercent6.text = 0.toStringAsFixed(2);
        SGSTPercent9.text = 0.toStringAsFixed(2);
        SGSTPercent14.text = 0.toStringAsFixed(2);

        double FinalSGSTAmounts = 0;

        SGSTAmountController.text = FinalSGSTAmounts.toStringAsFixed(2);
      }
    }

    void calculatetotalAmount() {
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double finaltotalTaxable =
            double.tryParse(finalTaxableController.text) ?? 0.0;
        double finalCGSTAmount =
            double.tryParse(CGSTAmountController.text) ?? 0.0;
        double finalSGSTAmount =
            double.tryParse(SGSTAmountController.text) ?? 0.0;

        // Perform calculation
        double TotalAmount =
            finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

        // // Update TotalAmountController
        // TotalAmountController.text = TotalAmount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        TotalAmountController.text = FinalTotlaAmount.toStringAsFixed(2);
      } else {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        TotalAmountController.text = FinalTotlaAmount.toStringAsFixed(2);
      }
    }

    void calculateFinaltotalAmount() {
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double finaltotalTaxable =
            double.tryParse(finalTaxableController.text) ?? 0.0;
        double finalCGSTAmount =
            double.tryParse(CGSTAmountController.text) ?? 0.0;
        double finalSGSTAmount =
            double.tryParse(SGSTAmountController.text) ?? 0.0;

        // Perform calculation
        double TotalAmount =
            finaltotalTaxable + finalCGSTAmount + finalSGSTAmount;

        TotalAmountController.text = TotalAmount.toStringAsFixed(2);

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = TotalAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = FinalTotlaAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      } else {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double Roundoff =
            double.tryParse(purchaseRoundOffController.text) ?? 0.0;
        double roundoffFinalTotAmt = FinalTotlaAmount + Roundoff;

        FinalTotalAmountController.text =
            roundoffFinalTotAmt.toStringAsFixed(2);
      }
    }

    void calculateFinalTaxableAmount() {
      // Parse discount percentage
      double disPercentage =
          double.tryParse(purchaseDisPercentageController.text.toString()) ??
              0.0;
      double discountAmount =
          double.tryParse(purchaseDisAMountController.text) ?? 0.0;
      if (widget.purchaseGSTMethodController.text == "Excluding") {
        // Get the total taxable amount from the widget
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;

        double FinalTaxableAMount = totalTaxable - discountAmount;
        finalTaxableController.text = FinalTaxableAMount.toStringAsFixed(2);
      } else if (widget.purchaseGSTMethodController.text == "Including") {
        double totalFInalAMount = double.tryParse(
                widget.getTotalFinalAmtCallback(widget.tableData).toString()) ??
            0.0;
        double discountamount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double FinalTotlaAmount = totalFInalAMount - discountamount;

        double finalAmount = FinalTotlaAmount;
        double cgsttotalamount =
            double.tryParse(CGSTAmountController.text.toString()) ?? 0.0;
        double sgsttotalamount =
            double.tryParse(CGSTAmountController.text.toString()) ?? 0.0;

        double totalgstamount = cgsttotalamount + sgsttotalamount;

        double finaltaxableamount = finalAmount - totalgstamount;
        finalTaxableController.text = finaltaxableamount.toStringAsFixed(2);
      } else {
        double totalTaxable = double.tryParse(
                widget.getTotalTaxableCallback(widget.tableData).toString()) ??
            0.0;
        double discountAmount =
            double.tryParse(purchaseDisAMountController.text) ?? 0.0;

        double finaltaxableamount = totalTaxable - discountAmount;
        finalTaxableController.text = finaltaxableamount.toStringAsFixed(2);
      }
    }

    Future<void> postDataToAPI(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      if (!mounted) return; // Check if the widget is mounted before proceeding

      CalculateCGSTFinalAmount();
      CalculateSGSTFinalAmount();
      calculateFinalTaxableAmount();
      calculateFinaltotalAmount();
      List<String> productDetails = [];

      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        String date = DateFormat('yyyy-MM-dd').format(selectedDate);
        productDetails.add(
            "{serialno:$purchaseRecordNo,dt:$date,item:${data['productName']},qty:${data['quantity']},rate:${data['rate']},disc:${data['discountamount']},total:${data['total']},cgstperc:${data['cgstpercentage']},cgstamount:${data['cgstAmount']},sgstperc:${data['sgstPercentage']},sgstamount:${data['sgstAmount']},finaltotal:${data['finalAmount']},disperc:${data['discountpercentage']},taxable:${data['taxableAmount']},igstperc:0.0,igstamnt:0.0,cessperc:0.0,cessamnt:0.0,addstock:${data['addstock']}}");
      }
      // print('tbl : $tableData');

      // Join all product details into a single string
      String productDetailsString = productDetails.join('');
      // print("productdetails:$productDetailsString");
      // Prepare the data to be sent
      if (!mounted) return; // Check if the widget is mounted before proceeding

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "serialno": widget.purchaseRecordNoController.text,
        "date": DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        "purchasername": widget.purchaseSupplierNameController.text,
        "count": widget.getProductCountCallback(widget.tableData).toString(),
        "total": FinalTotalAmountController.text,
        // "name": widget.purchaseSupplierNameController.text,
        "invoiceno": widget.purchaseInvoiceNoController.text,
        "finlaldis": purchaseDisAMountController.text,
        "round": purchaseRoundOffController.text,
        "cgst0": CGSTPercent0.text, // Use the calculated CGST values
        "cgst25": CGSTPercent25.text,
        "cgst6": CGSTPercent6.text,
        "cgst9": CGSTPercent9.text,
        "cgst14": CGSTPercent14.text,
        "sgst0": SGSTPercent0.text,
        "sgst25": SGSTPercent25.text,
        "sgst6": SGSTPercent6.text,
        "sgst9": SGSTPercent9.text,
        "sgst14": SGSTPercent14.text,
        "igst0": "0.0",
        "igst5": "0.0",
        "igst12": "0.0",
        "igst18": "0.0",
        "igst28": "0.0",
        "cess": "0.0",
        "totcgst": CGSTAmountController.text,
        "totsgst": SGSTAmountController.text,
        "totigst": "0.0",
        "totcess": "0.0",
        "proddis":
            widget.getProductDiscountCallBack(widget.tableData).toString(),
        "taxable": TaxableController.text,
        "gstmethod": widget.purchaseGSTMethodController.text.isEmpty
            ? "NonGst"
            : widget.purchaseGSTMethodController.text,
        "disperc": purchaseDisPercentageController.text,
        "agentid": widget.purchaseSupplierAgentidController.text,
        "contact": widget.purchaseContactController.text,
        "gstno": widget.purchaseSuppliergstnoController.text,
        "finaltaxable": finalTaxableController.text,
        "PurchaseDetails": productDetailsString,
      };

      if (widget.purchaseGSTMethodController.text.isEmpty) {
        postData["gstmethod"] = "NonGst";
      } else {
        postData["gstmethod"] = widget.purchaseGSTMethodController.text;
      }

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);

      try {
        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/PurchaseRoundDetailsalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );
        if (!mounted)
          return; // Check if the widget is mounted before proceeding

        // Check the response status
        if (response.statusCode == 201) {
          print('Data posted successfully');
          await logreports(
              "Purchase: Invoice-${widget.purchaseInvoiceNoController.text}_Billno-${widget.purchaseRecordNoController.text}_AgentName-${widget.purchaseSupplierNameController.text}_Inserted");
          successfullySavedMessage(context);
          widget.purchaseInvoiceNoController.clear();
          widget.purchaseSupplierNameController.text = '';
          widget.purchaseContactController.clear();
          widget.clearTableData();

          purchaseDisPercentageController.text = '0';
          purchaseDisAMountController.text = '0';
          purchaseRoundOffController.text = '0';
          widget.recordonorefresh();
        } else {
          // print('Failed to post data. Error code: ${response.statusCode}');

          // print('Response body: ${response.statusCode}');
        }
      } catch (e) {
        // print('Failed to post data. Error: $e');
      }
    }

    Clear() {
      widget.purchaseInvoiceNoController.clear();
      widget.purchaseSupplierNameController.text = '';
      widget.purchaseContactController.clear();
      widget.clearTableData();
      purchaseDisPercentageController.text = '0';
      purchaseDisAMountController.text = '0';
      purchaseRoundOffController.text = '0';
      widget.recordonorefresh();
    }

    Future<void> postDataWithIncrementedSerialNo() async {
      // Increment the serial number
      int incrementedSerialNo = int.parse(
        widget.purchaseRecordNoController.text,
      );

      String? cusid = await SharedPrefs.getCusId();
      // Prepare the data to be sent
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "serialno": incrementedSerialNo,
      };

      // Convert the data to JSON format
      String jsonData = jsonEncode(postData);

      try {
        // Send the POST request
        var response = await http.post(
          Uri.parse('$IpAddress/PurchaseserialNoalldatas/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check the response status
        if (response.statusCode == 200) {
          print('Data posted successfully');
        } else {
          // print('Response body: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to post data. Error: $e');
      }
    }

    Future<void> Post__purchaseDetails(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      for (var data in tableData) {
        Map<String, dynamic> postData = {
          // "id": 30,
          "serialno": purchaseRecordNo,
          "dt": DateFormat('yyyy-MM-dd').format(selectedDate),
          "item": data['productName'],
          "qty": data['quantity'],
          "rate": data['rate'],
          "disc": data['discountamount'],
          "total": data['total'],
          "cgstperc": data['cgstpercentage'],
          "cgstamount": data['cgstAmount'],
          "sgstperc": data['sgstPercentage'],
          "sgstamount": data['sgstAmount'],
          "finaltotal": data['finalAmount'],
          "disperc": data['discountpercentage'],
          "taxable": data['taxableAmount'],
          "igstperc": "0.0",
          "igstamnt": "0.0",
          "cessperc": "0.0",
          "cessamnt": "0.0",
          "addstock": data["stockcheck"]
        };

        // Convert the data to JSON format
        String jsonData = jsonEncode(postData);

        try {
          // Send the POST request
          var response = await http.post(
            Uri.parse('http://$IpAddress/Purchase_Details/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonData,
          );

          // Check the response status
          if (response.statusCode == 200) {
            print('Data posted successfully');
          } else {
            // print('Response body: ${response.statusCode}');
          }
        } catch (e) {
          print('Failed to post data. Error: $e');
        }
      }
    }

    TextEditingController ProductCategoryController = TextEditingController();
    Future<bool> checkProductExists(String apiUrl, String productName) async {
      final response = await http.get(Uri.parse(apiUrl));
      final jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        final List<dynamic> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Check if product name exists in the results
        for (var entry in results) {
          if (entry['name'] == productName) {
            return true;
          }
        }
      }
      return false;
    }

    Future<String> fetchProductCategory(String productName) async {
      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
      final response = await http.get(Uri.parse(apiUrl));
      final jsonData = json.decode(response.body);

      String totalCategory = ''; // Initialize total category to empty string

      if (jsonData['results'] != null) {
        final List<dynamic> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Iterate through each entry in the results
        for (var entry in results) {
          // Check if product name matches
          if (entry['name'] == productName) {
            // Accumulate the categories
            String category = entry['category'] ?? '';
            totalCategory += category + ', ';
          }
        }
        // Remove the trailing comma and space
        if (totalCategory.isNotEmpty) {
          totalCategory = totalCategory.substring(0, totalCategory.length - 2);
        }
      }
      return totalCategory;
    }

    Future<void> addNewProduct(String apiUrl, Map<String, dynamic> data) async {
      String category = await fetchProductCategory(data['productName']);

      Map<String, dynamic> postData = {
        "name": data['productName'],
        "stock": data['quantity'],
        "category": category,
        "amount": data['rate'],
        "sgstperc": data['cgstpercentage'],
        "cgstperc": data['sgstPercentage']
      };

      String jsonData = jsonEncode(postData);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data added successfully');
      } else {
        print('Failed to add data: ${response.statusCode}, ${response.body}');
        // Handle failure as needed
      }
    }

    void _addRowMaterial(List<Map<String, dynamic>> tableData) async {
      if (!mounted) return;

      String? cusid = await SharedPrefs.getCusId();
      for (var data in tableData) {
        String productName = data['productName'];
        String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';

        // Check if the product already exists in the URL data
        bool productExists = await checkProductExists(apiUrl, productName);

        if (productExists) {
          try {
            String url = apiUrl;
            Map<String, dynamic> jsonData;
            int productId; // Variable to store the product ID

            while (true) {
              final response = await http.get(Uri.parse(url));

              if (response.statusCode == 200) {
                jsonData = jsonDecode(response.body);
                final List<dynamic> results = jsonData['results'];

                // Find the product and extract its ID
                for (var entry in results) {
                  if (entry['name'] == productName) {
                    productId = entry['id'];
                    double currentStock = double.parse(entry['stock'] ?? '0');
                    double newStockValue =
                        double.parse(data['quantity'].toString());
                    entry['stock'] = (currentStock + newStockValue).toString();

                    // Update the product data using the specific URL with ID
                    String productUrl = '$apiUrl$productId/';
                    String jsonDataString = jsonEncode(entry);
                    await http.put(
                      Uri.parse(productUrl),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonDataString,
                    );

                    print('Stock updated successfully for $productName');
                    break; // Break the loop after updating the stock
                  }
                }

                break; // Break the loop after updating the stock
              } else {
                throw Exception(
                    'Failed to load product data: ${response.reasonPhrase}');
              }
            }
          } catch (e) {
            print('Error updating product stock: $e');
          }
        } else {
          // If product does not exist, add new data
          await addNewProduct(apiUrl, data);
        }
      }
    }

// start with mine
// Function to check if the product exists
    Future<bool> NewcheckProductExists(String productName) async {
      String? cusid = await SharedPrefs.getCusId();
      final url = '$IpAddress/Settings_ProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];
          return products.any((product) =>
              product['name'].toLowerCase() == productName.toLowerCase());
        } else {
          print('Failed to load product data');
          return false;
        }
      } catch (e) {
        print('Error occurred: $e');
        return false;
      }
    }

// Function to fetch the product ID from the URL
    Future<String?> fetchProductId(String productName) async {
      String? cusid = await SharedPrefs.getCusId();

      final url = '$IpAddress/PurchaseProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];
          final product = products.firstWhere(
            (product) =>
                product['name'].toLowerCase() == productName.toLowerCase(),
            orElse: () => null,
          );
          return product?['id']?.toString();
        } else {
          print('Failed to fetch product ID');
          return null;
        }
      } catch (e) {
        print('Error occurred: $e');
        return null;
      }
    }

// Function to fetch current stock and update with new stock using product ID
    Future<void> fetchAndUpdateStockById(String productId, int newStock) async {
      // Fetch the cusid from shared preferences
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null) {
        print('Error: cusid is null');
        return;
      }

      // Step 1: Fetch the current stock for the given product ID
      final fetchUrl = '$IpAddress/PurchaseProductDetailsalldatas/$productId/';
      try {
        final fetchResponse = await http.get(Uri.parse(fetchUrl));
        if (fetchResponse.statusCode == 200) {
          final data = jsonDecode(fetchResponse.body);

          // Assume the current stock is stored in a field called 'stock'
          // You may need to adjust this depending on the actual structure of the response
          double currentStock = 0.0;

          if (data['stock'] is String) {
            currentStock = double.tryParse(data['stock']) ?? 0.0;
          } else if (data['stock'] is num) {
            currentStock = (data['stock'] as num).toDouble();
          }

          print('Current Stock for product ID $productId: $currentStock');

          // Step 2: Add the new stock (from tableData) to the current stock
          final updatedStock = currentStock + newStock;
          print('Updated Stock for product ID $productId: $updatedStock');

          // Step 3: Send PUT request to update stock
          final updateUrl =
              '$IpAddress/PurchaseProductDetailsalldatas/$productId/';
          final updateResponse = await http.put(
            Uri.parse(updateUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'cusid': cusid, // Include cusid in the request
              'stock': updatedStock // Update with the new stock value
            }),
          );

          if (updateResponse.statusCode == 200) {
            print('Stock updated successfully for product ID: $productId.');
          } else {
            print(
                'Failed to update stock for product ID: $productId. Status Code: ${updateResponse.statusCode}');
            // print('Response Body: ${updateResponse.body}');
          }
        } else {
          print(
              'Failed to fetch current stock for product ID: $productId. Status Code: ${fetchResponse.statusCode}');
        }
      } catch (e) {
        print('Error occurred while fetching or updating stock: $e');
      }
    }

// // Function to fetch and update stock value, and return whether the product was found
    Future<bool> fetchAndUpdateStock(String productName, int newStock) async {
      String? cusid = await SharedPrefs.getCusId();

      final url = '$IpAddress/Settings_ProductDetails/$cusid/';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> products = data['results'];

          // Check if the product exists
          final existingProduct = products.firstWhere(
            (product) =>
                product['name'].toLowerCase() == productName.toLowerCase(),
            orElse: () => null,
          );

          if (existingProduct != null) {
            final productId = existingProduct['id'];

            // Handle the stockvalue which could be of type String or num
            double currentStock;
            if (existingProduct['stockvalue'] is String) {
              currentStock =
                  double.tryParse(existingProduct['stockvalue']) ?? 0.0;
            } else if (existingProduct['stockvalue'] is num) {
              currentStock = (existingProduct['stockvalue'] as num).toDouble();
            } else {
              currentStock =
                  0.0; // Default value if stockvalue is neither a String nor a num
            }

            print('Product "$productName" exists with ID: $productId');
            print('Current Stock Value: $currentStock');

            // Update stock by adding newStock to currentStock
            final double updatedStock = currentStock + newStock;
            print('New Stock Value: $newStock');
            print('Update Stock Value: $updatedStock');

            // Send PUT request to update stock
            final updateUrl =
                '$IpAddress/SettingsProductDetailsalldatas/$productId/';
            final updateResponse = await http.put(
              Uri.parse(updateUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'stockvalue': updatedStock,
                'cusid': cusid, // Ensure cusid is included in the request
              }),
            );

            if (updateResponse.statusCode == 200) {
              print(
                  'Stock updated successfully for product "$productName". New stock: $updatedStock');
              return true; // Product found and stock updated
            } else {
              print(
                  'Failed to update stock for product "$productName". Status Code: ${updateResponse.statusCode}');
              // print('Response Body: ${updateResponse.body}');
              return false; // Failed to update stock
            }
          } else {
            print(
                'The product name "$productName" does not exist in the API data.');
            return false; // Product not found
          }
        } else {
          print('Failed to load product data');
          return false; // Failed to load data
        }
      } catch (e) {
        print('Error occurred: $e');
        return false; // Error occurred
      }
    } // Function to fetch product details and check if they exist, including addstock

    Future<void> fetchProductDetails(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      List<String> productDetails = [];

      if (tableData.isEmpty) {
        print('No data available');
        return;
      }

      for (var data in tableData) {
        // Safely extract values with null checks and type conversions
        String productName = data['productName'] ?? 'Unknown Product';

        // Convert quantity to int if it's not already
        int quantity;
        try {
          quantity = int.tryParse(data['quantity'].toString()) ?? 0;
        } catch (e) {
          print('Error parsing quantity for item $productName: $e');
          quantity = 0;
        }

        // Fetch the addstock value (Yes/No)
        String addStock = data['addstock'] ?? 'No'; // Default to 'No' if null

        // Add product details to the list, including addstock
        productDetails.add(
          "{item: ${productName}, qty: ${quantity}, addstock: ${addStock}}",
        );

        // Check if the product exists and update stock if addstock is Yes
        if (addStock.toLowerCase() == 'yes') {
          // Check if the product exists in the API
          final productExists = await NewcheckProductExists(productName);
          if (productExists) {
            // Fetch and update stock if the product exists
            await fetchAndUpdateStock(productName, quantity);
          } else {
            // If product does not exist, fetch the product ID and update the stock
            final productId = await fetchProductId(productName);
            if (productId != null) {
              await fetchAndUpdateStockById(productId, quantity);
            } else {
              print('Product "$productName" not found and cannot be updated.');
            }
          }
        }
      }

      // Print all collected product details
      print('Product Details: $productDetails');
    }

    TextEditingController _DateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

    Future _saveStockDetailsAndRoundToAPI(List<Map<String, dynamic>> tableData,
        String purchaseRecordNo, DateTime selectedDate) async {
      if (tableData.isEmpty ||
          widget.purchaseSupplierNameController.text.isEmpty) {
        // showEmptyWarning();
        return;
      }

      List<Map<String, dynamic>> StockDetailsData = [];
      String RecordNo = widget.purchaseRecordNoController.text;
      Set<String> uniqueItems = Set<String>();

      for (var i = 0; i < tableData.length; i++) {
        var rowData = tableData[i];

        String productName = rowData['productName'];
        int qty = int.tryParse(rowData['quantity'].toString()) ?? 0;

        // Add the product name to the set of unique items
        uniqueItems.add(productName);

        StockDetailsData.add({
          'serialno': RecordNo,
          'agentname': widget.purchaseSupplierNameController.text,
          'date': _DateController.text,
          'productname': productName,
          'qty': qty,
        });
      }

      // Calculate the number of unique items
      int itemCount = uniqueItems.length;

      String StockDetailsJson = json.encode(StockDetailsData);

      String? cusid = await SharedPrefs.getCusId();
      String apiUrl = '$IpAddress/Stock_Details_Roundalldata/';
      Map<String, dynamic> postData = {
        "cusid": cusid,
        'serialno': RecordNo,
        'date': _DateController.text,
        'agentname': widget.purchaseSupplierNameController.text,
        'itemcount': itemCount.toString(), // Use the count of unique items
        'status': 'PurchaseStock',
        'StockDetails': StockDetailsJson,
      };

      print('Processed Data: $postData');

      try {
        http.Response response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode(postData),
          headers: {'Content-Type': 'application/json'},
        );

        if (mounted) {
          if (response.statusCode == 201) {
            print('Data saved successfully');

            await logreports(
                'Stock Entry: ${widget.purchaseSupplierNameController.text}_Inserted');
            successfullySavedMessage(context);
            postDataWithIncrementedSerialNo();
            widget.purchaseSupplierNameController.clear();
          } else {
            print('Failed to save data. Status code: ${response.statusCode}');
            print('Response Body: ${response.body}');
          }
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.07;

    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.06;
    return Padding(
      padding: EdgeInsets.only(
        bottom: !Responsive.isDesktop(context) ? 10 : 0,
        right: 20,
        left: !Responsive.isDesktop(context) ? 20 : 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            height: Responsive.isDesktop(context)
                ? screenHeight * 0.68
                : MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey)), // height: 420,

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: Responsive.isMobile(context) ||
                                Responsive.isTablet(context)
                            ? 20
                            : 15,
                        right: 0),
                    child: Column(
                      children: [
                        if (Responsive.isMobile(context) ||
                            Responsive.isTablet(context))
                          SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 8),
                                      child: Text("No.Of.Product:",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          // color: Colors.grey[200],
                                          child: Text(
                                              "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getProductCountCallback(widget.tableData))}",
                                              style: textStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Responsive.isDesktop(context))
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                              if (!Responsive.isDesktop(context))
                                SizedBox(width: 20),
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 8),
                                      child: Text("Total Qty",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          child: Text(
                                              "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getTotalQuantityCallback(widget.tableData))}",
                                              style: textStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              // color: Subcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 5),
                                    child: Text("Taxable ₹",
                                        style: commonLabelTextStyle),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 8),
                                    child: Container(
                                      width: Responsive.isDesktop(context)
                                          ? desktopcontainerdwidth
                                          : MediaQuery.of(context).size.width *
                                              0.38,
                                      child: Container(
                                        height: 27,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : 100,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            controller: TaxableController,
                                            readOnly: true,
                                            onChanged: (newvalue) {},
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (Responsive.isDesktop(context))
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                            if (!Responsive.isDesktop(context))
                              SizedBox(width: 20),
                            Container(
                              // color: Subcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 5),
                                    child: Text("Discount %",
                                        style: commonLabelTextStyle),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 8),
                                    child: Container(
                                      width: Responsive.isDesktop(context)
                                          ? desktopcontainerdwidth
                                          : MediaQuery.of(context).size.width *
                                              0.38,
                                      child: Container(
                                        height: 27,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : 100,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode: widget
                                                .finaldiscountPercFocusNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    widget
                                                        .finaldiscountPercFocusNode,
                                                    FinalDiscountAmtFocusNode),
                                            controller:
                                                purchaseDisPercentageController,
                                            onChanged: (newValue) {
                                              // Convert the input value to a double
                                              double newPercentage =
                                                  double.tryParse(newValue) ??
                                                      0.0;
                                              purchaseDisPercentageController
                                                      .text =
                                                  newPercentage.toString();
                                              calculateDiscountAmount();
                                              CalculateCGSTFinalAmount();
                                              CalculateSGSTFinalAmount();
                                              calculatetotalAmount();
                                              calculateFinalTaxableAmount();
                                              calculateFinaltotalAmount();

                                              purchaseDisPercentageController
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset:
                                                              purchaseDisPercentageController
                                                                  .text
                                                                  .length));
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              // color: Subcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 5),
                                    child: Text("Discount ₹",
                                        style: commonLabelTextStyle),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 8),
                                    child: Container(
                                      width: Responsive.isDesktop(context)
                                          ? desktopcontainerdwidth
                                          : MediaQuery.of(context).size.width *
                                              0.38,
                                      child: Container(
                                        height: 27,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : 100,
                                        color: Colors.grey[200],
                                        child: TextFormField(
                                            focusNode:
                                                FinalDiscountAmtFocusNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                _fieldFocusChange(
                                                    context,
                                                    FinalDiscountAmtFocusNode,
                                                    RoundOffFocusNode),
                                            controller:
                                                purchaseDisAMountController,
                                            onChanged: (newvalue) {
                                              calculateDiscountPercentage();
                                              CalculateCGSTFinalAmount();
                                              CalculateSGSTFinalAmount();

                                              calculateFinaltotalAmount();
                                              calculatetotalAmount();
                                              calculateFinalTaxableAmount();

                                              purchaseDisAMountController
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset:
                                                              purchaseDisAMountController
                                                                  .text
                                                                  .length));
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: textStyle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (Responsive.isDesktop(context))
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                            if (!Responsive.isDesktop(context))
                              SizedBox(width: 20),
                            Container(
                              // color: Subcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 5),
                                    child: Text("Final Taxable ₹",
                                        style: commonLabelTextStyle),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 0, top: 8),
                                    child: Container(
                                      width: Responsive.isDesktop(context)
                                          ? desktopcontainerdwidth
                                          : MediaQuery.of(context).size.width *
                                              0.38,
                                      child: Container(
                                        height: 27,
                                        width: Responsive.isDesktop(context)
                                            ? desktoptextfeildwidth
                                            : 100,
                                        color: Colors.grey[200],
                                        child: TextField(
                                            controller: finalTaxableController,
                                            onChanged: (newValue) {
                                              finalTaxableAmountinitialValue =
                                                  newValue;
                                              // purchaseDisPercentageController.clear();
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 7.0,
                                              ),
                                            ),
                                            style: AmountTextStyle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Text("CGST ₹",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          // color: Colors.grey[200],
                                          child: TextField(
                                              controller: CGSTAmountController,
                                              onChanged: (newValue) {
                                                CGSTAmountInitialvalue =
                                                    newValue;
                                                // purchaseDisPercentageController.clear();
                                              },
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 7.0,
                                                ),
                                              ),
                                              style: AmountTextStyle),
                                          // Text(
                                          //   "${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.getTotalCGSTAmtCallback(widget.tableData))}",
                                          //   style: TextStyle(
                                          //     color: Colors.black,
                                          //     fontSize: 13,
                                          //     fontWeight: FontWeight.w600,
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Responsive.isDesktop(context))
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                              if (!Responsive.isDesktop(context))
                                SizedBox(width: 20),
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Text("SGST ₹",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          child: TextField(
                                              controller: SGSTAmountController,
                                              onChanged: (newValue) {
                                                SGSTAmountInitialvalue =
                                                    newValue;
                                                // purchaseDisPercentageController.clear();
                                              },
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 7.0,
                                                ),
                                              ),
                                              style: AmountTextStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Text("Total ₹",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          child: TextField(
                                              controller: TotalAmountController,
                                              onChanged: (newValue) {
                                                totalAmountInitialvalue =
                                                    newValue;
                                                // purchaseDisPercentageController.clear();
                                              },
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 7.0,
                                                ),
                                              ),
                                              style: AmountTextStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Responsive.isDesktop(context))
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                              if (!Responsive.isDesktop(context))
                                SizedBox(width: 20),
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Text("Round off(+/-)",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          color: Colors.grey[200],
                                          child: TextFormField(
                                              focusNode: RoundOffFocusNode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      RoundOffFocusNode,
                                                      FinalTotalAmountFocusNode),
                                              controller:
                                                  purchaseRoundOffController,
                                              onChanged: (newValue) {
                                                calculateFinaltotalAmount();
                                              },
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 7.0,
                                                ),
                                              ),
                                              style: textStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Text("Final Amount ₹",
                                          style: commonLabelTextStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 8),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? desktopcontainerdwidth
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.38,
                                        child: Container(
                                          height: 27,
                                          width: Responsive.isDesktop(context)
                                              ? desktoptextfeildwidth
                                              : 100,
                                          color: Colors.grey[200],
                                          child: TextFormField(
                                              focusNode:
                                                  FinalTotalAmountFocusNode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      FinalTotalAmountFocusNode,
                                                      saveallButtonFocusNode),
                                              controller:
                                                  FinalTotalAmountController,
                                              onChanged: (newValue) {
                                                FinalTotalAmtInitialValue =
                                                    newValue;
                                                // purchaseDisPercentageController.clear();
                                              },
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 7.0,
                                                ),
                                              ),
                                              style: AmountTextStyle),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!Responsive.isDesktop(context))
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 0
                                          : 10.0,
                                      top: Responsive.isDesktop(context)
                                          ? 0
                                          : 25.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          Responsive.isDesktop(context)
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          // color: Colors.green,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: Responsive.isDesktop(
                                                            context)
                                                        ? 20
                                                        : 0,
                                                    top: 0),
                                                child: Container(
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? 60
                                                      : 70,
                                                  child: ElevatedButton(
                                                    focusNode:
                                                        saveallButtonFocusNode,
                                                    onPressed: () async {
                                                      // Check if any mandatory fields are empty
                                                      if (widget.purchaseInvoiceNoController.text.isEmpty ||
                                                          widget
                                                              .purchaseSupplierAgentidController
                                                              .text
                                                              .isEmpty ||
                                                          widget.tableData
                                                              .isEmpty ||
                                                          purchaseDisAMountController
                                                              .text.isEmpty ||
                                                          purchaseRoundOffController
                                                              .text.isEmpty ||
                                                          purchaseDisPercentageController
                                                              .text.isEmpty) {
                                                        // Show error message if validation fails
                                                        WarninngMessage(
                                                            context);
                                                        return;
                                                      }

                                                      // Fetch product details
                                                      // try {
                                                      //   await fetchProductDetails(
                                                      //     widget.tableData,
                                                      //     widget
                                                      //         .purchaseRecordNoController
                                                      //         .text,
                                                      //     widget.selectedDate,
                                                      //   );
                                                      // } catch (error) {
                                                      //   // Handle errors in fetchProductDetails
                                                      //   print(
                                                      //       "Error fetching product details: $error");
                                                      //   return; // Stop further execution if this fails
                                                      // }
                                                      // try {
                                                      //   await _saveStockDetailsAndRoundToAPI(
                                                      //     widget.tableData,
                                                      //     widget
                                                      //         .purchaseRecordNoController
                                                      //         .text,
                                                      //     widget.selectedDate,
                                                      //   );
                                                      // } catch (error) {
                                                      //   print(
                                                      //       "error posting stock details : $error");
                                                      // }
                                                      // // Post data to API
                                                      // try {
                                                      //   await postDataToAPI(
                                                      //     widget.tableData,
                                                      //     widget
                                                      //         .purchaseRecordNoController
                                                      //         .text,
                                                      //     widget.selectedDate,
                                                      //   );
                                                      // } catch (error) {
                                                      //   // Handle errors in posting data
                                                      //   print(
                                                      //       "Error posting data to API: $error");
                                                      // }
                                                      // try {
                                                      //   postDataWithIncrementedSerialNo();
                                                      // } catch (error) {
                                                      //   // Handle errors in adding row material
                                                      //   print(
                                                      //       "Error increament serial no: $error");
                                                      // }
                                                      fetchProductDetails(
                                                          widget.tableData,
                                                          widget
                                                              .purchaseRecordNoController
                                                              .text,
                                                          widget.selectedDate);
                                                      postDataToAPI(
                                                          widget.tableData,
                                                          widget
                                                              .purchaseRecordNoController
                                                              .text,
                                                          widget.selectedDate);
                                                      postDataWithIncrementedSerialNo();
                                                      _addRowMaterial(
                                                          widget.tableData);
                                                      _saveStockDetailsAndRoundToAPI(
                                                          widget.tableData,
                                                          widget
                                                              .purchaseRecordNoController
                                                              .text,
                                                          widget.selectedDate);
                                                      // Add row material or any other logic
                                                      try {
                                                        _addRowMaterial(
                                                            widget.tableData);
                                                      } catch (error) {
                                                        // Handle errors in adding row material
                                                        print(
                                                            "Error adding row material: $error");
                                                      }

                                                      // Log product category for debugging purposes
                                                      print(
                                                          "Product Category: ${widget.ProductCategoryController.text}");
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2.0),
                                                            ),
                                                            backgroundColor:
                                                                subcolor,
                                                            minimumSize: Size(
                                                                25.0,
                                                                10.0), // Set width and height
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10.0)),
                                                    child: Text('Save',
                                                        style: commonWhiteStyle
                                                            .copyWith(
                                                                fontSize: 14)),
                                                  ),
                                                ),
                                                //   child: ElevatedButton(
                                                //     focusNode: saveallButtonFocusNode,
                                                //     onPressed: () {
                                                //       // if (widget.purchaseInvoiceNoController.text.isEmpty ||
                                                //       //     widget
                                                //       //         .purchaseSupplierAgentidController
                                                //       //         .text
                                                //       //         .isEmpty ||
                                                //       //     widget.tableData.isEmpty ||
                                                //       //     purchaseDisAMountController
                                                //       //         .text.isEmpty ||
                                                //       //     purchaseRoundOffController
                                                //       //         .text.isEmpty ||
                                                //       //     purchaseDisPercentageController
                                                //       //         .text.isEmpty) {
                                                //       //   // Show error message
                                                //       //   WarninngMessage(context);
                                                //       //   return;
                                                //       // }
                                                //       fetchProductDetails(
                                                //           widget.tableData,
                                                //           widget
                                                //               .purchaseRecordNoController
                                                //               .text,
                                                //           widget.selectedDate);
                                                //       // postDataToAPI(
                                                //       //     widget.tableData,
                                                //       //     widget
                                                //       //         .purchaseRecordNoController
                                                //       //         .text,
                                                //       //     widget.selectedDate);
                                                //       // Post__purchaseDetails(
                                                //       //     widget.tableData,
                                                //       //     widget.purchaseRecordNoController.text,
                                                //       //     widget.selectedDate);
                                                //       // postDataWithIncrementedSerialNo();

                                                //       _addRowMaterial(
                                                //         widget.tableData,
                                                //       );

                                                //       // print(
                                                //       //     "Product Category:${widget.ProductCategoryController.text}");
                                                //     },
                                                //     style: ElevatedButton.styleFrom(
                                                //       shape: RoundedRectangleBorder(
                                                //         borderRadius:
                                                //             BorderRadius.circular(
                                                //                 2.0),
                                                //       ),
                                                //       backgroundColor: subcolor,
                                                //       minimumSize: Size(
                                                //           Responsive.isDesktop(
                                                //                   context)
                                                //               ? 45.0
                                                //               : 30,
                                                //           Responsive.isDesktop(
                                                //                   context)
                                                //               ? 31.0
                                                //               : 25), // Set width and height
                                                //     ),
                                                //     child: Text('Save',
                                                //         style: commonWhiteStyle),
                                                //   ),
                                                // ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!Responsive.isDesktop(context))
                                          SizedBox(width: 5),
                                        Container(
                                          // color: Subcolor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: Responsive.isDesktop(
                                                            context)
                                                        ? 20
                                                        : 0,
                                                    top: 0),
                                                child: Container(
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? 75
                                                      : 85,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Clear();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2.0),
                                                            ),
                                                            backgroundColor:
                                                                subcolor,
                                                            minimumSize: Size(
                                                                25.0,
                                                                10.0), // Set width and height
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10.0)),
                                                    child: Text('Refresh',
                                                        style: commonWhiteStyle
                                                            .copyWith(
                                                                fontSize: 14)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (Responsive.isDesktop(context)) SizedBox(height: 15),
                  if (Responsive.isDesktop(context))
                    Padding(
                      padding: EdgeInsets.only(
                        left: Responsive.isDesktop(context) ? 0 : 48.0,
                      ),
                      child: Row(
                          mainAxisAlignment: Responsive.isDesktop(context)
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              // color: Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isDesktop(context)
                                              ? 20
                                              : 0,
                                          top: 0),
                                      child: Container(
                                        width: 90,
                                        child: ElevatedButton(
                                          focusNode: saveallButtonFocusNode,
                                          onPressed: () async {
                                            // Check if any mandatory fields are empty
                                            if (widget.purchaseInvoiceNoController.text.isEmpty ||
                                                widget
                                                    .purchaseSupplierAgentidController
                                                    .text
                                                    .isEmpty ||
                                                widget.tableData.isEmpty ||
                                                purchaseDisAMountController
                                                    .text.isEmpty ||
                                                purchaseRoundOffController
                                                    .text.isEmpty ||
                                                purchaseDisPercentageController
                                                    .text.isEmpty) {
                                              // Show error message if validation fails
                                              WarninngMessage(context);
                                              return;
                                            }
                                            fetchProductDetails(
                                                widget.tableData,
                                                widget
                                                    .purchaseRecordNoController
                                                    .text,
                                                widget.selectedDate);
                                            postDataToAPI(
                                                widget.tableData,
                                                widget
                                                    .purchaseRecordNoController
                                                    .text,
                                                widget.selectedDate);
                                            postDataWithIncrementedSerialNo();
                                            _addRowMaterial(widget.tableData);
                                            _saveStockDetailsAndRoundToAPI(
                                                widget.tableData,
                                                widget
                                                    .purchaseRecordNoController
                                                    .text,
                                                widget.selectedDate);

                                            // Fetch product details
                                            // try {
                                            //   await fetchProductDetails(
                                            //     widget.tableData,
                                            //     widget
                                            //         .purchaseRecordNoController
                                            //         .text,
                                            //     widget.selectedDate,
                                            //   );
                                            // } catch (error) {
                                            //   // Handle errors in fetchProductDetails
                                            //   print(
                                            //       "Error fetching product details: $error");
                                            //   return; // Stop further execution if this fails
                                            // }
                                            // try {
                                            //   await _saveStockDetailsAndRoundToAPI(
                                            //     widget.tableData,
                                            //     widget
                                            //         .purchaseRecordNoController
                                            //         .text,
                                            //     widget.selectedDate,
                                            //   );
                                            // } catch (error) {
                                            //   print(
                                            //       "error posting stock details : $error");
                                            // }
                                            // Post data to API
                                            // try {
                                            //   await postDataToAPI(
                                            //     widget.tableData,
                                            //     widget
                                            //         .purchaseRecordNoController
                                            //         .text,
                                            //     widget.selectedDate,
                                            //   );
                                            // } catch (error) {
                                            //   // Handle errors in posting data
                                            //   print(
                                            //       "Error posting data to API: $error");
                                            // }
                                            // try {
                                            //   postDataWithIncrementedSerialNo();
                                            // } catch (error) {
                                            //   // Handle errors in adding row material
                                            //   print(
                                            //       "Error increament serial no: $error");
                                            // }

                                            // Add row material or any other logic
                                            // try {
                                            //   _addRowMaterial(widget.tableData);
                                            // } catch (error) {
                                            //   // Handle errors in adding row material
                                            //   print(
                                            //       "Error adding row material: $error");
                                            // }

                                            // Log product category for debugging purposes
                                            print(
                                                "Product Category: ${widget.ProductCategoryController.text}");
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
                                              ),
                                              backgroundColor: subcolor,
                                              minimumSize: Size(22.0,
                                                  31.0), // Set width and height
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 16.0)),
                                          child: Text('Save',
                                              style: commonWhiteStyle.copyWith(
                                                  fontSize: 14)),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            //POST BUTTON
                            // if (!Responsive.isDesktop(context)) SizedBox(width: 20),
                            // Container(
                            //   // color: Subcolor,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Padding(
                            //         padding: EdgeInsets.only(
                            //             left:
                            //                 Responsive.isDesktop(context) ? 20 : 0,
                            //             top: 0),
                            //         child: Container(
                            //           width: 90,
                            //           child: ElevatedButton(
                            //             onPressed: () {
                            //               fetchProductDetails(
                            //                   widget.tableData,
                            //                   widget
                            //                       .purchaseRecordNoController.text,
                            //                   widget.selectedDate);
                            //             },
                            //             style: ElevatedButton.styleFrom(
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius:
                            //                     BorderRadius.circular(2.0),
                            //               ),
                            //               backgroundColor: subcolor,
                            //               minimumSize: Size(
                            //                   45.0, 31.0), // Set width and height
                            //             ),
                            //             child:
                            //                 Text('post', style: commonWhiteStyle),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            //REFRESH BUTTON
                            if (!Responsive.isDesktop(context))
                              SizedBox(width: 20),
                            Container(
                              // color: Subcolor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: Responsive.isDesktop(context)
                                            ? 20
                                            : 0,
                                        top: 0),
                                    child: Container(
                                      width: 90,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Clear();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                          backgroundColor: subcolor,
                                          minimumSize: Size(45.0,
                                              31.0), // Set width and height
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 10.0), // Add padding
                                        ),
                                        child: Text('Refresh',
                                            style: commonWhiteStyle.copyWith(
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  SizedBox(height: 10),
                ],
              ),
            )),
      ),
    );
  }
}
