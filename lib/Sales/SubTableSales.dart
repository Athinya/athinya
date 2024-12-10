import 'dart:async';

import 'package:ProductRestaurant/Settings/StaffDetails.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Sales/NewSales.dart';
import 'package:ProductRestaurant/Settings/AddProductsDetails.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

class tablesalesview extends StatefulWidget {
  final TextEditingController ProductSalesTypeController;
  final TextEditingController SalesPaytype;

  tablesalesview({
    required this.ProductSalesTypeController,
    required this.SalesPaytype,
  });
  @override
  State<tablesalesview> createState() => _tablesalesviewState();
}

class _tablesalesviewState extends State<tablesalesview> {
  String? selectedValue;
  late Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  DateTime? _startTime;
  Map<String, int> _elapsedTimes = {};

  List<dynamic> _tableData = [];
  TextEditingController TableNoController = TextEditingController();

  TextEditingController SCodeController = TextEditingController();
  TextEditingController SNameController = TextEditingController();
  TextEditingController TableCusNameController = TextEditingController();
  TextEditingController TableContactController = TextEditingController();
  TextEditingController TableAddressController = TextEditingController();
  TextEditingController TableCodeController = TextEditingController();
  TextEditingController TableItemController = TextEditingController();
  TextEditingController TableAmountController = TextEditingController();
  TextEditingController TableProdutMakingCostController =
      TextEditingController();
  TextEditingController TableProdutCategoryController = TextEditingController();

  TextEditingController TableQuantityController = TextEditingController();

  TextEditingController TotalAmtController = TextEditingController();
  TextEditingController CGSTperccontroller = TextEditingController();
  TextEditingController SGSTPercController = TextEditingController();
  TextEditingController CGSTAmtController = TextEditingController();
  TextEditingController SGSTAmtController = TextEditingController();
  TextEditingController FinalAmtController = TextEditingController();

  TextEditingController Taxableamountcontroller = TextEditingController();
  TextEditingController SalesGstMethodController = TextEditingController();
  TextEditingController salestypecontroller = TextEditingController();

  String tableKey = ' ';

  double totalAmount = 0.0;
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchProductNameList();
    fetchGSTMethod();
    salestypecontroller = widget.ProductSalesTypeController;
    _loadSavedData();
    _startTimer();
    _loadPreferences();
    _stopTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Update state
        });
      }
    });
    updateTotalAmount();
    FinalAmtController.text = calculateTotalAmount().toStringAsFixed(2);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _stopTimer();
    super.dispose();
  }

  FocusNode scodeFocusNode = FocusNode();
  FocusNode snameFocusNode = FocusNode();
  FocusNode CusnameFocusNode = FocusNode();
  FocusNode CusContactFocusNode = FocusNode();

  FocusNode CusAddressFocusNode = FocusNode();

  FocusNode codeFocusNode = FocusNode();
  FocusNode itemFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode quantityFocusNode = FocusNode();
  FocusNode finaltotFocusNode = FocusNode();

  FocusNode addbuttonFocusNode = FocusNode();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<String> ProductNameList = [];

  Future<void> fetchProductNameList() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
              results.map<String>((item) => item['name'].toString()));
          // print("payment List : $ProductNameList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      // print('All product categories: $ProductNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? ProductNameSelected;

  int? _selectedProductnameIndex;

  bool _isProductnameOptionsVisible = false;
  int? _ProductnamehoveredIndex;
  Widget _buildProductnameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 15,
          ),
          SizedBox(width: 3),
          Container(
            // width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    color: Colors.grey[100],
                    height: 23,
                    width: Responsive.isDesktop(context)
                        ? MediaQuery.of(context).size.width * 0.08
                        : MediaQuery.of(context).size.width * 0.2,
                    child: ProductnameDropdown()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: Container(
                        width: 1350,
                        height: 800,
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            AddProductDetailsPage(),
                            Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.red, size: 23),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  fetchproductName();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(color: subcolor),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Text(
                    "+",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ProductnameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(TableItemController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                TableItemController.text = ProductNameList[currentIndex + 1];
                _isProductnameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(TableItemController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                TableItemController.text = ProductNameList[currentIndex - 1];
                _isProductnameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: itemFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchproductcode();
            _fieldFocusChange(context, itemFocusNode, quantityFocusNode);
          },
          controller: TableItemController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            contentPadding: EdgeInsets.only(bottom: 10, left: 5),
            labelStyle: DropdownTextStyle,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) async {
            setState(() {
              _isProductnameOptionsVisible = true;
              ProductNameSelected = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProductnameOptionsVisible && pattern.isNotEmpty) {
            return ProductNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProductnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProductnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(TableItemController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    suggestion,
                    style: DropdownTextStyle,
                  ),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (String? suggestion) async {
          setState(() {
            fetchproductcode();

            TableItemController.text = suggestion!;
            ProductNameSelected = suggestion;
            _isProductnameOptionsVisible = false;

            FocusScope.of(context).requestFocus(quantityFocusNode);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  bool isProductAlreadyExists(String productName) {
    // Assuming table data is stored in a List<Map<String, dynamic>> called tableData
    for (var item in salestableData) {
      if (item['productName'] == productName) {
        return true;
      }
    }
    return false;
  }

  void productalreadyexist() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'This product is already in the table data.',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  List<Map<String, dynamic>> productList = [];
  Future<List<Map<String, dynamic>>> salesProductList() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String url = '$IpAddress/Settings_ProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          for (var product in results) {
            // Extracting required fields and creating a map
            Map<String, dynamic> productMap = {
              'name': product['name'],
              'stock': product['stock'],
              'stockvalue': product['stockvalue']
            };

            // Adding the map to the list
            productList.add(productMap);
          }
          // print("product list : $productList");

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }

    return productList;
  }

  Future<void> fetchproductName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String ProductCode =
        TableCodeController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductCodeController Name: $ProductCode");

    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each customer entry
          for (var entry in results) {
            if (entry['code'].toString().toLowerCase() == ProductCode) {
              // Convert to lowercase
              // Retrieve the contact number and address for the customer
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String name = entry['name'];
              String agentId = entry['id'].toString();
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (ProductCode.isNotEmpty) {
                TableItemController.text = name;
                TableAmountController.text = amount;
                TableAmountController.text = amount;
                TableProdutMakingCostController.text = makingcost;
                TableProdutCategoryController.text = category;

                CGSTperccontroller.text = cgstperc;
                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // print("CGst Percentages:${CGSTperccontroller.text}");
          // print("Sgst Percentages:${SGSTPercController.text}");
          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load customer contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {
        // print("No contact number found for $ProductCode");
      }
    } catch (e) {
      print('Error fetching customer contact information: $e');
    }
  }

  Future<void> fetchproductcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
    String productName =
        TableItemController.text.toLowerCase(); // Convert to lowercase
    bool contactFound = false;
    // print("ProductNameController Name: $productName");
    String salestype = widget.ProductSalesTypeController.text;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each product entry
          for (var entry in results) {
            if (entry['name'].toString().toLowerCase() == productName) {
              // Convert to lowercase
              // Retrieve the code and id for the product
              String code = entry['code'];
              String agentId = entry['id'].toString();

              // Determine the amount based on the salestype
              String amount = '';
              if (salestype == 'DineIn') {
                amount = entry['amount'];
              } else if (salestype == 'TakeAway') {
                amount = entry['wholeamount'];
              }
              String makingcost = entry['makingcost'];
              String category = entry['category'];

              String cgstperc = entry['cgstper'];
              String sgstperc = entry['sgstper'];

              if (productName.isNotEmpty) {
                TableCodeController.text = code;
                TableAmountController.text = amount;
                TableProdutMakingCostController.text = makingcost;
                TableProdutCategoryController.text = category;

                CGSTperccontroller.text = cgstperc;

                SGSTPercController.text = sgstperc;

                contactFound = true;
                break; // Exit the loop once the product information is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or product information found
            break;
          }
        } else {
          throw Exception(
              'Failed to load product information: ${response.reasonPhrase}');
        }
      }

      // Print a message if product information not found
      if (!contactFound) {
        // print("No product information found for $productName");
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchSName() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/StaffDetails/$cusid/';
    String productCode = SCodeController.text; // Code entered by the user
    // print("Code : ${SCodeController.text}");

    try {
      String url = '$baseUrl?code=$productCode'; // Append code to URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          // Filter the results based on the entered code
          var filteredResults =
              results.where((entry) => entry['code'] == productCode);

          if (filteredResults.isNotEmpty) {
            // Clear previous names
            SNameController.clear();

            // Retrieve the product name for the specific code
            String name = filteredResults.first['serventname'];

            // Update the SNameController with the retrieved name
            SNameController.text = name;
          } else {
            // print('No product found for code: $productCode');
          }
        } else {
          // print('No products found for code: $productCode');
        }
      } else {
        throw Exception(
            'Failed to load product information: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchcode() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/StaffDetails/$cusid/';
    String productName = SNameController.text; // Code entered by the user
    // print("Code : ${SCodeController.text}");

    try {
      String url = '$baseUrl?serventname=$productName'; // Append code to URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          // Filter the results based on the entered code
          var filteredResults =
              results.where((entry) => entry['serventname'] == productName);

          if (filteredResults.isNotEmpty) {
            // Clear previous names
            SCodeController.clear();

            // Retrieve the product name for the specific code
            String code = filteredResults.first['code'];

            // Update the SNameController with the retrieved name
            SCodeController.text = code;
          } else {
            // print('No product found for code: $productName');
          }
        } else {
          // print('No products found for code: $productName');
        }
      } else {
        throw Exception(
            'Failed to load product information: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching product information: $e');
    }
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/Sales_tableCount/$cusid/'));
    if (response.statusCode == 200) {
      setState(() {
        _tableData = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchGSTMethod() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/GstDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    String gstMethod = ''; // Initialize GST method to empty string

    // Iterate through each entry in the JSON data
    for (var entry in jsonData) {
      // Check if the name is "Sales"
      if (entry['name'] == "Sales") {
        // Retrieve the GST method for "Sales"
        gstMethod = entry['gst'];
        break; // Exit the loop once the entry is found
      }
    }

    // Update rateController if needed
    if (gstMethod.isNotEmpty) {
      SalesGstMethodController.text = gstMethod;
      // print("GST method for Sales: ${SalesGstMethodController.text}");
      // print("GST method for Sales: $gstMethod");
    } else {
      // print("No GST method found for Sales");
    }
  }

  void updateCGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    CGSTAmtController.text = cgstAmount.toStringAsFixed(2);
    // print("CGST amont = ${CGSTAmtController.text}");
  }

  void updateSGSTAmount() {
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    SGSTAmtController.text = sgstAmount.toStringAsFixed(2);
    // print("SGZGST amont = ${SGSTAmtController.text}");
  }

  void updateTotal() {
    double rate = double.tryParse(TableAmountController.text) ?? 0;
    double quantity = double.tryParse(TableQuantityController.text) ?? 0;
    double total = rate * quantity;
    TotalAmtController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
    // Taxableamountcontroller.text = total.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;
    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double cgstPercentage = double.tryParse(CGSTperccontroller.text) ?? 0;
    double sgstPercentage = double.tryParse(SGSTPercController.text) ?? 0;

    double numeratorPart1 = total;

    if (SalesGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    } else {
      double taxableAmount = numeratorPart1;
      Taxableamountcontroller.text = taxableAmount.toStringAsFixed(2);
      // print("total taxable amount = ${Taxableamountcontroller.text}");
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalAmtController.text) ?? 0;

    double cgstAmount = double.tryParse(CGSTAmtController.text) ?? 0;
    double sgstAmount = double.tryParse(SGSTAmtController.text) ?? 0;
    double taxableAmount = double.tryParse(Taxableamountcontroller.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;

    if (SalesGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;
      // print("FIanl amount = ${taxableAmount} + ${denominator}");

      // Update the final amount controller
      FinalAmtController.text = finalAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else if (SalesGstMethodController.text == "Including") {
      double totalfinalamount = total;
      FinalAmtController.text = totalfinalamount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    } else {
      double taxableAmount = total;
      FinalAmtController.text = taxableAmount.toStringAsFixed(2);
      // print("FIanl amount = ${FinalAmtController.text}");
    }
  }

  void _saveText(
      String tableno,
      String scodeValue,
      String snameValue,
      String customerNameValue,
      String customerContactValue,
      String addressValue,
      List<Map<String, dynamic>> tabledata,
      double totalAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tableDataJson = jsonEncode(tabledata);
    totalAmount = calculateTotalAmount();
    String jsonData = jsonEncode({
      'tableno': tableno,
      'scode': scodeValue,
      'sname': snameValue,
      'customerName': customerNameValue,
      'customerContact': customerContactValue,
      'address': addressValue,
      'tableData': tableDataJson,
      'startTime': _startTime?.toIso8601String() ?? '',
      'stopTime': _isRunning ? null : DateTime.now().toIso8601String(),
      'elapsedSeconds': _elapsedSeconds,
      'totalAmount': totalAmount,
    });
    // print('jsonData : $jsonData');
    // Construct unique key based on table number
    String key = 'table_$tableno';

    // Save the serialized data as a string with the unique key
    prefs.setString(key, jsonData);
  }

  void deleteTableData(String tableno) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Construct unique key based on table number
    String key = 'table_$tableno';

    // Remove data associated with the key
    prefs.remove(key);
  }

  late SharedPreferences prefs;
  String selectedCode = '';
  bool showTableNo = false;
  bool isSavedInSharedPreferences = false;

  void _loadSavedData() async {
    prefs = await SharedPreferences.getInstance();

    // Construct the key based on the selected table number
    String key = 'table_$selectedCode';

    // Retrieve the data associated with the selected table number
    String? jsonData = prefs.getString(key);

    // If data exists for the selected table number
    if (jsonData != null) {
      // Decode the JSON data
      Map<String, dynamic> data = jsonDecode(jsonData);

      // Populate the text fields with the retrieved data
      setState(() {
        SCodeController.text = data['scode'] ?? '';
        SNameController.text = data['sname'] ?? '';
        TableCusNameController.text = data['customerName'] ?? '';
        TableContactController.text = data['customerContact'] ?? '';
        TableAddressController.text = data['address'] ?? '';
        isSavedInSharedPreferences = true;
        finalsalestableData =
            List<Map<String, dynamic>>.from(jsonDecode(data['tableData']));
        _startTime = data['startTime'] != null
            ? DateTime.parse(data['startTime'])
            : null;
        _elapsedSeconds = data['elapsedSeconds'] ?? 0;

        _isRunning = data['stopTime'] ==
            null; // If stopTime is null, the timer is still running

        // If timer is running, start the timer
        if (_isRunning) {
          _startTimer();
        }
      });
    }
  }

  void _launchUrl(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime currentDatetime = DateTime.now();

    // Format date and time
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedTime = DateFormat('hh:mm:ss a').format(currentDatetime);

    // Get table number and server name from controllers
    String tableno = TableNoController.text;
    String serventName = SNameController.text;

    // Construct product details
    List<String> productDetails = [];
    for (var data in salestableData) {
      productDetails.add("${data['productName']},${data['quantity']}");
    }

    // Join product details into a single string
    String productDetailsString = productDetails.join(';');

    // Construct the dynamic URL
    String dynamicUrl =
        'http://192.168.10.139:82//print/DINE-IN%20ORDER/$tableno/$formattedDate/$formattedTime/$serventName/$productDetailsString';
    // http://192.168.10.140:82//print/DINE-IN%20ORDER/5/2024-08-21/12:30:00%20AM/John/product1,2;product2,3;product3,1/

    print('url : $dynamicUrl');

    // Launch the dynamic URL
    if (await canLaunch(dynamicUrl)) {
      await launch(
        dynamicUrl,
        enableJavaScript: true,
      ); // Enable JavaScript if necessary,forceSafariVC: false, forceWebView: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $dynamicUrl')),
      );
    }
  }

// Function to show the confirmation dialog
  Future<bool> _showDialogBox(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text('Print Confirmation'),
          content: Text('Do you want to print the receipt?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if "No" is pressed
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _launchUrl(context); // Launch the URL if "Yes" is pressed
                Navigator.of(context)
                    .pop(true); // Return false if "No" is pressed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.1;
    double desktoptextfeildwidth = MediaQuery.of(context).size.width * 0.07;
    double screenHeight = MediaQuery.of(context).size.height;
    TableNoController.text = selectedCode;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6),
                  // Render buttons conditionally based on showTableNo
                  if (!showTableNo)
                    for (var data in _tableData)
                      buildTableButton(
                        data['name'],
                        List.generate(int.parse(data['count']),
                            (index) => '${data['code']}${index + 1}'),
                        data['code'], // Pass the code for comparison
                      ),
                  // Show only the selected button's details when showTableNo is true
                  if (showTableNo)
                    SingleChildScrollView(
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: !Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.65
                            : MediaQuery.of(context).size.width * 0.65,
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              if (selectedCode.isNotEmpty)
                                Text("Table No : $selectedCode  ",
                                    style: HeadingStyle),
                              SizedBox(height: 12),
                              if (Responsive.isDesktop(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    tablesalesserventdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (Responsive.isDesktop(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    tablesalesproductdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (!Responsive.isDesktop(context))
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    tablesalesserventdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                    tablesalesproductdetails(
                                        context,
                                        desktopcontainerdwidth,
                                        desktoptextfeildwidth),
                                  ],
                                ),
                              if (!Responsive.isDesktop(context))
                                SizedBox(
                                  width: 20,
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    // color:subcolor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 20,
                                              top: Responsive.isDesktop(context)
                                                  ? 17
                                                  : 4),
                                          child: Container(
                                            width: Responsive.isDesktop(context)
                                                ? (updateenable ? 83 : 60)
                                                : 60,
                                            child: ElevatedButton(
                                              focusNode: addbuttonFocusNode,
                                              onPressed: () {
                                                updateenable
                                                    ? UpdateData()
                                                    : saveData();
                                                setState(() {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          codeFocusNode);
                                                });

                                                // print("finalamount :: ${FinallyyyAmounttts.text}");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  backgroundColor: subcolor,
                                                  minimumSize: Size(45.0,
                                                      31.0), // Set width and height
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 15.0)),
                                              child: Text(
                                                  updateenable
                                                      ? 'Update'
                                                      : 'Add',
                                                  style: commonWhiteStyle
                                                      .copyWith(fontSize: 14)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //addbutton
                                  // Container(
                                  //   // color:subcolor,
                                  //   child: Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Padding(
                                  //         padding: EdgeInsets.only(
                                  //             left:
                                  //                 Responsive.isDesktop(context)
                                  //                     ? 20
                                  //                     : 0,
                                  //             top: Responsive.isDesktop(context)
                                  //                 ? 17
                                  //                 : 14),
                                  //         child: Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               right: 13),
                                  //           child: StatefulBuilder(builder:
                                  //               (BuildContext context,
                                  //                   StateSetter setState) {
                                  //             return ElevatedButton(
                                  //               focusNode: addbuttonFocusNode,
                                  //               onPressed: () {
                                  //                 updateTotal();
                                  //                 updatetaxableamount();
                                  //                 updateCGSTAmount();
                                  //                 updateSGSTAmount();
                                  //                 updateFinalAmount();
                                  //                 addButtonPressed();

                                  //                 FocusScope.of(context)
                                  //                     .requestFocus(
                                  //                         codeFocusNode);
                                  //               },
                                  //               style: ElevatedButton.styleFrom(
                                  //                 shape: RoundedRectangleBorder(
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                           2.0),
                                  //                 ),
                                  //                 backgroundColor: subcolor,
                                  //                 minimumSize: Size(45.0,
                                  //                     31.0), // Set width and height
                                  //               ),
                                  //               child: Text('Add',
                                  //                   style: commonWhiteStyle),
                                  //             );
                                  //           }),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(width: 5),
                                  Container(
                                    // color:subcolor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 0,
                                              top: Responsive.isDesktop(context)
                                                  ? 17
                                                  : 14),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                cleardata();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                backgroundColor: subcolor,
                                                minimumSize: Size(45.0,
                                                    31.0), // Set width and height
                                              ),
                                              child: Text('Clear',
                                                  style: commonWhiteStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width
                                        : MediaQuery.of(context).size.width *
                                            0.8,
                                    // color: const Color.fromARGB(255, 255, 233, 231),
                                    child: Responsive.isDesktop(context)
                                        ? Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.6
                                                            : 480,
                                                        height: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.4
                                                            : 320,
                                                        // color: Colors.pink,
                                                        child:
                                                            tablesalesview()),
                                                    VerticalDivider(
                                                      color: Color.fromARGB(
                                                          255, 122, 122, 122),
                                                      thickness: 0.8,
                                                    ),
                                                    Container(
                                                        width: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.6
                                                            : 480,
                                                        height: Responsive
                                                                .isDesktop(
                                                                    context)
                                                            ? screenHeight * 0.4
                                                            : 320,
                                                        // color: Colors.yellow,
                                                        child:
                                                            tablesalesviewtableNo())
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width:
                                                          Responsive.isDesktop(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.6
                                                              : 480,
                                                      height: 40,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                _startTimer(); // Start the timer first

                                                                // Wait for the dialog to close and capture the result
                                                                bool
                                                                    dialogResult =
                                                                    await _showDialogBox(
                                                                        context);

                                                                // If the user pressed "Yes", proceed with other actions
                                                                if (dialogResult ==
                                                                    true) {
                                                                  _printResult(); // Execute print result
                                                                  lastsaveData(); // Execute save data

                                                                  String
                                                                      tableno =
                                                                      TableNoController
                                                                          .text;
                                                                  String
                                                                      scodeValue =
                                                                      SCodeController
                                                                          .text;
                                                                  String
                                                                      snameValue =
                                                                      SNameController
                                                                          .text;
                                                                  String
                                                                      customerNameValue =
                                                                      TableCusNameController
                                                                          .text;
                                                                  String
                                                                      customerContactValue =
                                                                      TableContactController
                                                                          .text;
                                                                  String
                                                                      addressValue =
                                                                      TableAddressController
                                                                          .text;

                                                                  List<Map<String, dynamic>>
                                                                      tabledata =
                                                                      finalsalestableData;

                                                                  // Ensure `scodeValue` is not empty before saving
                                                                  if (scodeValue
                                                                      .isNotEmpty) {
                                                                    _saveText(
                                                                      tableno,
                                                                      scodeValue,
                                                                      snameValue,
                                                                      customerNameValue,
                                                                      customerContactValue,
                                                                      addressValue,
                                                                      tabledata,
                                                                      totalAmount,
                                                                    );
                                                                  }
                                                                } else {
                                                                  // If "No" is pressed, handle accordingly (no URL launch, but save the data)
                                                                  lastsaveData(); // Still save the data even if "No" is pressed
                                                                }
                                                              },

                                                              // onPressed:
                                                              //     () async {
                                                              //   _startTimer(); // Start the timer first

                                                              //   // Wait for the dialog to close and capture the result
                                                              //   bool
                                                              //       dialogResult =
                                                              //       await _showDialogBox(
                                                              //           context);

                                                              //   // If the user pressed "Yes", proceed with other actions
                                                              //   if (dialogResult ==
                                                              //       true) {
                                                              //     _printResult(); // Execute print result
                                                              //     lastsaveData(); // Execute save data

                                                              //     String
                                                              //         tableno =
                                                              //         TableNoController
                                                              //             .text;
                                                              //     String
                                                              //         scodeValue =
                                                              //         SCodeController
                                                              //             .text;
                                                              //     String
                                                              //         snameValue =
                                                              //         SNameController
                                                              //             .text;
                                                              //     String
                                                              //         customerNameValue =
                                                              //         TableCusNameController
                                                              //             .text;
                                                              //     String
                                                              //         customerContactValue =
                                                              //         TableContactController
                                                              //             .text;
                                                              //     String
                                                              //         addressValue =
                                                              //         TableAddressController
                                                              //             .text;

                                                              //     List<Map<String, dynamic>>
                                                              //         tabledata =
                                                              //         finalsalestableData;

                                                              //     if (scodeValue
                                                              //         .isNotEmpty) {
                                                              //       _saveText(
                                                              //         tableno,
                                                              //         scodeValue,
                                                              //         snameValue,
                                                              //         customerNameValue,
                                                              //         customerContactValue,
                                                              //         addressValue,
                                                              //         tabledata,
                                                              //         totalAmount,
                                                              //       );
                                                              //     }
                                                              //   } else {
                                                              //     // Handle the case where the user pressed "No" if needed
                                                              //   }
                                                              // },

                                                              style:
                                                                  ElevatedButton
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
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Save',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                          //       ElevatedButton(
                                                          //     onPressed: () {
                                                          //       _startTimer; // Start the timer if it's not already running
                                                          //       _showDialogBox(
                                                          //           context);
                                                          //       _printResult();
                                                          //       lastsaveData();
                                                          //       String tableno =
                                                          //           TableNoController
                                                          //               .text;
                                                          //       String
                                                          //           scodeValue =
                                                          //           SCodeController
                                                          //               .text;
                                                          //       String
                                                          //           snameValue =
                                                          //           SNameController
                                                          //               .text;
                                                          //       String
                                                          //           customerNameValue =
                                                          //           TableCusNameController
                                                          //               .text;
                                                          //       String
                                                          //           customerContactValue =
                                                          //           TableContactController
                                                          //               .text;
                                                          //       String
                                                          //           addressValue =
                                                          //           TableAddressController
                                                          //               .text;

                                                          //       List<
                                                          //               Map<String,
                                                          //                   dynamic>>
                                                          //           tabledata =
                                                          //           finalsalestableData;

                                                          //       if (scodeValue
                                                          //           .isNotEmpty) {
                                                          //         _saveText(
                                                          //             tableno,
                                                          //             scodeValue,
                                                          //             snameValue,
                                                          //             customerNameValue,
                                                          //             customerContactValue,
                                                          //             addressValue,
                                                          //             tabledata,
                                                          //             totalAmount);
                                                          //       }
                                                          //       // Navigator.pop(
                                                          //       //     context);
                                                          //     },
                                                          //     style:
                                                          //         ElevatedButton
                                                          //             .styleFrom(
                                                          //       shape:
                                                          //           RoundedRectangleBorder(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     2.0),
                                                          //       ),
                                                          //       backgroundColor:
                                                          //           subcolor,
                                                          //       minimumSize: Size(
                                                          //           45.0,
                                                          //           31.0), // Set width and height
                                                          //     ),
                                                          //     child: Text(
                                                          //         'Savebtn',
                                                          //         style:
                                                          //             commonWhiteStyle),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          Responsive.isDesktop(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.6
                                                              : 480,
                                                      height: 40,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                String tableno =
                                                                    TableNoController
                                                                        .text;
                                                                if (tableno
                                                                    .isEmpty) {
                                                                  print(
                                                                      "Table number is not provided.");
                                                                  return; // Exit early if no table number is provided
                                                                }

                                                                String key =
                                                                    'table_$tableno'; // Initialize `key` early

                                                                // Stop the timer if it's running for the current table
                                                                _stopTimer; // Ensure _stop is called as a function

                                                                // Clear the saved data for the start time and elapsed seconds from SharedPreferences
                                                                // await _clearPreferences(); // Call the method to remove specific keys

                                                                // Clear the saved data for the table from SharedPreferences
                                                                SharedPreferences
                                                                    prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                bool removed =
                                                                    await prefs
                                                                        .remove(
                                                                            key);
                                                                if (removed) {
                                                                  print(
                                                                      "Timer data for $key removed from SharedPreferences");
                                                                } else {
                                                                  print(
                                                                      "Failed to remove data for $key from SharedPreferences");
                                                                }

                                                                // Navigate to the next screen
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            NewSalesEntry(
                                                                      Fianlamount:
                                                                          TextEditingController(),
                                                                      salestableData:
                                                                          finalsalestableData,
                                                                      cusnameController:
                                                                          TableCusNameController,
                                                                      TableNoController:
                                                                          TableNoController, // Corrected to use TableNoController
                                                                      cusaddressController:
                                                                          TableAddressController,
                                                                      cuscontactController:
                                                                          TableContactController,
                                                                      scodeController:
                                                                          SCodeController,
                                                                      snameController:
                                                                          SNameController,
                                                                      TypeController:
                                                                          salestypecontroller,
                                                                      isSaleOn:
                                                                          false,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
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
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Move',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets
                                                          //           .only(
                                                          //           bottom: 10,
                                                          //           right: 13),
                                                          //   child:
                                                          //       ElevatedButton(
                                                          //     onPressed: () {
                                                          //       // Handle form submission
                                                          //     },
                                                          //     style:
                                                          //         ElevatedButton
                                                          //             .styleFrom(
                                                          //       shape:
                                                          //           RoundedRectangleBorder(
                                                          //         borderRadius:
                                                          //             BorderRadius
                                                          //                 .circular(
                                                          //                     2.0),
                                                          //       ),
                                                          //       backgroundColor:
                                                          //           subcolor,
                                                          //       minimumSize: Size(
                                                          //           45.0,
                                                          //           31.0), // Set width and height
                                                          //     ),
                                                          //     child: Text(
                                                          //         'Print',
                                                          //         style:
                                                          //             commonWhiteStyle),
                                                          //   ),
                                                          // ),

                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    right: 13),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                Closetabledetails();
                                                                if (showTableNo) {
                                                                  setState(() {
                                                                    showTableNo =
                                                                        false; // Close the details view
                                                                  });
                                                                }
                                                                // print(
                                                                //     "c;ose button is pressed");
                                                              },
                                                              style:
                                                                  ElevatedButton
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
                                                                    45.0,
                                                                    31.0), // Set width and height
                                                              ),
                                                              child: Text(
                                                                  'Close',
                                                                  style:
                                                                      commonWhiteStyle),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                            ],
                                          )
                                        //mob design
                                        : Column(
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 480,
                                                        // color: Colors.pink,
                                                        child: Column(
                                                          children: [
                                                            tablesalesview(),
                                                            Container(
                                                              width: 480,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            13,
                                                                        bottom:
                                                                            15,
                                                                        top:
                                                                            15),
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        _startTimer(); // Start the timer first

                                                                        // Wait for the dialog to close and capture the result
                                                                        bool
                                                                            dialogResult =
                                                                            await _showDialogBox(context);

                                                                        // If the user pressed "Yes", proceed with other actions
                                                                        if (dialogResult ==
                                                                            true) {
                                                                          _printResult(); // Execute print result
                                                                          lastsaveData(); // Execute save data

                                                                          String
                                                                              tableno =
                                                                              TableNoController.text;
                                                                          String
                                                                              scodeValue =
                                                                              SCodeController.text;
                                                                          String
                                                                              snameValue =
                                                                              SNameController.text;
                                                                          String
                                                                              customerNameValue =
                                                                              TableCusNameController.text;
                                                                          String
                                                                              customerContactValue =
                                                                              TableContactController.text;
                                                                          String
                                                                              addressValue =
                                                                              TableAddressController.text;

                                                                          List<Map<String, dynamic>>
                                                                              tabledata =
                                                                              finalsalestableData;

                                                                          if (scodeValue
                                                                              .isNotEmpty) {
                                                                            _saveText(
                                                                              tableno,
                                                                              scodeValue,
                                                                              snameValue,
                                                                              customerNameValue,
                                                                              customerContactValue,
                                                                              addressValue,
                                                                              tabledata,
                                                                              totalAmount,
                                                                            );
                                                                          }
                                                                        } else {
                                                                          lastsaveData();
                                                                          // Handle the case where the user pressed "No" if needed
                                                                        }
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2.0),
                                                                        ),
                                                                        backgroundColor:
                                                                            subcolor,
                                                                        minimumSize: Size(
                                                                            45.0,
                                                                            31.0), // Set width and height
                                                                      ),
                                                                      child: Text(
                                                                          'Save',
                                                                          style:
                                                                              commonWhiteStyle),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    Container(
                                                        width: 480,
                                                        // color: Colors.yellow,
                                                        child: Column(
                                                          children: [
                                                            tablesalesviewtableNo(),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              width: 480,
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                7,
                                                                            bottom:
                                                                                15,
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            String
                                                                                tableno =
                                                                                TableNoController.text;
                                                                            if (tableno.isEmpty) {
                                                                              print("Table number is not provided.");
                                                                              return; // Exit early if no table number is provided
                                                                            }

                                                                            String
                                                                                key =
                                                                                'table_$tableno'; // Initialize `key` early

                                                                            // Stop the timer if it's running for the current table
                                                                            _stopTimer; // Stop the timer and save the stop time

                                                                            // Clear the saved data for the table from SharedPreferences
                                                                            SharedPreferences
                                                                                prefs =
                                                                                await SharedPreferences.getInstance();
                                                                            bool
                                                                                removed =
                                                                                await prefs.remove(key);
                                                                            if (removed) {
                                                                              print("Timer data for $key removed from SharedPreferences");
                                                                            } else {
                                                                              print("Failed to remove data for $key from SharedPreferences");
                                                                            }

                                                                            // Navigate to the next screen
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => NewSalesEntry(
                                                                                  Fianlamount: TextEditingController(),
                                                                                  salestableData: finalsalestableData,
                                                                                  cusnameController: TableCusNameController,
                                                                                  TableNoController: TableContactController,
                                                                                  cusaddressController: TableAddressController,
                                                                                  cuscontactController: TableContactController,
                                                                                  scodeController: SCodeController,
                                                                                  snameController: SNameController,
                                                                                  TypeController: salestypecontroller,
                                                                                  isSaleOn: false,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                subcolor,
                                                                            minimumSize:
                                                                                Size(45.0, 31.0), // Set width and height
                                                                          ),
                                                                          child: Text(
                                                                              'Move',
                                                                              style: commonWhiteStyle),
                                                                        ),
                                                                        //      ElevatedButton(
                                                                        //       onPressed:
                                                                        //           () async {
                                                                        //         // Stop the timer if it's running

                                                                        //         // Clear the saved data for the table from SharedPreferences
                                                                        //         String tableno = TableNoController.text;
                                                                        //         String key = 'table_$tableno';
                                                                        //         if (tableno.isEmpty) {
                                                                        //           print("Table number is not provided.");
                                                                        //           return; // Exit early if no table number is provided
                                                                        //         }

                                                                        //         if (_isRunning) {
                                                                        //           await _stopTimer(key); // Stop the timer and save the stop time
                                                                        //         }

                                                                        //         SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                        //         await prefs.remove(key);

                                                                        //         print("Timer data for $key removed after moving");

                                                                        //         // Navigate to the next screen
                                                                        //         Navigator.push(
                                                                        //           context,
                                                                        //           MaterialPageRoute(
                                                                        //             builder: (context) => NewSalesEntry(
                                                                        //               Fianlamount: TextEditingController(),
                                                                        //               salestableData: finalsalestableData,
                                                                        //               cusnameController: TableCusNameController,
                                                                        //               TableNoController: TableContactController,
                                                                        //               cusaddressController: TableAddressController,
                                                                        //               cuscontactController: TableContactController,
                                                                        //               scodeController: SCodeController,
                                                                        //               snameController: SNameController,
                                                                        //               TypeController: salestypecontroller,
                                                                        //               isSaleOn: false,
                                                                        //             ),
                                                                        //           ),
                                                                        //         );
                                                                        //       },
                                                                        //       style:
                                                                        //           ElevatedButton.styleFrom(
                                                                        //         shape: RoundedRectangleBorder(
                                                                        //           borderRadius: BorderRadius.circular(2.0),
                                                                        //         ),
                                                                        //         backgroundColor: subcolor,
                                                                        //         minimumSize: Size(45.0, 31.0), // Set width and height
                                                                        //       ),
                                                                        //       child:
                                                                        //           Text('Move', style: commonWhiteStyle),
                                                                        //     )),
                                                                      ),
                                                                      // Padding(
                                                                      //   padding: const EdgeInsets
                                                                      //       .only(
                                                                      //       right:
                                                                      //           7,
                                                                      //       bottom:
                                                                      //           15,
                                                                      //       top:
                                                                      //           5),
                                                                      //   child:
                                                                      //       ElevatedButton(
                                                                      //     onPressed:
                                                                      //         () {
                                                                      //       // Handle form submission
                                                                      //     },
                                                                      //     style:
                                                                      //         ElevatedButton.styleFrom(
                                                                      //       shape:
                                                                      //           RoundedRectangleBorder(
                                                                      //         borderRadius: BorderRadius.circular(2.0),
                                                                      //       ),
                                                                      //       backgroundColor:
                                                                      //           subcolor,
                                                                      //       minimumSize:
                                                                      //           Size(45.0, 31.0), // Set width and height
                                                                      //     ),
                                                                      //     child: Text(
                                                                      //         'Print',
                                                                      //         style: commonWhiteStyle),
                                                                      //   ),
                                                                      // ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                7,
                                                                            bottom:
                                                                                15,
                                                                            top:
                                                                                5),
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Closetabledetails();
                                                                            if (showTableNo) {
                                                                              setState(() {
                                                                                showTableNo = false; // Close the details view
                                                                              });
                                                                            }
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                            ),
                                                                            backgroundColor:
                                                                                subcolor,
                                                                            minimumSize:
                                                                                Size(45.0, 31.0), // Set width and height
                                                                          ),
                                                                          child: Text(
                                                                              'Close',
                                                                              style: commonWhiteStyle),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ))
                                                  ]),
                                            ],
                                          )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Wrap tablesalesproductdetails(BuildContext context,
      double desktopcontainerdwidth, double desktoptextfeildwidth) {
    return Wrap(alignment: WrapAlignment.start, children: [
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Code", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        onChanged: (newvalue) {
                          fetchproductName();
                        },
                        controller: TableCodeController,
                        focusNode: codeFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, codeFocusNode, itemFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 7.0,
                          ),
                        ),
                        style: textStyle)),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Item", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 3 : 0, top: 8),
              child: Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.11
                      : MediaQuery.of(context).size.width * 0.3,
                  child: _buildProductnameDropdown()),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Amount", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined, // Your icon here
                      size: 17,
                    ),
                    SizedBox(width: 3), // Adjust spacing between icon and text

                    Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.08
                            : MediaQuery.of(context).size.width * 0.255,
                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextField(
                            readOnly: true,
                            controller: TableAmountController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Quantity", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_alert_rounded, // Your icon here
                      size: 17,
                    ),
                    SizedBox(width: 1), // Adjust spacing between icon and text

                    Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width * 0.08
                            : MediaQuery.of(context).size.width * 0.255,
                        color: Colors.grey[100],
                        // color: Colors.grey[100],
                        child: TextFormField(
                            controller: TableQuantityController,
                            focusNode: quantityFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              String productName = TableItemController.text;
                              int quantity = int.tryParse(value) ?? 0;

                              // Check if the product's stock is available
                              salesProductList().then(
                                  (List<Map<String, dynamic>> productList) {
                                // Find the product in the list
                                Map<String, dynamic>? product =
                                    productList.firstWhere(
                                  (element) => element['name'] == productName,
                                  orElse: () => {
                                    'stock': 'no'
                                  }, // Default values if product not found
                                );

                                String stockStatus = product['stock'];
                                // print(
                                //     "stock values for the $productName is $stockStatus");

                                if (stockStatus == 'No') {
                                  // Product's stock is not available, proceed with relevant action
                                  // For example, move focus to the next field
                                  // FocusScope.of(context)
                                  //     .requestFocus(
                                  //         finaltotFocusNode);
                                } else if (stockStatus == 'Yes') {
                                  // Product's stock is available, proceed with quantity validation
                                  double stockValue = double.tryParse(
                                          product['stockvalue'].toString()) ??
                                      0;

                                  if (quantity > stockValue) {
                                    // Quantity exceeds stock value, show error message and clear quantity controller
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // Prevent closing when tapping outside or pressing back button

                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Stock Check'),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                // Close the dialog without any action
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                        content: Container(
                                          width: 500,
                                          child: Text(
                                              'The entered quantity exceeds the available stock value (${stockValue}). '
                                              'Do you want to proceed by deducting this excess quantity from the stock?'),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  // FocusScope.of(
                                                  //         context)
                                                  //     .requestFocus(
                                                  //         itemFocusNode);
                                                },
                                                child: Text('Yes Add'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  TableQuantityController.text =
                                                      stockValue
                                                          .toString(); // Set quantity to stock value

                                                  Navigator.of(context).pop();
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          finaltotFocusNode);
                                                },
                                                child: Text('Skip'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // Quantity is valid, move focus to the next field
                                    _fieldFocusChange(context,
                                        quantityFocusNode, finaltotFocusNode);
                                  }
                                }
                              });
                            },

                            // onFieldSubmitted: (_) {
                            //   // Move focus to the save button
                            //   FocusScope.of(context)
                            //       .requestFocus(
                            //           addbuttonFocusNode);
                            // },
                            onChanged: (value) {
                              updateTotal();
                              updatetaxableamount();
                              updateCGSTAmount();
                              updateSGSTAmount();
                              updateFinalAmount();
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        // color:subcolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0, top: 8),
              child: Text("Total", style: commonLabelTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 5 : 0, top: 8),
              child: Container(
                height: 24,
                width: Responsive.isDesktop(context)
                    ? desktopcontainerdwidth
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktoptextfeildwidth
                      : MediaQuery.of(context).size.width * 0.2,
                  color: Colors.grey[200],
                  child: TextFormField(
                      readOnly: true,
                      controller: FinalAmtController,
                      focusNode: finaltotFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        // Move focus to the save button
                        FocusScope.of(context).requestFocus(addbuttonFocusNode);
                      },
                      onChanged: (newValue) {},
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
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
    ]);
  }

  Wrap tablesalesserventdetails(BuildContext context,
      double desktopcontainerdwidth, double desktoptextfeildwidth) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        SizedBox(width: 10),
        //scode
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("S.Code: ", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  // color: Colors.red,
                  child: Row(
                    children: [
                      Container(
                        height: 24,
                        width: Responsive.isDesktop(context)
                            ? desktoptextfeildwidth
                            : MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey[100],
                        child: TextFormField(
                            focusNode: scodeFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _fieldFocusChange(
                                context, scodeFocusNode, snameFocusNode),
                            onChanged: (newvalue) {
                              fetchSName();
                            },
                            controller: SCodeController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 7.0,
                              ),
                            ),
                            style: textStyle),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  child: Container(
                                    width: 1350,
                                    height: 800,
                                    padding: EdgeInsets.all(16),
                                    child: Stack(
                                      children: [
                                        StaffDetailsPage(),
                                        Positioned(
                                          right: 0.0,
                                          top: 0.0,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel,
                                                color: Colors.red, size: 23),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              fetchproductName();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(color: subcolor),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 6, right: 6, top: 2, bottom: 2),
                              child: Text(
                                "+",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        //sname
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("S Name", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        onChanged: (newvalue) {
                          fetchcode();
                        },
                        controller: SNameController,
                        focusNode: snameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, snameFocusNode, CusnameFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
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
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Customer Name", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[200],
                    child: TextFormField(
                        controller: TableCusNameController,
                        focusNode: CusnameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusnameFocusNode, CusContactFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
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
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Contact", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        controller: TableContactController,
                        focusNode: CusContactFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                              10), // Optional: Limit input length to 10
                        ],
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusContactFocusNode, CusAddressFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
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
        SizedBox(width: 10),
        Container(
          // color:subcolor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 8),
                child: Text("Address", style: commonLabelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 8),
                child: Container(
                  height: 24,
                  width: Responsive.isDesktop(context)
                      ? desktopcontainerdwidth
                      : MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 24,
                    width: Responsive.isDesktop(context)
                        ? desktoptextfeildwidth
                        : MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey[100],
                    child: TextFormField(
                        controller: TableAddressController,
                        focusNode: CusAddressFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, CusAddressFocusNode, codeFocusNode),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
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
    );
  }

  Map<String, DateTime> _tableStartTimes = {};

//   ///this code made stop time but not running always then double time running
// //orginial ocode
//   void _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? startTimeString = prefs.getString('start_time');
//     int? elapsedSeconds = prefs.getInt('elapsed_seconds');

//     if (startTimeString != null && elapsedSeconds != null) {
//       _startTime = DateTime.parse(startTimeString);
//       _elapsedSeconds = elapsedSeconds;
//       _isRunning = true;
//       _startTimer();
//     }
//   }

//   void _startTimer() {
//     if (_isRunning) {
//       _timer?.cancel(); // Cancel any existing timer before starting a new one
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedSeconds++;
//           _savePreferences();
//         });
//       });
//     }
//   }

//   Future<void> _stopTimer() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       setState(() {
//         _isRunning = false;
//       });

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String key = 'table_$selectedCode';
//       String? jsonData = prefs.getString(key);

//       if (jsonData != null) {
//         Map<String, dynamic> data = jsonDecode(jsonData);
//         data['stopTime'] = DateTime.now().toIso8601String();
//         data['elapsedSeconds'] = _elapsedSeconds;

//         print("Final timer details before removal: ${jsonEncode(data)}");

//         await prefs.remove(key); // Remove data from SharedPreferences
//         print("Removed timer data for $key from SharedPreferences");
//       } else {
//         print("No timer data found for $key to remove");
//       }
//     }
//   }

//   void _start() async {
//     _startTime = DateTime.now();
//     _isRunning = true;
//     _elapsedSeconds = 0;
//     String tableno = TableNoController.text;
//     String scodeValue = SCodeController.text;
//     String snameValue = SNameController.text;
//     String customerNameValue = TableCusNameController.text;
//     String customerContactValue = TableContactController.text;
//     String addressValue = TableAddressController.text;

//     List<Map<String, dynamic>> tabledata = finalsalestableData;

//     if (scodeValue.isNotEmpty) {
//       _saveText(tableno, scodeValue, snameValue, customerNameValue,
//           customerContactValue, addressValue, tabledata, totalAmount);
//     }
//     _startTimer();
//   }

//   void _stop() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       _isRunning = false;
//       _startTime = null;
//       await _stopTimer(); // Stop the timer and remove data
//       setState(() {});
//     }
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
//     await prefs.setInt('elapsed_seconds', _elapsedSeconds);
//   }

//   Future<void> _clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('start_time');
//     await prefs.remove('elapsed_seconds');
//   }

//   String _formatDuration(int seconds) {
//     Duration duration = Duration(seconds: seconds);
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//   }

// //trial
//   void _startTimer() {
//     if (!_isRunning) {
//       _startTime = DateTime.now();
//       _elapsedSeconds = 0; // Reset elapsed seconds to 0
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
//           _savePreferences();
//           print('Timer tick: ${DateTime.now()}');
//           _updateElapsedTimes();
//         });
//       });
//       _isRunning = true;
//       _savePreferences(); // Save the state when the timer starts
//     }
//   }

//   Future<void> _stopTimer() async {
//     if (_isRunning) {
//       _timer?.cancel();
//       setState(() {
//         _isRunning = false;
//       });
//       await _savePreferences(); // Save the final state
//     }
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
//     await prefs.setInt('elapsed_seconds', _elapsedSeconds);
//     await prefs.setBool('is_running', _isRunning);
//   }

//   Future<void> _clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('start_time');
//     await prefs.remove('elapsed_seconds');
//     await prefs.remove('is_running');
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? startTimeString = prefs.getString('start_time');
//     int? elapsedSeconds = prefs.getInt('elapsed_seconds');
//     bool? isRunning = prefs.getBool('is_running');

//     if (startTimeString != null && isRunning != null) {
//       _startTime = DateTime.parse(startTimeString);
//       _elapsedSeconds = elapsedSeconds ?? 0;
//       _isRunning = isRunning;

//       if (_isRunning) {
//         // Calculate the elapsed time based on the start time and current time
//         _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//           setState(() {
//             _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
//             _savePreferences();
//           });
//         });
//       }
//     } else {
//       // Initialize with default values if no data found
//       _startTime = null;
//       _elapsedSeconds = 0;
//       _isRunning = false;
//     }
//   }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Map<String, bool> _hoveredTableCodes = {}; // Map to track hover state
  // void _updateElapsedTimes() {
  //   setState(() {
  //     _elapsedTimes.updateAll((key, elapsedTime) {
  //       final newTime = elapsedTime + 1;
  //       print('Updated time for $key: $newTime seconds');
  //       return newTime;
  //     });
  //   });
  // }

  Map<String, DateTime> _startTimes = {}; // Store start time for each table
  // Future<void> _reserveTable(String tableCode) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentTime = DateTime.now();

  //   setState(() {
  //     _startTimes[tableCode] = currentTime;
  //   });

  //   // Save the start time as a string in SharedPreferences
  //   await prefs.setString(tableCode, currentTime.toIso8601String());
  // }

  // Future<void> _loadStartTimes() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.getKeys().forEach((tableCode) {
  //     String? storedTime = prefs.getString(tableCode);
  //     if (storedTime != null) {
  //       setState(() {
  //         _startTimes[tableCode] = DateTime.parse(storedTime);
  //       });
  //     }
  //   });
  // }

  // String _getElapsedTime(String tableCode) {
  //   if (!_startTimes.containsKey(tableCode)) {
  //     return "00:00:00"; // Return zero time if not reserved
  //   }

  //   final startTime = _startTimes[tableCode]!;
  //   final elapsed = DateTime.now().difference(startTime);

  //   return _formatDuration(elapsed);
  // }

  // Future<void> _reserveTable(String tableCode) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final currentTime = DateTime.now();

  //   setState(() {
  //     _startTimes[tableCode] = currentTime;
  //   });

  //   // Save the start time as a string in SharedPreferences
  //   await prefs.setString(tableCode, currentTime.toIso8601String());
  // }

  // Future<void> _loadStartTimes() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.getKeys().forEach((tableCode) {
  //     String? storedTime = prefs.getString(tableCode);
  //     if (storedTime != null) {
  //       setState(() {
  //         _startTimes[tableCode] = DateTime.parse(storedTime);
  //       });
  //     }
  //   });
  // }

  // String _getElapsedTime(String tableCode) {
  //   if (!_startTimes.containsKey(tableCode)) {
  //     return "00:00:00"; // Return zero time if the table is not reserved
  //   }

  //   final startTime = _startTimes[tableCode]!;
  //   final elapsed = DateTime.now().difference(startTime);

  //   return _formatDuration(elapsed);
  // }

  // String _formatDuration(Duration duration) {
  //   final hours = duration.inHours.toString().padLeft(2, '0');
  //   final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  //   final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  //   return '$hours:$minutes:$seconds';
  // }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var data in finalsalestableData) {
      if (data['Amount'] != null) {
        double Amount = double.tryParse(data['Amount'].toString()) ?? 0.0;
        // print('Amount: $Amount'); // Debug print
        totalAmount += Amount;
      }
    }
    // print('Total Amount: $totalAmount'); // Debug print
    return totalAmount;
  }

  void updateTotalAmount() {
    setState(() {
      double totalAmount = calculateTotalAmount();
      FinalAmtController.text = totalAmount.toStringAsFixed(2);
      print(
          'Updated FinalAmtController: ${FinalAmtController.text}'); // Debug print
    });
  }

  double _getTotalAmountFromPrefs(String tableCode) {
    String jsonData = prefs.getString('table_$tableCode') ?? '';
    if (jsonData.isNotEmpty) {
      var data = jsonDecode(jsonData);
      return data['totalAmount'] ?? 0.0; // Return totalAmount if available
    }
    return 0.0; // Return 0.0 if no data found
  }

//afternoon try
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  final Map<String, DateTime> _reservationStartTimes = {};
  String _formatElapsedTime(String tableCode) {
    if (_reservationStartTimes.containsKey(tableCode)) {
      Duration elapsed =
          DateTime.now().difference(_reservationStartTimes[tableCode]!);
      return _formatDuration(elapsed);
    }
    return '00:00:00';
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  Future<void> _stopTimer() async {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
      await _savePreferences(); // Save the final state
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
    await prefs.setInt('elapsed_seconds', _elapsedSeconds);
    await prefs.setBool('is_running', _isRunning);
  }

  Future<void> _loadPreferences() async {
    print("Loading preferences...");
    final prefs = await SharedPreferences.getInstance();
    String? startTimeString = prefs.getString('start_time');
    int? elapsedSeconds = prefs.getInt('elapsed_seconds');
    bool? isRunning = prefs.getBool('is_running');

    if (startTimeString != null && isRunning != null) {
      print(
          "Preferences loaded: start_time=$startTimeString, elapsed_seconds=$elapsedSeconds, is_running=$isRunning");
      _startTime = DateTime.parse(startTimeString);
      _elapsedSeconds = elapsedSeconds ?? 0;
      _isRunning = isRunning;

      if (_isRunning) {
        // Calculate the elapsed time based on the start time and current time
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
            _savePreferences(); // Save preferences every second
          });
        });
      }
    } else {
      // Initialize with default values if no data found
      print("No preferences found. Initializing with default values.");
      _startTime = null;
      _elapsedSeconds = 0;
      _isRunning = false;
    }
  }

  Widget buildTableButton(String name, List<String> codes, String tableCode) {
    List<Widget> buttonRows = [];
    List<Widget> currentRow = [];
    int buttonsPerRow = Responsive.isDesktop(context)
        ? 5
        : Responsive.isTablet(context)
            ? 5
            : 2;

    for (int i = 0; i < codes.length; i++) {
      String key = 'table_${codes[i]}';
      bool isReserved = prefs.containsKey(key);

      // Get total amount from SharedPreferences if available
      double totalAmount = 0.0;
      if (isReserved) {
        String? jsonData = prefs.getString(key);
        if (jsonData != null) {
          Map<String, dynamic> data = jsonDecode(jsonData);
          totalAmount = _getTotalAmountFromPrefs(codes[i]);

          // Set reservation start time if not already set
          if (!_reservationStartTimes.containsKey(codes[i])) {
            _reservationStartTimes[codes[i]] = DateTime.now()
                .subtract(Duration(seconds: data['elapsedSeconds'] ?? 0));
          }
        }
      }
      bool isHovered = _hoveredTableCodes[codes[i]] ?? false;
      String elapsedTime = isReserved ? _formatElapsedTime(codes[i]) : '';

      currentRow.add(MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredTableCodes[codes[i]] = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredTableCodes[codes[i]] = false;
          });
        },
        child: Transform.scale(
          scale: isHovered ? 1.1 : 1.0,
          child: Padding(
            padding: EdgeInsets.only(
                top: Responsive.isDesktop(context) ? 10 : 10,
                left: Responsive.isDesktop(context) ? 10 : 3,
                right: Responsive.isDesktop(context) ? 10 : 3,
                bottom: Responsive.isDesktop(context) ? 10 : 2),
            child: Container(
              decoration: BoxDecoration(
                color: isReserved
                    ? Color.fromARGB(255, 62, 67, 85)
                    : Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: isReserved
                          ? MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 62, 67, 85))
                          : MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 255, 255, 255)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(4),
                    ),
                    onPressed: () {
                      _loadSavedData();
                      setState(() {
                        selectedCode = codes[i];
                        showTableNo = true;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(
                          Responsive.isDesktop(context) ? 10 : 2),
                      child: isReserved
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/imgs/reservetable.png',
                                        height: 25,
                                        width: 25,
                                        color: Colors.white),
                                    SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text('Reserved',
                                          style: commonWhiteStyle),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Center(
                                  child: Text(
                                    codes[i],
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Center(
                                    child: Text(
                                      "Time: $elapsedTime",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'TotAmt: ',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            '\$${totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/imgs/table.png',
                                    height: 35,
                                    width: 35,
                                    color: Color.fromARGB(255, 62, 67, 85)),
                                SizedBox(height: 5),
                                Text(
                                  'Available Seat',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color.fromARGB(255, 62, 67, 85)),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  codes[i],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 62, 67, 85)),
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));

      if ((i + 1) % buttonsPerRow == 0 || i == codes.length - 1) {
        buttonRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentRow,
          ),
        );
        currentRow = [];
      }
    }

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (!showTableNo) ...buttonRows,
        SizedBox(height: 16),
      ],
    );
  }

// //original
//   Widget buildTableButton(String name, List<String> codes, String tableCode) {
//     List<Widget> buttonRows = [];
//     List<Widget> currentRow = [];
//     int buttonsPerRow = Responsive.isDesktop(context)
//         ? 5
//         : Responsive.isTablet(context)
//             ? 5
//             : 2;

//     for (int i = 0; i < codes.length; i++) {
//       String key = 'table_${codes[i]}';
//       bool isReserved = prefs.containsKey(key);

//       // Get elapsed time from SharedPreferences if available
//       String elapsedTime = '';
//       double totalAmount = 0.0;
//       if (isReserved) {
//         elapsedTime = _getElapsedTime(codes[i]);
//         totalAmount = _getTotalAmountFromPrefs(codes[i]); // Get total amount
//         // print('Elapsed time for ${codes[i]}: $elapsedTime');
//       }
//       bool isHovered = _hoveredTableCodes[codes[i]] ?? false;

//       currentRow.add(MouseRegion(
//         onEnter: (_) {
//           setState(() {
//             _hoveredTableCodes[codes[i]] = true;
//           });
//         },
//         onExit: (_) {
//           setState(() {
//             _hoveredTableCodes[codes[i]] = false;
//           });
//         },
//         child: Transform.scale(
//           scale: isHovered ? 1.1 : 1.0,
//           child: Padding(
//             padding: EdgeInsets.only(
//                 top: Responsive.isDesktop(context) ? 10 : 10,
//                 left: Responsive.isDesktop(context) ? 10 : 3,
//                 right: Responsive.isDesktop(context) ? 10 : 3,
//                 bottom: Responsive.isDesktop(context) ? 10 : 2),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: isReserved
//                     ? Color.fromARGB(255, 62, 67, 85)
//                     : Color.fromARGB(255, 255, 255, 255),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3), // changes position of shadow
//                   ),
//                 ],
//                 borderRadius:
//                     BorderRadius.circular(8), // Optional: adds rounded corners
//               ),
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: isReserved
//                           ? MaterialStateProperty.all<Color>(
//                               Color.fromARGB(255, 62, 67, 85))
//                           : MaterialStateProperty.all<Color>(
//                               Color.fromARGB(255, 255, 255, 255)),
//                       elevation: MaterialStateProperty.all<double>(4),
//                     ),
//                     onPressed: () {
//                       _loadSavedData();
//                       setState(() {
//                         selectedCode = codes[i];
//                         showTableNo = true;
//                       });
//                     },
//                     child: Padding(
//                       padding: EdgeInsets.all(
//                           Responsive.isDesktop(context) ? 10 : 2),
//                       child: isReserved
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Image.asset('assets/imgs/reservetable.png',
//                                         height: 25,
//                                         width: 25,
//                                         color: Colors.white),
//                                     SizedBox(width: 4),
//                                     Padding(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: Text('Reserved',
//                                           style: commonWhiteStyle),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 3),
//                                 Center(
//                                   child: Text(
//                                     codes[i],
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.white),
//                                   ),
//                                 ),
//                                 if (elapsedTime.isNotEmpty)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 4.0),
//                                     child: Center(
//                                         child: RichText(
//                                       text: TextSpan(
//                                         children: [
//                                           TextSpan(
//                                             text: 'Time: ', // Label for time
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors
//                                                     .white, // Style for the label
//                                                 fontWeight: FontWeight.bold
//                                                 // Bold for emphasis
//                                                 ),
//                                           ),
//                                           TextSpan(
//                                             text:
//                                                 elapsedTime, // Actual elapsed time
//                                             style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors
//                                                     .white, // Different color for the elapsed time
//                                                 fontWeight: FontWeight
//                                                     .bold // Italics for distinction
//                                                 ),
//                                           ),
//                                         ],
//                                       ),
//                                     )),
//                                   ),
//                                 SizedBox(height: 5),
//                                 RichText(
//                                   text: TextSpan(
//                                     children: [
//                                       TextSpan(
//                                         text: 'TotAmt: ', // Label for time
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors
//                                                 .white, // Style for the label
//                                             fontWeight: FontWeight.bold
//                                             // Bold for emphasis
//                                             ),
//                                       ),
//                                       TextSpan(
//                                         text:
//                                             '\$${totalAmount.toStringAsFixed(2)}',
//                                         style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors
//                                                 .white, // Different color for the elapsed time
//                                             fontWeight: FontWeight
//                                                 .bold // Italics for distinction
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             )
//                           : Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset('assets/imgs/table.png',
//                                     height: 35,
//                                     width: 35,
//                                     color: Color.fromARGB(255, 62, 67, 85)),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   'Available Seat',
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: Color.fromARGB(255, 62, 67, 85)),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   codes[i],
//                                   style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromARGB(255, 62, 67, 85)),
//                                 ),
//                                 SizedBox(height: 4),
//                               ],
//                             ),
//                     ),
//                     // child: Padding(
//                     //   padding: EdgeInsets.all(
//                     //       Responsive.isDesktop(context) ? 10 : 2),
//                     //   child: Container(
//                     //     child: Column(
//                     //       children: [
//                     //         Image.asset(
//                     //             isReserved
//                     //                 ? 'assets/imgs/reservetable.png'
//                     //                 : 'assets/imgs/table.png',
//                     //             height: 30,
//                     //             width: 30,
//                     //             color: isReserved
//                     //                 ? Colors.white
//                     //                 : Color.fromARGB(255, 62, 67, 85)),
//                     //         SizedBox(height: 0),
//                     //         Padding(
//                     //           padding: const EdgeInsets.all(4.0),
//                     //           child: Text(
//                     //             isReserved ? 'Reserved' : 'Available Seat',
//                     //             style: TextStyle(
//                     //                 fontSize: 10,
//                     //                 color: isReserved
//                     //                     ? Colors.white
//                     //                     : Color.fromARGB(255, 62, 67, 85)),
//                     //           ),
//                     //         ),
//                     //         Padding(
//                     //           padding: const EdgeInsets.all(4.0),
//                     //           child: Text(
//                     //             codes[i],
//                     //             style: TextStyle(
//                     //                 fontSize: 12,
//                     //                 fontWeight: FontWeight.bold,
//                     //                 color: isReserved
//                     //                     ? Colors.white
//                     //                     : Color.fromARGB(255, 62, 67, 85)),
//                     //           ),
//                     //         ),
//                     //         if (isReserved) // Show elapsed time if the table is reserved
//                     //           Padding(
//                     //             padding: const EdgeInsets.all(4.0),
//                     //             child: Text(
//                     //               'Time: $elapsedTime',
//                     //             ),
//                     //           ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ));

//       if ((i + 1) % buttonsPerRow == 0 || i == codes.length - 1) {
//         buttonRows.add(
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: currentRow,
//           ),
//         );
//         currentRow = [];
//       }
//     }

//     return Column(
//       children: [
//         Text(
//           name,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 16),
//         if (!showTableNo) ...buttonRows,
//         SizedBox(height: 16),
//       ],
//     );
//   }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> salestableData = [];

  List<Map<String, dynamic>> finalsalestableData = [];
  bool updateenable = false;
  void saveData() {
    // Check if any required field is empty
    if (SCodeController.text.isEmpty ||
        SNameController.text.isEmpty ||
        TableItemController.text.isEmpty ||
        TableAmountController.text.isEmpty ||
        TableQuantityController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (widget.SalesPaytype.text.toLowerCase() == 'credit' &&
        TableCusNameController.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details , when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (TableQuantityController.text == '0' ||
        TableQuantityController.text == '') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity Check'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text('Kindly enter the quantity , Quantity must above 0'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productName = TableItemController.text;
      String amount = TableAmountController.text;
      String makingcost = TableProdutMakingCostController.text;
      String category = TableProdutCategoryController.text;

      String quantity = TableQuantityController.text;
      // Extract required details from controllers
      String totalamt = FinalAmtController.text;

      String taxable = Taxableamountcontroller.text;
      // print("final amount :${FinalAmtController.text}");

      String cgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

      String cgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
      String sgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
      String sgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;
      bool productExists = false;

      for (var item in salestableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          salestableData.add({
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        productName = '';
        TableCodeController.clear();
        updateenable = false;
      });

      TableCodeController.clear();
      TableItemController.clear();
      ProductNameSelected = '';
      TableAmountController.clear();
      TableQuantityController.clear();
      FinalAmtController.clear();
    }
  }

  void UpdateData() {
    // Check if any required field is empty
    if (TableCodeController.text.isEmpty ||
        TableItemController.text.isEmpty ||
        TableAmountController.text.isEmpty ||
        TableQuantityController.text.isEmpty ||
        FinalAmtController.text.isEmpty ||
        UpdateidController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    } else if (widget.SalesPaytype.text.toLowerCase() == 'credit' &&
        TableCusNameController.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Details'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            width: 330,
            child: Text(
                'Kindly enter the Customer Details, when you select Paytype Credit'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).requestFocus(codeFocusNode);
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String productName = TableItemController.text;
      String amount = TableAmountController.text;
      String makingcost = TableProdutMakingCostController.text;
      String category = TableProdutCategoryController.text;

      String quantity = TableQuantityController.text;
      // Extract required details from controllers
      String totalamt = FinalAmtController.text;

      String taxable = Taxableamountcontroller.text;
      // print("final amount :${FinalAmtController.text}");

      String cgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

      String cgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
      String sgstPercentage =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
      String sgstAmount =
          SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;
      bool productExists = false;

      for (var item in salestableData) {
        if (item['productName'] == productName) {
          item['quantity'] =
              (int.parse(item['quantity']) + int.parse(quantity)).toString();

          item['Amount'] =
              (double.parse(item['Amount']) + double.parse(totalamt))
                  .toString();
          item['retail'] =
              (double.parse(item['retail']) + double.parse(taxable)).toString();
          item['cgstAmt'] =
              (double.parse(item['cgstAmt']) + double.parse(cgstAmount))
                  .toString();
          item['sgstAmt'] =
              (double.parse(item['sgstAmt']) + double.parse(sgstAmount))
                  .toString();
          productExists = true;
          break;
        }
      }

      if (!productExists) {
        setState(() {
          salestableData.add({
            'productName': productName,
            'amount': amount,
            'quantity': quantity,
            "cgstAmt": cgstAmount,
            "sgstAmt": sgstAmount,
            "Amount": totalamt,
            "retail": taxable,
            "retailrate": amount,
            "cgstperc": cgstPercentage,
            "sgstperc": sgstPercentage,
            "makingcost": makingcost,
            "category": category,
          });
        });
      }

      setState(() {
        productName = '';
        TableCodeController.clear();
        updateenable = false;
      });

      TableCodeController.clear();
      TableItemController.clear();
      ProductNameSelected = '';
      TableAmountController.clear();
      TableQuantityController.clear();
      FinalAmtController.clear();
    }
  }

  void lastsaveData() {
    // Check if any required field is empty
    if (selectedCode.isEmpty) {
      // Handle empty selectedCode
      return;
    }

    // Extract required details from controllers
    String totalamt = FinalAmtController.text;
    String taxable = Taxableamountcontroller.text;

    // print("final amount lasttable:${FinalAmtController.text}");
    // print("taxable  amount lasttable:${Taxableamountcontroller.text}");

    String cgstPercentage =
        SalesGstMethodController.text.isEmpty ? "0" : CGSTperccontroller.text;

    String cgstAmount =
        SalesGstMethodController.text.isEmpty ? "0" : CGSTAmtController.text;
    String sgstPercentage =
        SalesGstMethodController.text.isEmpty ? "0" : SGSTPercController.text;
    String sgstAmount =
        SalesGstMethodController.text.isEmpty ? "0" : SGSTAmtController.text;

    setState(() {
      // Iterate through salestableData and save only the required fields with the provided table number
      for (var data in salestableData) {
        finalsalestableData.add({
          'TableNo': selectedCode,
          'productName': data[
              'productName'], // Assuming 'productName' is a key in salestableData
          'amount':
              data['amount'], // Assuming 'amount' is a key in salestableData
          'quantity': data[
              'quantity'], // Assuming 'quantity' is a key in salestableData
          "cgstAmt": cgstAmount,
          "sgstAmt": sgstAmount,
          "Amount": data['Amount'],
          "retail": taxable,
          "retailrate": data['amount'],
          'cgstperc': cgstPercentage,
          'sgstperc': sgstPercentage,
          'makingcost': data['makingcost'],
          'category': data['category'],
        });
      }
    });

    // Clear salestableData after saving required data
    salestableData.clear();
  }

  Future<void> _printResult() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);
      String tableno = TableNoController.text;
      String serventName = SNameController.text;
      String date = formattedDate;
      String time = formattedDateTime;

      List<String> productDetails = [];
      for (var data in salestableData) {
        productDetails.add("${data['productName']}-${data['quantity']}");
      }
      getKitchenPrinterProducts();
      String productDetailsString = productDetails.join(",");
      // print("product details : $productDetailsString");
      print(
          "$IpAddress/KitchenSalesPrint3Inch/$tableno-$serventName-$date-$time/$productDetailsString");
      final response = await http.get(Uri.parse(
          '$IpAddress/KitchenSalesPrint3Inch/$tableno-$serventName-$date-$time/$productDetailsString'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, print the response body.
        // print('Response: ${response.body}');
      } else {
        // If the server did not return a 200 OK response, print the status code.
        // print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any potential errors.
      print('Error: $e');
    }
  }

  Future<List<String>> getKitchenPrinterProducts() async {
    String? cusid = await SharedPrefs.getCusId();
    final categoryUrl = '$IpAddress/Settings_ProductCategory/$cusid/';
    List<String> kitchenPrinterProducts = [];
    String? nextUrl = categoryUrl;

    // Fetch categories from all pages
    while (nextUrl != null) {
      try {
        final response = await http.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final decodedData = json.decode(response.body);
          final List<dynamic> categories = decodedData['results'];

          // Collect product names where type is "KitchenPrinter"
          for (var category in categories) {
            if (category['type'] == 'KitchenPrinter') {
              kitchenPrinterProducts.add(category['cat']);
            }
          }

          nextUrl = decodedData['next'];
        } else {
          throw Exception(
              'Failed to load category data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
        throw Exception('Failed to load category data');
      }
    }

    // Print the list of KitchenPrinter products
    // print('Kitchen printer category: $kitchenPrinterProducts');

    return kitchenPrinterProducts;
  }

  void addButtonPressed() {
    saveData(); // Call the saveData function to add data
    if (!_isRunning) {
      _startTimer; // Start the timer if it's not already running
    }
    setState(() {
      // Trigger a rebuild to reflect the changes in tablesalesview
      tablesalesview();
    });
  }

  void _deleteRow(int index) {
    setState(() {
      salestableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  void _deleteRowinitemtable(int index) {
    setState(() {
      finalsalestableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

  cleardata() {
    SCodeController.clear();
    SNameController.clear();
    TableCusNameController.clear();
    TableContactController.clear();
    TableAddressController.clear();

    TableCodeController.clear();
    TableItemController.clear();
    ProductNameSelected = '';
    TableAmountController.clear();
    TableQuantityController.clear();
    FinalAmtController.clear();
    finalsalestableData = [];
    salestableData = [];
    String tableno = TableNoController.text;

    deleteTableData(tableno);

    setState(() {
      TableCodeController.clear();
    });
  }

  Closetabledetails() {
    SCodeController.clear();
    SNameController.clear();
    TableCusNameController.clear();
    TableContactController.clear();
    TableAddressController.clear();

    TableCodeController.clear();
    TableItemController.clear();
    ProductNameSelected = '';
    TableAmountController.clear();
    TableQuantityController.clear();
    FinalAmtController.clear();
    finalsalestableData = [];
    salestableData = [];

    setState(() {
      TableCodeController.clear();
    });
  }

  Widget tablesalesview() {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalAmount = calculateTotalAmount(); // Calculate total amount

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 0,
          right: 0,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
            // height: Responsive.isDesktop(context) ? 260 : 240,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.7,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fastfood,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 1),
                                  Text("Item",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_exchange_outlined,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Amount",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 300.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_box,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Qty",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 5),
                                  Text("Action",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (salestableData.isNotEmpty)
                    ...salestableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;
                      var productName = data['productName'].toString();
                      var amount = data['amount'].toString();
                      var quantity = data['quantity'].toString();
                      var cgstAmt = data['cgstAmt'].toString();
                      var sgstAmt = data['sgstAmt'].toString();
                      var Amount = data['Amount'].toString();
                      var retail = data['retail'].toString();
                      var retailrate = data['retailrate'] ?? 0;

                      var cgstperc = data['cgstperc'].toString();
                      var sgstperc = data['sgstperc'] ?? 0;
                      var makingcost = data['makingcost'] ?? 0;
                      var category = data['category'] ?? 0;
                      // print("categoryyyyyyyyyyyyyyy: $category");
                      // print("tablenoooooooooooooo : $TableNo");
                      // print("111productNameaaaaaaaaaaaaaa : $productName");
                      // print("1111111naaaaaaaaaaaaaaaa : $amount");
                      // print("11111111111cgstAmtyyyyyyyyyyyyy : $cgstAmt");
                      // print("111111111111sgstAmtttttttttttttttt : $sgstAmt");
                      // print("111111111Amounttttttttttttttt : $Amount");
                      // print("111111111retailllllllllllllllll : $retail");
                      // print("1111111retailrateaaaaaaaaaaaa : $retailrate");
                      // print("11111111111111cgstperccccccccccccc : $cgstperc");
                      // print("111111111sgstpercscccccccccc : $sgstperc");

                      bool isEvenRow = salestableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Tooltip(
                                  message: productName,
                                  child: Center(
                                    child: Text(productName,
                                        textAlign: TextAlign.center,
                                        style: TableRowTextStyle),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(quantity,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 255.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: Container(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  index);
                                            },
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  // Text(
                  //   "Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //     color: Colors.black,
                  //   ),
                  // ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController UpdateidController = TextEditingController();
  Widget tablesalesviewtableNo() {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalAmount = 0; // Variable to keep track of the total amount

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.7,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Containers
                        _buildTableHeader("T.No", Icons.note_alt_rounded),
                        _buildTableHeader("Item", Icons.add_box),
                        _buildTableHeader(
                            "Amt", Icons.currency_exchange_outlined),
                        _buildTableHeader("Qty", Icons.add_box),
                        _buildTableHeader("Action", Icons.delete),
                      ],
                    ),
                  ),
                  if (finalsalestableData.isNotEmpty)
                    ...finalsalestableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;
                      var Amount =
                          double.tryParse(data['Amount'].toString()) ?? 0;

                      // Accumulate the total amount
                      totalAmount += Amount;

                      bool isEvenRow =
                          finalsalestableData.indexOf(data) % 2 == 0;
                      Color? rowColor = isEvenRow
                          ? Color.fromARGB(224, 255, 255, 255)
                          : Color.fromARGB(255, 223, 225, 226);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTableCell(
                                data['TableNo'].toString(), rowColor),
                            _buildTableCell(
                                data['productName'].toString(), rowColor),
                            _buildTableCell(
                                data['amount'].toString(), rowColor),
                            _buildTableCell(
                                data['quantity'].toString(), rowColor),
                            _buildActionButtons(index, data, rowColor),
                          ],
                        ),
                      );
                    }).toList(),
                  SizedBox(height: 10), // Spacer
                  // Text(
                  //   'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, IconData icon) {
    return Flexible(
      child: Container(
        height: Responsive.isDesktop(context) ? 25 : 30,
        width: 265.0,
        decoration: TableHeaderColor,
        child: Center(
          child: Row(
            children: [
              Icon(icon, size: 15, color: Colors.blue),
              SizedBox(width: 5),
              Text(text,
                  textAlign: TextAlign.center, style: commonLabelTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, Color? color) {
    return Flexible(
      child: Container(
        height: 30,
        width: 265.0,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Center(
          child:
              Text(text, textAlign: TextAlign.center, style: TableRowTextStyle),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      int index, Map<String, dynamic> data, Color? color) {
    return Flexible(
      child: Container(
        height: 30,
        width: 255.0,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Color.fromARGB(255, 226, 225, 225)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue, size: 15),
                onPressed: () {
                  TableNoController.text = data['TableNo'].toString();
                  TableItemController.text = data['productName'].toString();
                  TableAmountController.text = data['amount'].toString();
                  TableQuantityController.text = data['quantity'].toString();
                  FinalAmtController.text = data['Amount'].toString();
                  UpdateidController.text = data['id'].toString();
                  setState(() {
                    updateenable = true;
                    FocusScope.of(context).requestFocus(quantityFocusNode);
                  });
                },
              ),
              SizedBox(width: 1),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 15),
                onPressed: () {
                  _showFinalsalestableDeleteConfirmationDialog(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
//original
  // Widget tablesalesviewtableNo() {
  //   double screenHeight = MediaQuery.of(context).size.height;
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Padding(
  //       padding: const EdgeInsets.only(
  //         left: 0,
  //         right: 0,
  //       ),
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         child: Container(
  //           height: Responsive.isDesktop(context) ? screenHeight * 0.39 : 320,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[50],
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.5),
  //                 spreadRadius: 2,
  //                 blurRadius: 5,
  //                 offset: Offset(0, 3),
  //               ),
  //             ],
  //           ),
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Container(
  //               width: Responsive.isDesktop(context)
  //                   ? MediaQuery.of(context).size.width * 0.3
  //                   : MediaQuery.of(context).size.width * 0.7,
  //               child: Column(children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: Responsive.isDesktop(context) ? 265 : 300,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.note_alt_rounded,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("T.No",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.add_box,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Item",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.currency_exchange_outlined,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Amt",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.add_box,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Qty",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Flexible(
  //                         child: Container(
  //                           height: Responsive.isDesktop(context) ? 25 : 30,
  //                           width: 265.0,
  //                           decoration: TableHeaderColor,
  //                           child: Center(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.delete,
  //                                   size: 15,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 SizedBox(width: 5),
  //                                 Text("Action",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (finalsalestableData.isNotEmpty)
  //                   ...finalsalestableData.asMap().entries.map((entry) {
  //                     int index = entry.key;
  //                     Map<String, dynamic> data = entry.value;
  //                     var TableNo = data['TableNo'].toString();

  //                     var productName = data['productName'].toString();
  //                     var amount = data['amount'].toString();
  //                     var quantity = data['quantity'].toString();
  //                     var cgstAmt = data['cgstAmt'].toString();
  //                     var sgstAmt = data['sgstAmt'].toString();
  //                     var Amount = data['Amount'].toString();
  //                     var retail = data['retail'].toString();
  //                     var retailrate = data['retailrate'] ?? 0;

  //                     var cgstperc = data['cgstperc'].toString();
  //                     var sgstperc = data['sgstperc'] ?? 0;
  //                     var makingcost = data['makingcost'] ?? 0;
  //                     var category = data['category'] ?? 0;
  //                     // print("categoryyy11111111: $category");
  //                     // print("tablenoooooooooooooo : $TableNo");
  //                     // print("productNameaaaaaaaaaaaaaa : $productName");
  //                     // print("naaaaaaaaaaaaaaaa : $amount");
  //                     // print("cgstAmtyyyyyyyyyyyyy : $cgstAmt");
  //                     // print("sgstAmtttttttttttttttt : $sgstAmt");
  //                     // print("Amounttttttttttttttt : $Amount");
  //                     // print("retailllllllllllllllll : $retail");
  //                     // print("retailrateaaaaaaaaaaaa : $retailrate");
  //                     // print("cgstperccccccccccccc : $cgstperc");
  //                     // print("sgstpercscccccccccc : $sgstperc");
  //                     bool isEvenRow =
  //                         finalsalestableData.indexOf(data) % 2 == 0;
  //                     Color? rowColor = isEvenRow
  //                         ? Color.fromARGB(224, 255, 255, 255)
  //                         : Color.fromARGB(255, 223, 225, 226);

  //                     return Padding(
  //                       padding: const EdgeInsets.only(left: 0.0, right: 0),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(TableNo,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(productName,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(amount,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: Container(
  //                               height: 30,
  //                               width: 265.0,
  //                               decoration: BoxDecoration(
  //                                 color: rowColor,
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 226, 225, 225),
  //                                 ),
  //                               ),
  //                               child: Center(
  //                                 child: Text(quantity,
  //                                     textAlign: TextAlign.center,
  //                                     style: TableRowTextStyle),
  //                               ),
  //                             ),
  //                           ),
  //                           Flexible(
  //                               child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(bottom: 10.0),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   IconButton(
  //                                     icon: Icon(
  //                                       Icons.edit,
  //                                       color: Colors.blue,
  //                                       size: 15,
  //                                     ),
  //                                     onPressed: () {
  //                                       // _showEditDialog(index);
  //                                       TableNoController.text =
  //                                           data['TableNo'].toString();
  //                                       TableItemController.text =
  //                                           data['productName'].toString();
  //                                       TableAmountController.text =
  //                                           data['amount'].toString();
  //                                       TableQuantityController.text =
  //                                           data['quantity'].toString();
  //                                       FinalAmtController.text =
  //                                           data['Amount'].toString();
  //                                       UpdateidController.text =
  //                                           data['id'].toString();
  //                                       setState(() {
  //                                         updateenable = true;
  //                                         FocusScope.of(context)
  //                                             .requestFocus(quantityFocusNode);
  //                                       });
  //                                     },
  //                                   ),
  //                                   SizedBox(width: 1),
  //                                   IconButton(
  //                                     icon: Icon(
  //                                       Icons.delete,
  //                                       color: Colors.red,
  //                                       size: 15,
  //                                     ),
  //                                     onPressed: () {
  //                                       _showFinalsalestableDeleteConfirmationDialog(
  //                                           index);
  //                                     },
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ))
  //                         ],
  //                       ),
  //                     );
  //                   }).toList()
  //               ]),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<bool?> _showDeleteConfirmationDialog(index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRow(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showFinalsalestableDeleteConfirmationDialog(index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this data?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteRowinitemtable(index!);
                Navigator.pop(context);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}
