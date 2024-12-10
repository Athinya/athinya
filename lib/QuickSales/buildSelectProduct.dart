import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:scrollable/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetails extends StatefulWidget {
  List<Product> selectedProducts = [];

   ProductDetails({Key? key, required this.selectedProducts})
      : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class Product {
  final String name;
  final String price;
  final String imagePath;
  final double cgstPercentage;
  final double sgstPercentage;
  final String category;
  final String stock;
  final double stockValue;
  int quantity;
  bool isFavorite;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.category,
    required this.stock,
    required this.stockValue,
    this.quantity = 0,
    this.isFavorite = false,
  });

  double totalPrice = 0.0;
}

class _ProductDetailsState extends State<ProductDetails> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool isLoading = false;
  String errorMessage = '';
  Product? selectedProduct;
  List<String> categories = ['All', 'Favorites'];
  String selectedCategory = 'All';
  List<Product> selectedProducts = [];
  List<dynamic> allCategories = [];
  List<dynamic> mainCategories = [];
  String selectedProductName = '';
  String selectedProductPrice = '';
  String formattedTotalAmount = '';
  double? selectedProductCGST;
  double? selectedProductSGST;
  int totalItems = 0;
  double totalAmount = 0.0;
  double discountAmount = 0.0;
  double cgstPercentage = 0.0;
  double sgstPercentage = 0.0;
  double finalTaxable = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double finAmt = 0.0;
  double finalAmount = 0.0;
  int quantity = 0; // Initialize the quantity
  double totalPrice = 0.0; // Initialize the totalPrice
  String selectedPaymentType = 'Cash';
  TextEditingController gstMethodController = TextEditingController();
  List<String> paymentTypes = [];
  String orderType = 'DineIn';
  List<String> servantNames = [];
  String selectedServantName = 'Choose';
  bool _isHovered = false;
  String? gstType; // Initialize as nullable
  late var _pageController = PageController();
  String? serialNo;
  String cusid = '';
  Timer? _timer;
  double stockValue = 0.0;
  String stock = '';
  late ScrollController _scrollController;
  bool _showFloatingButton = true;
  // Method to build selected product details

  Widget _buildSelectedProductDetails() {
    bool isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return buildMobileView();
    } else {
      return buildDesktopView();
    }
  }

  TextEditingController taxAmountController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController finalTaxableAmountController = TextEditingController();
  TextEditingController fitchfinalTaxableAmountController =
      TextEditingController();
  TextEditingController cgstAmountController = TextEditingController();
  TextEditingController fitchcgstAmountController = TextEditingController();
  TextEditingController sgstAmountController = TextEditingController();
  TextEditingController fitchsgstAmountController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController fitchfinalAmountController = TextEditingController();
  TextEditingController cgstAmount0Controller = TextEditingController();
  TextEditingController cgstAmount2_5Controller = TextEditingController();
  TextEditingController cgstAmount6Controller = TextEditingController();
  TextEditingController cgstAmount9Controller = TextEditingController();
  TextEditingController cgstAmount14Controller = TextEditingController();

  void _navigateToNextPage() {
    if (_pageController.page! < 3) {
      // Assuming you have 4 pages
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToPreviousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _contactFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _tableNoFocusNode = FocusNode();
  final FocusNode _sCodeFocusNode = FocusNode();
  final FocusNode _disAmtFocusNode = FocusNode();
  final FocusNode _disPercFocusNode = FocusNode();
  final FocusNode _saveDetailsFocusNode = FocusNode();

  TextEditingController cusNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController tableNumberController = TextEditingController();
  TextEditingController scodeController = TextEditingController();
  TextEditingController sNameControlelr = TextEditingController();
  // Declare the controllers
  TextEditingController cgst0AmountController = TextEditingController();
  TextEditingController cgst25AmountController = TextEditingController();
  TextEditingController cgst6AmountController = TextEditingController();
  TextEditingController cgst9AmountController = TextEditingController();
  TextEditingController cgst14AmountController = TextEditingController();
  TextEditingController sgst0AmountController = TextEditingController();
  TextEditingController sgst25AmountController = TextEditingController();
  TextEditingController sgst6AmountController = TextEditingController();
  TextEditingController sgst9AmountController = TextEditingController();
  TextEditingController sgst14AmountController = TextEditingController();
  Future<void> fetchPaymentTypes() async {
    String? cusid = await SharedPrefs.getCusId();
    // String baseUrl = '$IpAddress/SalesCustomer/$cusid/';
    final url = Uri.parse('$IpAddress/PaymentMethod/$cusid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final paymentTypeNames = <String>[];
      for (final item in data) {
        final name = item['paytype'] as String;
        paymentTypeNames.add(name);
      }
      setState(() {
        paymentTypes = paymentTypeNames;
        if (paymentTypes.isNotEmpty) {
          selectedPaymentType = paymentTypes.first;
        }
      });
    } else {
      throw Exception('Failed to fetch payment types');
    }
  }

  Future<void> fetchAndShowPaymentTypesDialog(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await fetchPaymentTypes();
      showPaymentTypesDialog(context);
    } catch (e) {
      print('Error fetching payment types: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPaymentTypesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select PayTypes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: paymentTypes.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: paymentTypes.map((paymentType) {
                    return ListTile(
                      title: Text(
                        paymentType,
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          selectedPaymentType = paymentType;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              )
            : Text('No payment types found'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  bool isSaleOn = true; // Initial state of the switch

  void toggleSale(bool isSale) {
    setState(() {
      isSaleOn = isSale;
      if (!isSaleOn) {
        _fetchTableSalesData();
      }
    });
  }

  Future<void> _fetchTableSalesData() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      final response =
          await http.get(Uri.parse('$IpAddress/Sales_tableCount/$cusid/'));

      if (response.statusCode == 200) {
        // Parse the JSON response as a Map
        Map<String, dynamic> data = jsonDecode(response.body);

        print('Fetched data: $data'); // Debugging line to print fetched data

        // Extract the list of tables from the 'results' key
        List<dynamic> tableCounts = data['results'];

        if (tableCounts != null) {
          showTableSalesDialog(tableCounts, tableNumberController);
        } else {
          print('No table data available.');
        }
      } else {
        // Handle non-200 status codes
        print(
            'Failed to load table sales data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching table sales data: $e');
    }
  }

  void showTableSalesDialog(
      List<dynamic> tableCounts, TextEditingController controller) {
    final List<Widget> indoorCards = [];
    final List<Widget> outdoorCards = [];

    for (var table in tableCounts) {
      int count = int.parse(table['count'] as String);
      String baseCode = table['code'] as String;
      for (int i = 1; i <= count; i++) {
        String tableCode = '$baseCode$i';
        Widget card = GestureDetector(
          onTap: () {
            controller.text = tableCode;
            Navigator.of(context).pop();
          },
          child: Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.table_bar, size: 20),
                SizedBox(height: 5),
                Text(
                  tableCode,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );

        if (table['name'] == 'Indoor tables') {
          indoorCards.add(card);
        } else {
          outdoorCards.add(card);
        }
      }
    }

    showDialog(
      barrierDismissible:
          false, // Prevents closing the dialog when tapping outside
      context: context,
      builder: (BuildContext context) {
        var screenWidth = MediaQuery.of(context).size.width;
        var dialogWidth = screenWidth * 0.4;
        var isDesktop = screenWidth > 600;
        var cardsPerRow = isDesktop ? 7 : 2;

        return AlertDialog(
          title: Text('Table Sales'),
          content: Container(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Indoor Tables',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List<Widget>.generate(
                      indoorCards.length,
                      (index) => indoorCards[index],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Outdoor Tables',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List<Widget>.generate(
                      outdoorCards.length,
                      (index) => outdoorCards[index],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showServantNamesDialog(BuildContext context, List<String> servantNames,
      Function(String) onServantSelected) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Select Servant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: servantNames.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: servantNames.map((servantName) {
                      return ListTile(
                        title: Text(
                          servantName,
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          onServantSelected(servantName);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    }).toList(),
                  ),
                )
              : Text('No servants found'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        );
      },
    );
  }

  Future<void> postSerialNumber() async {
    String? cusid = await SharedPrefs.getCusId();

    try {
      if (serialNo == null) {
        print('Missing serial number for posting');
        return;
      }

      final response = await http.post(
        Uri.parse('$IpAddress/Sales_serialnoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'cusid': cusid,
          'serialno': serialNo,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // If the server returns a 201 CREATED or 200 OK response,
        // then the post was successful.
        print('Serial number posted successfully.');
      } else {
        // If the server did not return a 201 CREATED or 200 OK response,
        // then throw an exception.
        print('Failed to post serial number: ${response.statusCode}');
        // print('Response body: ${response.body}');
        throw Exception('Failed to post serial number');
      }
    } catch (e) {
      print('Error posting serial number: $e');
    }
  }

  void updateControllersBasedOnSelectedProducts() {
    itemsController.text = selectedProducts.length.toString();
    double totalAmount = 0.0;
    double taxableAmount = 0.0;
    double totalCgstAmount = 0.0;
    double totalSgstAmount = 0.0;

    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      totalAmount += productPrice;
      taxableAmount +=
          productPrice; // Adjust this as needed for taxable calculations

      // Calculate CGST and SGST based on percentage
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      double cgstAmount = 0.0;
      double sgstAmount = 0.0;

      // Calculate CGST and SGST amounts based on percentages
      if (productCGST > 0) {
        cgstAmount = productPrice * productCGST / 100;
      }
      if (productSGST > 0) {
        sgstAmount = productPrice * productSGST / 100;
      }

      totalCgstAmount += cgstAmount;
      totalSgstAmount += sgstAmount;
    }

    // Update the controllers with the calculated amounts
    finalAmountController.text = totalAmount.toStringAsFixed(2);
    taxAmountController.text = taxableAmount.toStringAsFixed(2);
    finalTaxableAmountController.text = taxableAmount.toStringAsFixed(2);
    cgstAmountController.text = totalCgstAmount.toStringAsFixed(2);
    sgstAmountController.text = totalSgstAmount.toStringAsFixed(2);
  }

  Future<double> fetchMakingCost(String productName) async {
    String? cusid = await SharedPrefs.getCusId();

    String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);

        if (responseBody is List<dynamic>) {
          for (var product in responseBody) {
            if (product['name'] == productName) {
              return double.tryParse(product['makingcost'].toString()) ?? 0.0;
            }
          }
        } else {
          //     print('Response is not a list: $responseBody');
        }
      } else {
        print('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return 0.0;
  }

  Future<void> incomeDetails() async {
    int pageNumber = 1;
    bool postedSuccessfully = false;
    final now = DateTime.now();

    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    double finalAmount = double.tryParse(finalAmountController.text) ?? 0.0;

    while (!postedSuccessfully) {
      try {
        final response = await http.post(
          Uri.parse('$IpAddress/Sales_IncomeDetails/?page=$pageNumber'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "cusid": "BTRM_1",
            "dt": formattedDate,
            "description": "Sales Bill:$serialNo",
            "amount": finalAmount.toString()
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Income details posted successfully.');
          postedSuccessfully = true; // Exit the loop
        } else {
          print(
              'Failed to post income details on page $pageNumber. Status code: ${response.statusCode}');
          // print('Response body: ${response.body}');
          pageNumber++; // Try the next page
        }
      } catch (e) {
        print('Error posting income details on page $pageNumber: $e');
        pageNumber++; // Try the next page
      }
    }
  }

  Future<void> saveDetails(BuildContext context, String paidAmount) async {
    final url = Uri.parse('$IpAddress/SalesRoundDetailsalldatas/');
    final now = DateTime.now();
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final formattedDateTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    double totalAmount = 0.0;
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;
    String salesDetails = '';

    // Ensure default values for discount fields
    if (discountPercentageController.text.isEmpty) {
      discountPercentageController.text = '0';
    }
    if (discountAmountController.text.isEmpty) {
      discountAmountController.text = '0';
    }

    updateControllersBasedOnSelectedProducts();

    try {
      // Calculate total amount and CGST amounts
      for (Product product in selectedProducts) {
        String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
        double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
        totalAmount += productPrice;

        double productCGST = product.cgstPercentage ?? 0.0;

        double discountPercentage =
            double.tryParse(discountPercentageController.text) ?? 0.0;
        double productDiscountAmount =
            (productPrice * discountPercentage) / 100;
        double finalcgstAmount = productPrice - productDiscountAmount;
        double makingCost = await fetchMakingCost(product.name);

        if (productCGST == 0.0) {
          cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        } else if (productCGST == 2.5) {
          cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        } else if (productCGST == 6.0) {
          cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        } else if (productCGST == 9.0) {
          cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        } else if (productCGST == 14.0) {
          cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        }
        salesDetails +=
            '{salesbillno:BTRM_1,category:${product.category},dt:$formattedDate,Itemname:${product.name},rate:${product.price},qty:${product.quantity},amount:$totalAmount,retailrate:${product.price},retail:${taxAmountController.text},cgst:${cgstAmountController.text},sgst:${sgstAmountController.text},serialno:1,sgstperc:${product.sgstPercentage},cgstperc:${product.cgstPercentage},makingcost:$makingCost,status:Normal,sno:1.0}';
      }

      salesDetails = salesDetails.replaceAll('}{', '},{');
      double finalAmount = double.tryParse(finalAmountController.text) ?? 0.0;
      String paidAmount = selectedPaymentType.toLowerCase() == 'credit'
          ? '0.0'
          : finalAmount.toStringAsFixed(2);

      double taxableAmount = double.tryParse(taxAmountController.text) ?? 0.0;
      double finalTaxable =
          double.tryParse(finalTaxableAmountController.text) ?? 0.0;

      String? cusid = await SharedPrefs.getCusId();

      final body = {
        'billno': serialNo,
        'cusid': cusid,
        'dt': formattedDate,
        'type': orderType,
        'tableno': tableNumberController.text.isEmpty
            ? 'null'
            : tableNumberController.text,
        'servent':
            selectedServantName == 'Choose' ? 'null' : selectedServantName,
        'count': itemsController.text,
        'amount': totalAmount,
        'discount': discountAmountController.text.isEmpty
            ? '0.0'
            : discountAmountController.text,
        'finalamount': finalAmountController.text.isEmpty
            ? '0.0'
            : finalAmountController.text,
        'cgst0': cgstAmount0.toStringAsFixed(2),
        'cgst25': cgstAmount2_5.toStringAsFixed(2),
        'cgst6': cgstAmount6.toStringAsFixed(2),
        'cgst9': cgstAmount9.toStringAsFixed(2),
        'cgst14': cgstAmount14.toStringAsFixed(2),
        'sgst0': cgstAmount0.toStringAsFixed(2),
        'sgst25': cgstAmount2_5.toStringAsFixed(2),
        'sgst6': cgstAmount6.toStringAsFixed(2),
        'sgst9': cgstAmount9.toStringAsFixed(2),
        'sgst14': cgstAmount14.toStringAsFixed(2),
        'totcgst': (cgstAmount0 +
                cgstAmount2_5 +
                cgstAmount6 +
                cgstAmount9 +
                cgstAmount14)
            .toStringAsFixed(2),
        'totsgst': (cgstAmount0 +
                cgstAmount2_5 +
                cgstAmount6 +
                cgstAmount9 +
                cgstAmount14)
            .toStringAsFixed(2),
        'paidamount': paidAmount,
        'scode': scodeController.text.isEmpty ? 'null' : scodeController.text,
        'sname': selectedServantName == 'Choose' ? 'null' : selectedServantName,
        'paytype': selectedPaymentType,
        'disperc': discountPercentageController.text.isEmpty
            ? '0.0'
            : discountPercentageController.text,
        'Status': 'Normal',
        'gststatus': gstMethodController.text.isEmpty
            ? 'null'
            : gstMethodController.text,
        'time': formattedDateTime,
        'customeramount': '0.0',
        'customerchange': '0.0',
        'taxstatus': gstType,
        'taxable': taxableAmount.toString(),
        'finaltaxable': finalTaxable.toString(),
        'SalesDetails': salesDetails,
      };

      // Conditionally add customer name if not empty
      if (cusNameController.text.isNotEmpty) {
        body['cusname'] = cusNameController.text;
      } else {
        body['cusname'] = 'null';
      }
      if (contactController.text.isNotEmpty) {
        body['contact'] = contactController.text;
      } else {
        body['contact'] = 'null';
      }
      if (tableNumberController.text.isNotEmpty) {
        body['tableno'] = tableNumberController.text;
      } else {
        body['tableno'] = 'null';
      }
      if (scodeController.text.isNotEmpty) {
        body['scode'] = scodeController.text;
      } else {
        body['scode'] = 'null';
      }
      if (discountAmountController.text.isNotEmpty) {
        body['discount'] = discountAmountController.text;
      } else {
        body['discount'] = '0.0';
      }
      if (discountPercentageController.text.isNotEmpty) {
        body['disperc'] = discountPercentageController.text;
      } else {
        body['disperc'] = '0.0';
      }

      final response = await http.post(url,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'});
      print('Request body: ${jsonEncode(body)}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Details saved successfully');
        // Show dialog with success message
        successfullySavedMessage(context);
      } else {
        // Request failed
        print('Failed to save details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occurred during the request
      print('Error saving details: $e');
    }
  }

  TextEditingController itemsController = TextEditingController();

  // include discount
  void calculateDiscountAmountInclude() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    // double totalPrice = double.tryParse(finalAmountController.text) ?? 0;
    double totalPrice = 0.0;

    itemsController.text = selectedProducts.length.toString();

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalPrice += productPrice;
    }

    double discountAmount = (totalPrice * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      print('Prodname: ${product.name}');
      print('ProdPrice: ${product.price}');
      print('Productgst: ${product.cgstPercentage}');
      print('Productsgst: ${product.sgstPercentage}');

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');

      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      print('prodprice : $productPrice');
      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');
    print('Total Price: $totalPrice');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount : $totalDiscountAmount');
    print('Final  0%: $discountAmount0');
    print('Final  2.5%: $discountAmount2_5');
    print('Final for 6%: $discountAmount6');
    print('Finalt for 9%: $discountAmount9');
    print('Final dr 14%: $discountAmount14');

    double totalAmount = 0.0;

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalAmount += productPrice;
    }
    // Calculate the final amount after applying the total discount
    double finalAmount = totalAmount - discountAmount;
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
      totalAmount;
    });

    // cgstAmount code

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      double finalcgstAmount = productPrice - productDiscountAmount;
      double totalPercentage = productCGST + productSGST;
      print('sadasdsadsadddd : $finalcgstAmount');
      print('tax : $totalPercentage');
      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalcgstAmount * 0.0 / 100);
      //     print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
      //     print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");

      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalcgstAmount * 6.0 / 112);
      //     print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");

      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalcgstAmount * 9.0 / 118);
      //     print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");

      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalcgstAmount * 14.0 / 128);
      //     print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");

      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105);");
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112);");
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118);");
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        print(" $cgstAmount14 += ($finalcgstAmount * 14.0 / 128);");
      } else {
        print("Unsupported CGST value: $productCGST");
      }

      print('finalCGST : $finalcgstAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    print('Total CGST Amount: $totalCgstPercentAmount');

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    double finalTaxableAmount =
        finalAmount - (totalCgstPercentAmount + totalCgstPercentAmount);
    print('finalTax : $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
  }

  void calculateDiscountPercentageInclude() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    //double totalPrice = double.tryParse(finalAmountController.text) ?? 0;
    double totalPrice = 0.0;
    itemsController.text = selectedProducts.length.toString();

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalPrice += productPrice;
    }

// Update the final amount controller with the formatted total price
    finalAmountController.text = '₹${totalPrice.toStringAsFixed(2)}/-';

    // Calculate discount percentage using the specified formula
    double discountPercentage =
        (totalPrice != 0) ? (discountAmount * 100 / totalPrice) : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      print('Product Name: ${product.name}');
      print('Product Price: ${product.price}');
      print('Product CGST Percentage: ${product.cgstPercentage}');
      print('Product SGST Percentage: ${product.sgstPercentage}');

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');

      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      print('price : $productPrice');
      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');
    print('Total Price: $totalPrice');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    double totalAmount = 0.0;

// Calculate the total price for selected products
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      totalAmount += productPrice;
    }
    double finalAmount = totalAmount - discountAmount;
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });

    print(' Amount: $finalAmount');

    // cgstAmount code

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productDiscountAmount = (productPrice * discountPercentage) / 100;
      double finalcgstAmount = productPrice - productDiscountAmount;
      double totalPercentage = productCGST + productSGST;
      print('sadasdsadsadddd : $finalcgstAmount');
      print('tax : $totalPercentage');
      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalcgstAmount * 0.0 / 100);
      //     print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
      //     print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");

      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalcgstAmount * 6.0 / 112);
      //     print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");

      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalcgstAmount * 9.0 / 118);
      //     print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");

      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalcgstAmount * 14.0 / 128);
      //     print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");

      //     break;
      // }
      if (productCGST == 0.0) {
        cgstAmount0 += (finalcgstAmount * 0.0 / 100);
        print(" $cgstAmount0 += ($finalcgstAmount * 0.0 / 100);");
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalcgstAmount * 2.5 / 105);
        print(" $cgstAmount2_5 += ($finalcgstAmount * 2.5 / 105) ;");
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalcgstAmount * 6.0 / 112);
        print(" $cgstAmount6 += ($finalcgstAmount * 6.0 / 112) ;");
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalcgstAmount * 9.0 / 118);
        print(" $cgstAmount9 += ($finalcgstAmount * 9.0 / 118) ;");
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalcgstAmount * 14.0 / 128);
        print(" $cgstAmount14 += ($finalcgstAmount * 14 / 128) ;");
      } else {
        print("Unknown CGST rate: $productCGST");
      }

      print('finalCGST : $finalcgstAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    print('Total CGST Amount: $totalCgstPercentAmount');

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    double finalTaxableAmount =
        finalAmount - (totalCgstPercentAmount + totalCgstPercentAmount);
    print('finalTax : $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
  }

  // exclude discount
  void calculateDiscountAmountExclude() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    // double totalTaxableAmount = double.tryParse(taxAmountController.text) ?? 0;

    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount amount
    double discountAmount = (totalTaxableAmount * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);

    // Print values for debugging
    print('Total Taxable Amount: $totalTaxableAmount');
    print('Discount Percentage: $discountPercentage');
    print('Discount Amount: $discountAmount');
    // Initialize discount amounts for each CGST percentage

    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    // Calculate discount amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;

      print('Product Name: ${product.name}');
      print('Product Price: $productPrice');
      print('Product CGST Percentage: $productCGST');
      print('Product SGST Percentage: $productSGST');
      print('Product Taxable Amount: $productTaxableAmount');
      print('Product Discount Amount: $productDiscountAmount');

      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }

      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    // // Calculate the final taxable amount after applying the discount
    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    print('Final Taxable Amount: $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    // Calculate CGST amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;
      double finalProductTaxableAmount =
          productTaxableAmount - productDiscountAmount;

      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      }

      print('Final CGST : $finalProductTaxableAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    // Calculate the final amount by adding total taxable amount, total CGST amount, and total SGST amount
    double finalAmount =
        totalTaxableAmount + (totalCgstPercentAmount + totalCgstPercentAmount);
    finalAmountController.text = finalAmount.toStringAsFixed(2);

    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });

//
    print('tax amount : $totalTaxableAmount');
    print('cgstAmount : $totalCgstPercentAmount');
    print('sgstAmount : $totalCgstPercentAmount');
    print('fin amount : $finalAmount');
  }

  void calculateDiscountPercentageExclude() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount percentage using the total taxable amount
    double discountPercentage = (totalTaxableAmount != 0)
        ? (discountAmount * 100 / totalTaxableAmount)
        : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
    print('Total Taxable Amount: $totalTaxableAmount');

    // Initialize discount amounts for each CGST percentage
    double discountAmount0 = 0.0;
    double discountAmount2_5 = 0.0;
    double discountAmount6 = 0.0;
    double discountAmount9 = 0.0;
    double discountAmount14 = 0.0;

    // Calculate discount amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;

      print('Product Name: ${product.name}');
      print('Product Price: $productPrice');
      print('Product CGST Percentage: $productCGST');
      print('Product SGST Percentage: $productSGST');
      print('Product Taxable Amount: $productTaxableAmount');
      print('Product Discount Amount: $productDiscountAmount');

      // switch (productCGST) {
      //   case 0.0:
      //     discountAmount0 += productDiscountAmount;
      //     break;
      //   case 2.5:
      //     discountAmount2_5 += productDiscountAmount;
      //     break;
      //   case 6.0:
      //     discountAmount6 += productDiscountAmount;
      //     break;
      //   case 9.0:
      //     discountAmount9 += productDiscountAmount;
      //     break;
      //   case 14.0:
      //     discountAmount14 += productDiscountAmount;
      //     break;
      // }
      if (productCGST == 0.0) {
        discountAmount0 += productDiscountAmount;
      } else if (productCGST == 2.5) {
        discountAmount2_5 += productDiscountAmount;
      } else if (productCGST == 6.0) {
        discountAmount6 += productDiscountAmount;
      } else if (productCGST == 9.0) {
        discountAmount9 += productDiscountAmount;
      } else if (productCGST == 14.0) {
        discountAmount14 += productDiscountAmount;
      }
    }

    print('Discount Percentage: $discountPercentage');

    double totalDiscountAmount = discountAmount0 +
        discountAmount2_5 +
        discountAmount6 +
        discountAmount9 +
        discountAmount14;

    print('Total Discount Amount: $totalDiscountAmount');
    print('Final discount Amount for 0%: $discountAmount0');
    print('Final discount Amount for 2.5%: $discountAmount2_5');
    print('Final discount Amount for 6%: $discountAmount6');
    print('Final discount Amount for 9%: $discountAmount9');
    print('Final discount Amount for 14%: $discountAmount14');

    // Calculate the final taxable amount after applying the discount
    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    print('Final Taxable Amount: $finalTaxableAmount');
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    // Initialize CGST amounts for each CGST percentage
    double cgstAmount0 = 0.0;
    double cgstAmount2_5 = 0.0;
    double cgstAmount6 = 0.0;
    double cgstAmount9 = 0.0;
    double cgstAmount14 = 0.0;

    // Calculate CGST amount for each product
    for (Product product in selectedProducts) {
      double productCGST = product.cgstPercentage ?? 0.0;
      double productSGST = product.sgstPercentage ?? 0.0;

      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;
      double discountPercentage =
          double.tryParse(discountPercentageController.text) ?? 0.0;
      double productTaxableAmount = productPrice;
      double productDiscountAmount =
          (productTaxableAmount * discountPercentage) / 100;
      double finalProductTaxableAmount =
          productTaxableAmount - productDiscountAmount;

      // switch (productCGST) {
      //   case 0.0:
      //     cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      //     break;
      //   case 2.5:
      //     cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      //     break;
      //   case 6.0:
      //     cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      //     break;
      //   case 9.0:
      //     cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      //     break;
      //   case 14.0:
      //     cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      //     break;
      // }

      if (productCGST == 0.0) {
        cgstAmount0 += (finalProductTaxableAmount * 0.0 / 100);
      } else if (productCGST == 2.5) {
        cgstAmount2_5 += (finalProductTaxableAmount * 2.5 / 105);
      } else if (productCGST == 6.0) {
        cgstAmount6 += (finalProductTaxableAmount * 6.0 / 112);
      } else if (productCGST == 9.0) {
        cgstAmount9 += (finalProductTaxableAmount * 9.0 / 118);
      } else if (productCGST == 14.0) {
        cgstAmount14 += (finalProductTaxableAmount * 14.0 / 128);
      }

      print('Final CGST : $finalProductTaxableAmount');
    }

    double totalCgstPercentAmount =
        cgstAmount0 + cgstAmount2_5 + cgstAmount6 + cgstAmount9 + cgstAmount14;
    cgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);
    sgstAmountController.text = totalCgstPercentAmount.toStringAsFixed(2);

    // Print the CGST amounts for each CGST percentage
    print('CGST Amount for 0%: $cgstAmount0');
    print('CGST Amount for 2.5%: $cgstAmount2_5');
    print('CGST Amount for 6%: $cgstAmount6');
    print('CGST Amount for 9%: $cgstAmount9');
    print('CGST Amount for 14%: $cgstAmount14');

    // Calculate the final amount by adding total taxable amount, total CGST amount, and total SGST amount
    double finalAmount =
        totalTaxableAmount + (totalCgstPercentAmount + totalCgstPercentAmount);
    finalAmountController.text = finalAmount.toStringAsFixed(2);
    print(' Amount: $finalAmount');

    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
    String formattedtotAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(totalAmount);
    print('abcd : $formattedtotAmount');
    setState(() {
      totalAmount = formattedtotAmount as double;
    });
    print('tax amount : $totalTaxableAmount');
    print('cgstAmount : $totalCgstPercentAmount');
    print('sgstAmount : $totalCgstPercentAmount');
    print('fin amount : $finalAmount');
  }

  //non gst discount

  void calculateDisAmtNongst() {
    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    double discountAmount = (totalTaxableAmount * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);
    print('$totalTaxableAmount');
    print('$discountPercentage');
    print('dis amt : $discountAmount');

    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
    finalAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    print('$totalTaxableAmount');
    print('$finalTaxableAmount');
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalTaxableAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
  }

  void calculateDisPercentNongst() {
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double totalTaxableAmount = 0.0;
    itemsController.text = selectedProducts.length.toString();

    // Calculate the total taxable amount first
    for (Product product in selectedProducts) {
      String cleanedPrice = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      double productPrice = double.tryParse(cleanedPrice) ?? 0.0;

      // In exclude GST scenario, the product price is already the taxable amount
      totalTaxableAmount += productPrice;
    }

    // Calculate discount percentage using the total taxable amount
    double discountPercentage = (totalTaxableAmount != 0)
        ? (discountAmount * 100 / totalTaxableAmount)
        : 0;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
    print('Total Taxable Amount: $totalTaxableAmount');

    double finalTaxableAmount = totalTaxableAmount - discountAmount;
    finalTaxableAmountController.text = finalTaxableAmount.toStringAsFixed(2);
    finalAmountController.text = finalTaxableAmount.toStringAsFixed(2);

    print('$totalTaxableAmount');
    print('$finalTaxableAmount');
    String formattedTotalAmount = NumberFormat.currency(
      locale: 'en_IN', // Use 'en_IN' for Indian formatting (₹ symbol)
      symbol: '₹', // Specify currency symbol
    ).format(finalTaxableAmount);
    print('format : $formattedTotalAmount');
    setState(() {
      fitchfinalAmountController.text = formattedTotalAmount;
    });
  }

  Widget buildMobileView() {
    double totalAmount = 0.0;

    Map<String, Map<String, dynamic>> productDetails = {};

    void updateProductDetails(Product product) {
      final productPrice = double.parse(product.price.replaceAll('₹', ''));

      if (productDetails.containsKey(product.name)) {
        productDetails[product.name]!['quantity'] += product.quantity;
        productDetails[product.name]!['totalPrice'] +=
            productPrice * product.quantity;
      } else {
        productDetails[product.name] = {
          'quantity': product.quantity,
          'totalPrice': productPrice * product.quantity,
          'cgstPercentage': product.cgstPercentage ?? 0.0,
          'sgstPercentage': product.sgstPercentage ?? 0.0,
        };
      }

      totalAmount = 0.0;
      productDetails.forEach((_, details) {
        totalAmount += details['totalPrice'] as double;
      });

      print('Total Amount: $totalAmount');
    }

    Widget buildRowHeaders() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Qty',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    color: Colors.black,
                    size: 18,
                  ),
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildProductDetails(
        String productName, int quantity, double totalPrice, Product product) {
      TextEditingController _quantityController =
          TextEditingController(text: product.quantity.toString());
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                child: Text(
                  productName,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Text(
                  '${product.quantity}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
              const SizedBox(width: 60),
              Container(
                  width: 60,
                  child: Text(
                    '$totalPrice',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () {
                  setState(() {
                    for (var product in selectedProducts) {
                      if (product.name == product.name) {
                        selectedProducts.remove(product);
                        break;
                      }
                    }
                  });
                },
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
        ],
      );
    }

    double calculateCGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * cgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * cgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateSGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * sgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * sgstPercent) / 100;
        case 'NonGst':
          return 0.0;
        default:
          return 0.0;
      }
    }

    double calculateTaxableAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice - (cgstAmount + sgstAmount);
        case 'Excluding':
          return totalPrice;
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    double calculateFinalAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return totalPrice;
        case 'Excluding':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice + (cgstAmount + sgstAmount);
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    void showProductDetailsDialog({
      required String discountAmount,
      required String finalTaxable,
      required String cgst,
      required String sgst,
      required String finalAmount,
    }) {
      final ScrollController controller = ScrollController();
      fitchcgstAmountController.text = cgst;
      fitchsgstAmountController.text = sgst;
      fitchfinalTaxableAmountController.text = finalTaxable;
      fitchfinalAmountController.text = finalAmount;

      TextEditingController itemsController = TextEditingController();
      itemsController.text = productDetails.length.toString();

      double totalTaxableAmount = 0.0;
      productDetails.forEach((key, value) {
        totalTaxableAmount += calculateTaxableAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      taxAmountController.text = totalTaxableAmount.toStringAsFixed(2);

      finalTaxableAmountController.text = totalTaxableAmount.toStringAsFixed(2);
      double totalCGSTAmount = 0.0;
      productDetails.forEach((key, value) {
        totalCGSTAmount += calculateCGST(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      cgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);
      sgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);

      double totalFinalAmount = 0.0;
      productDetails.forEach((key, value) {
        totalFinalAmount += calculateFinalAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      finalAmountController.text = totalFinalAmount.toStringAsFixed(2);

      Container buildStyledTextField(TextEditingController controller) {
        return Container(
          width: 100,
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
              controller: controller,
              readOnly: true,
            ),
          ),
        );
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Product Details',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: ScrollableView(
                    controller: controller,
                    scrollBarVisible: true,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.grey[200],
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            // scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 160,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Total',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 105,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Taxable Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Retail Rate',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            'Final Amt',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            productDetails.entries.map((entry) {
                                          double cgstAmount = calculateCGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double sgstAmount = calculateSGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double taxableAmount =
                                              calculateTaxableAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);
                                          print(
                                              'taxableAmount : $taxableAmount');
                                          double finalAmount =
                                              calculateFinalAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical:
                                                    4.0), // Add spacing between products
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 160,
                                                      child: Center(
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          entry
                                                              .value['quantity']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '₹${entry.value['totalPrice']}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          cgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          sgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['cgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['sgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          finalAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'No.of.items',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildStyledTextField(
                                                  itemsController),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Taxable Amount',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                taxAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount %',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountPercentageController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountAmountInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountAmountExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisAmtNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountAmountController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'Including') {
                                                        calculateDiscountPercentageInclude();
                                                      } else if (gstType ==
                                                          'Excluding') {
                                                        calculateDiscountPercentageExclude();
                                                      } else if (gstType ==
                                                          'NonGst') {
                                                        calculateDisPercentNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Taxable',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalTaxableAmountController
                                                        .text.isEmpty
                                                    ? finalTaxableAmountController
                                                    : fitchfinalTaxableAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Cgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchcgstAmountController
                                                        .text.isEmpty
                                                    ? cgstAmountController
                                                    : fitchcgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Sgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchsgstAmountController
                                                        .text.isEmpty
                                                    ? sgstAmountController
                                                    : fitchsgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalAmountController
                                                        .text.isEmpty
                                                    ? finalAmountController
                                                    : fitchfinalAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          });
    }

    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showProductDetailsDialog(
                  discountAmount: discountAmount.toString(),
                  finalTaxable: "${finalTaxableAmountController.text}",
                  cgst: "${cgstAmountController.text}",
                  sgst: "${sgstAmountController.text}",
                  finalAmount: "${finalAmountController.text}",
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    onEnter: (event) => setState(() => _isHovered = true),
                    onExit: (event) => setState(() => _isHovered = false),
                    child: Text(
                      'Product Details',
                      style: TextStyle(
                        color: _isHovered ? Colors.blue : Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 8), // Add spacing between text and icon
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.0,
                      ),
                    ),
                    TextSpan(
                      text: ' Tap "product details" to view the details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Display the row headers only if there are selected products
            if (selectedProducts.isNotEmpty) buildRowHeaders(),
            const SizedBox(height: 13),
            // Display the details of selected products
            Container(
              height: 268,
              // color: Colors.white,
              child: ScrollConfiguration(
                behavior: ScrollBehavior()
                    .copyWith(overscroll: false, scrollbars: false),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: selectedProducts.map((product) {
                      // Update product details map
                      updateProductDetails(product);

                      return buildProductDetails(
                          product.name,
                          product.quantity,
                          double.parse(product.price.replaceAll('₹', '')) *
                              product.quantity,
                          product);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: Color.fromRGBO(56, 37, 51, 1),
            width: MediaQuery.of(context).size.width,
            height: 170,
            child: PageView(
              controller: _pageController,
              children: [
                //first container
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 25),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Customer Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Name :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 20),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      controller: cusNameController,
                                      focusNode: _nameFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Name: ${cusNameController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_contactFocusNode);
                                      },
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Contact :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 7),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      focusNode: _contactFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Contact: ${contactController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_addressFocusNode);
                                      },
                                      controller: contactController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Address :',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(width: 6),
                                Container(
                                    width: 150,
                                    height: 30,
                                    child: TextField(
                                      focusNode: _addressFocusNode,
                                      onEditingComplete: () {
                                        print(
                                            'Address: ${addressController.text}');
                                        FocusScope.of(context)
                                            .requestFocus(_tableNoFocusNode);
                                      },
                                      controller: addressController,
                                      decoration: InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .grey), // Border color when enabled
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .white), // Border color when focused
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                //second
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 25),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Type Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'GST Method :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 100,
                                  height: 30,
                                  child: TextField(
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    controller: gstMethodController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 5.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    readOnly: true,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee_sharp,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Pay Type :',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      fetchAndShowPaymentTypesDialog(context);
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            color: Colors.black,
                                            size: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            selectedPaymentType,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //    SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'DineIn',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'DineIn',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale:
                                            0.8, // Adjust this value to scale the size of the radio button
                                        child: Radio<String>(
                                          value: 'Take Away',
                                          groupValue: orderType,
                                          onChanged: (value) {
                                            setState(() {
                                              orderType = value.toString();
                                            });
                                          },
                                          activeColor: Colors.white,
                                          fillColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Colors
                                                  .white; // Color when selected
                                            }
                                            return Colors
                                                .white; // Color when not selected
                                          }),
                                        ),
                                      ),
                                      Text(
                                        'Take Away',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                //third
                Container(
                  height: 50,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 85.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 200,
                                        height: 30,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => toggleSale(true),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSaleOn
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Sales',
                                                    style: TextStyle(
                                                      color: isSaleOn
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => toggleSale(false),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSaleOn
                                                        ? Colors.white
                                                        : Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.horizontal(
                                                      right:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'TableSales',
                                                    style: TextStyle(
                                                      color: isSaleOn
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: isSaleOn
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/trend.png',
                                              width: 35,
                                              height: 35,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Sales',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.table_restaurant,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Table No :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 30,
                                                  child: TextField(
                                                    focusNode:
                                                        _tableNoFocusNode,
                                                    onEditingComplete: () {
                                                      print(
                                                          'tablNo: ${tableNumberController.text}');
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _sCodeFocusNode);
                                                    },
                                                    controller:
                                                        tableNumberController,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                    ),
                                                    decoration: InputDecoration(
                                                        hintStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey), // Border color when enabled
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        5.0)),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.format_list_numbered,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Scode :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 25.0,
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 30,
                                                  child: TextField(
                                                    focusNode: _sCodeFocusNode,
                                                    onEditingComplete: () {
                                                      print(
                                                          'sCode: ${scodeController.text}');
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _disAmtFocusNode);
                                                    },
                                                    controller: scodeController,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                    ),
                                                    decoration: InputDecoration(
                                                        hintStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey), // Border color when enabled
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        5.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'SName :',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showServantNamesDialog(
                                                          context, servantNames,
                                                          (selectedName) {
                                                        setState(() {
                                                          selectedServantName =
                                                              selectedName;
                                                        });
                                                        print(
                                                            'Selected Servant: $selectedName');
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 150,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          selectedServantName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 25,
                        child: GestureDetector(
                          onTap: _navigateToPreviousPage,
                          child: Icon(
                            Icons.arrow_circle_left,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 25,
                        child: GestureDetector(
                          onTap: _navigateToNextPage,
                          child: Icon(
                            Icons.arrow_circle_right,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //four
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToPreviousPage,
                        child: Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 120),
                              Column(
                                children: [
                                  Text(
                                    '₹$totalAmount',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dis %:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 5),
                                    Column(children: [
                                      SizedBox(
                                        width: 65,
                                        height: 25,
                                        child: Center(
                                          child: TextFormField(
                                            focusNode: _disAmtFocusNode,
                                            onEditingComplete: () {
                                              print(
                                                  'discountAmount: ${discountAmountController.text}');
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      _disPercFocusNode);
                                            },
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .grey), // Border color when enabled
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                vertical: 9.0,
                                                horizontal: 9.0,
                                              ),
                                            ),
                                            controller:
                                                discountPercentageController,
                                            onChanged: (value) {
                                              if (gstType == 'Including') {
                                                calculateDiscountAmountInclude();
                                              } else if (gstType ==
                                                  'Excluding') {
                                                calculateDiscountAmountExclude();
                                              } else if (gstType == 'NonGst') {
                                                calculateDisAmtNongst();
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ])
                                  ]),
                              SizedBox(
                                width: 35,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dis Amt:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 5),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 65,
                                        height: 25,
                                        child: Center(
                                          child: TextFormField(
                                            focusNode: _disPercFocusNode,
                                            onEditingComplete: () {
                                              print(
                                                  'discountPerc: ${discountPercentageController.text}');
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      _saveDetailsFocusNode);
                                            },
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: '',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .grey), // Border color when enabled
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 9.0,
                                                      horizontal: 9.0),
                                            ),
                                            controller:
                                                discountAmountController,
                                            onChanged: (value) {
                                              if (gstType == 'Including') {
                                                calculateDiscountPercentageInclude();
                                              } else if (gstType ==
                                                  'Excluding') {
                                                calculateDiscountPercentageExclude();
                                              } else if (gstType == 'NonGst') {
                                                calculateDisPercentNongst();
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'RS.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    5), // Space before the vertical line
                                            Container(
                                              width:
                                                  1, // Width of the vertical line
                                              height:
                                                  30, // Height of the vertical line
                                              color: Colors
                                                  .black, // Color of the vertical line
                                            ),
                                            SizedBox(
                                                width:
                                                    6), // Space after the vertical line
                                            Text(
                                              '${fitchfinalAmountController.text.isEmpty ? NumberFormat.currency(
                                                  locale: 'en_IN',
                                                  symbol: '₹',
                                                ).format(totalAmount) : fitchfinalAmountController.text}/-',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 15),
                              Container(
                                width: 100,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (selectedPaymentType == "Credit" &&
                                        cusNameController.text.isEmpty) {
                                      showAlert(context,
                                          "Customer name is required for credit payment type.");
                                      return;
                                    }
                                    await postSerialNumber();
                                    if (!(selectedPaymentType == "Credit")) {
                                      await incomeDetails();
                                    }
                                    String paidAmount =
                                        selectedPaymentType.toLowerCase() ==
                                                'credit'
                                            ? '0.0'
                                            : finalAmount.toStringAsFixed(2);

                                    await saveDetails(context, paidAmount);
                                    setState(() {
                                      // Reset the form fields
                                      tableNumberController.clear();
                                      itemsController.clear();
                                      discountAmountController.clear();
                                      finalAmountController.clear();
                                      scodeController.clear();
                                      cusNameController.clear();
                                      contactController.clear();
                                      discountPercentageController.clear();
                                      taxAmountController.clear();
                                      finalTaxableAmountController.clear();
                                      addressController.clear();
                                      selectedProducts
                                          .clear(); // Deselect products
                                      servantNames.clear();
                                      paymentTypes.clear();
                                    });
                                  },
                                  focusNode: _saveDetailsFocusNode,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue, // Text color

                                    textStyle: TextStyle(fontSize: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ]),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: _navigateToNextPage,
                        child: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ))
    ]);
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert', style: TextStyle(fontSize: 15)),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Adjust the radius here
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDesktopView() {
    int productIndex =
        selectedProducts.indexWhere((product) => product.name == product.name);
    const double mmWidth = 80.0; // 80 mm

    double pixels = mmWidth * MediaQuery.of(context).devicePixelRatio / 25.4;
    // void _showDialog() {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         child: Container(
    //           width: pixels,
    //           // height: 100,
    //           padding: const EdgeInsets.all(16.0),
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.grey.withOpacity(0.5),
    //                 spreadRadius: 2,
    //                 blurRadius: 5,
    //                 offset: const Offset(0, 3),
    //               ),
    //             ],
    //             borderRadius: BorderRadius.circular(8),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Menaka Restarunt',
    //                 style: TextStyle(
    //                   fontSize: 15,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               SizedBox(height: 8),
    //               Text(
    //                 '123 Main Street',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'Tenkasi-123456',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'GST No: 1234567890',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'FSSAI No: ABC123XYZ456',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               Text(
    //                 'Contact: +91 9876543210',
    //                 style: TextStyle(fontSize: 13),
    //               ),
    //               SizedBox(height: 10),
    //               // DashedDivider(),
    //               SizedBox(height: 10),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [Text('BillNo : 01'), Text('payType:cash')],
    //               ),
    //               SizedBox(height: 5),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [Text('Date:21.06.2024'), Text('Time:5.00 PM')],
    //               ),
    //               SizedBox(height: 10),
    //               // DashedDivider(),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }

    num totalAmount = 0;

    Map<String, Map<String, dynamic>> productDetails = {};
    void updateProductDetails(Product product) {
      final productPrice = double.parse(product.price.replaceAll('₹', ''));

      if (productDetails.containsKey(product.name)) {
        productDetails[product.name]!['quantity'] = product.quantity;
        productDetails[product.name]!['totalPrice'] =
            productPrice * product.quantity;
      } else {
        productDetails[product.name] = {
          'quantity': product.quantity,
          'totalPrice': productPrice * product.quantity,
          'cgstPercentage': product.cgstPercentage ?? 0.0,
          'sgstPercentage': product.sgstPercentage ?? 0.0,
        };
      }

      print('Product details updated:');
      print('Name: ${product.name}');
      print('Updated Quantity: ${productDetails[product.name]!['quantity']}');
      print(
          'Updated Total Price: ₹${productDetails[product.name]!['totalPrice']}');
      print(
          'CGST Percentage: ${productDetails[product.name]!['cgstPercentage']}');
      print(
          'SGST Percentage: ${productDetails[product.name]!['sgstPercentage']}');

      totalAmount = 0.0;
      productDetails.forEach((_, details) {
        totalAmount += details['totalPrice'] as double;
      });

      print('Total Amount: $totalAmount');
    }

    Widget buildRowHeaders() {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag,
                      color: Colors.black), // Icon for name
                  SizedBox(width: 3),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.black,
                      //    fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.shopping_cart,
                      color: Colors.black), // Icon for quantity
                  SizedBox(width: 3),
                  Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.black,
                      //    fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.attach_money,
                      color: Colors.black), // Icon for total price
                  SizedBox(width: 3),
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

// Define the buildProductDetails function
    Widget buildProductDetails(
        String name, int quantity, double totalPrice, Product product) {
      return Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Container(
            width: 80,
            child: Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          SizedBox(
            width: 65,
          ),
          Container(
            width: 90,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  color: Colors.red,
                  iconSize: 15,
                  onPressed: () {
                    setState(() {
                      if (quantity > 1) {
                        product.quantity--;
                      }
                    });
                  },
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  iconSize: 15,
                  onPressed: () {
                    setState(() {
                      product.quantity++;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 65,
          ),
          Text(
            '₹$totalPrice',
            style: TextStyle(fontSize: 15),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            iconSize: 16,
            onPressed: () {
              setState(() {
                selectedProducts.remove(product);
              });
            },
          ),
        ],
      );
    }

    double calculateCGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          print(totalPrice);
          print(cgstPercent);
          print(sgstPercent);

          return (totalPrice * cgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * cgstPercent) / 100;
        case 'NonGst':
          return 0.0; // No GST for non-GST items
        default:
          return 0.0;
      }
    }

    double calculateSGST(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return (totalPrice * sgstPercent) / (100 + cgstPercent + sgstPercent);
        case 'Excluding':
          return (totalPrice * sgstPercent) / 100;
        case 'NonGst':
          return 0.0; // No GST for non-GST items
        default:
          return 0.0;
      }
    }

    double calculateTaxableAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice - (cgstAmount + sgstAmount);
        case 'Excluding':
          return totalPrice;
        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    double calculateFinalAmount(double totalPrice, double cgstPercent,
        double sgstPercent, String gstType) {
      switch (gstType) {
        case 'Including':
          return totalPrice;
        case 'Excluding':
          double cgstAmount =
              calculateCGST(totalPrice, cgstPercent, sgstPercent, gstType);
          double sgstAmount =
              calculateSGST(totalPrice, sgstPercent, cgstPercent, gstType);
          return totalPrice + (cgstAmount + sgstAmount);

        case 'NonGst':
          return totalPrice;
        default:
          return 0.0;
      }
    }

    void showProductDetailsDialog({
      required String discountAmount,
      required String finalTaxable,
      required String cgst,
      required String sgst,
      required String finalAmount,
    }) {
      final ScrollController controller = ScrollController();
      fitchcgstAmountController.text = cgst;
      fitchsgstAmountController.text = sgst;
      fitchfinalTaxableAmountController.text = finalTaxable;
      fitchfinalAmountController.text = finalAmount;

      TextEditingController itemsController = TextEditingController();
      itemsController.text = productDetails.length.toString();

      double totalTaxableAmount = 0.0;
      productDetails.forEach((key, value) {
        totalTaxableAmount += calculateTaxableAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      taxAmountController.text = totalTaxableAmount.toStringAsFixed(2);

      finalTaxableAmountController.text = totalTaxableAmount.toStringAsFixed(2);
      double totalCGSTAmount = 0.0;
      productDetails.forEach((key, value) {
        totalCGSTAmount += calculateCGST(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      cgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);
      sgstAmountController.text = totalCGSTAmount.toStringAsFixed(2);

      double totalFinalAmount = 0.0;
      productDetails.forEach((key, value) {
        totalFinalAmount += calculateFinalAmount(
          value['totalPrice'],
          value['cgstPercentage'],
          value['sgstPercentage'],
          gstType!,
        );
      });

      finalAmountController.text = totalFinalAmount.toStringAsFixed(2);

      Container buildStyledTextField(TextEditingController controller) {
        return Container(
          width: 100,
          height: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ),
              controller: controller,
              readOnly: true,
            ),
          ),
        );
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Product Details',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: ScrollConfiguration(
                  behavior: ScrollBehavior()
                      .copyWith(overscroll: false, scrollbars: false),
                  child: ScrollableView(
                    controller: controller,
                    scrollBarVisible: true,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.grey[200],
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior()
                              .copyWith(overscroll: false, scrollbars: false),
                          child: SingleChildScrollView(
                            // scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 160,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Total',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 105,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Taxable Amt',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('Retail Rate',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('CGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text('SGST %',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black.withOpacity(0.8),
                                        width: 90,
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Center(
                                              child: Text(
                                            'Final Amt',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            productDetails.entries.map((entry) {
                                          double cgstAmount = calculateCGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double sgstAmount = calculateSGST(
                                              entry.value['totalPrice'],
                                              entry.value['cgstPercentage'],
                                              entry.value['sgstPercentage'],
                                              gstType!);
                                          double taxableAmount =
                                              calculateTaxableAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);
                                          print(
                                              'taxableAmount : $taxableAmount');
                                          double finalAmount =
                                              calculateFinalAmount(
                                                  entry.value['totalPrice'],
                                                  entry.value['cgstPercentage'],
                                                  entry.value['sgstPercentage'],
                                                  gstType!);

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical:
                                                    4.0), // Add spacing between products
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 160,
                                                      child: Center(
                                                        child: Text(
                                                          entry.key,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          entry
                                                              .value['quantity']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '₹${entry.value['totalPrice']}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          cgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          sgstAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          taxableAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['cgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          '${entry.value['sgstPercentage']}%',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 90,
                                                      child: Center(
                                                        child: Text(
                                                          finalAmount
                                                              .toStringAsFixed(
                                                                  2),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'No.of.items',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              buildStyledTextField(
                                                  itemsController),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Taxable Amount',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                taxAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount %',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountPercentageController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'include') {
                                                        calculateDiscountAmountInclude();
                                                      } else if (gstType ==
                                                          'exclude') {
                                                        calculateDiscountAmountExclude();
                                                      } else if (gstType ==
                                                          'non gst') {
                                                        calculateDisAmtNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Discount Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 30,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.0,
                                                              horizontal: 15.0),
                                                    ),
                                                    controller:
                                                        discountAmountController,
                                                    onChanged: (value) {
                                                      if (gstType ==
                                                          'include') {
                                                        calculateDiscountPercentageInclude();
                                                      } else if (gstType ==
                                                          'exclude') {
                                                        calculateDiscountPercentageExclude();
                                                      } else if (gstType ==
                                                          'non gst') {
                                                        calculateDisPercentNongst();
                                                      }
                                                    },
                                                    readOnly: true,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Taxable',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalTaxableAmountController
                                                        .text.isEmpty
                                                    ? finalTaxableAmountController
                                                    : fitchfinalTaxableAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Cgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchcgstAmountController
                                                        .text.isEmpty
                                                    ? cgstAmountController
                                                    : fitchcgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Sgst Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchsgstAmountController
                                                        .text.isEmpty
                                                    ? sgstAmountController
                                                    : fitchsgstAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  'Final Amt',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              buildStyledTextField(
                                                fitchfinalAmountController
                                                        .text.isEmpty
                                                    ? finalAmountController
                                                    : fitchfinalAmountController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
          });
    }

    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align to start

      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showProductDetailsDialog(
                    discountAmount: discountAmount.toString(),
                    finalTaxable: "${finalTaxableAmountController.text}",
                    cgst: "${cgstAmountController.text}",
                    sgst: "${sgstAmountController.text}",
                    finalAmount: "${finalAmountController.text}",
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      onEnter: (event) => setState(() => _isHovered = true),
                      onExit: (event) => setState(() => _isHovered = false),
                      child: Text(
                        'Product Details',
                        style: TextStyle(
                          color: _isHovered ? Colors.blue : Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13.0,
                        ),
                      ),
                      TextSpan(
                        text: ' Tap "product details" to view the details',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(width: 45),

              const SizedBox(height: 25),

              // Display the row headers only if there are selected products
              if (selectedProducts.isNotEmpty) buildRowHeaders(),
              const SizedBox(height: 10),
              // Display the details of selected products
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: 300,
                    // color: Colors.white,
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior()
                          .copyWith(overscroll: false, scrollbars: false),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: selectedProducts.map((product) {
                            // Calculate total price based on quantity and price
                            double totalPrice = product.quantity *
                                double.parse(product.price.replaceAll('₹', ''));
                            updateProductDetails(product);
                            return buildProductDetails(
                              product.name,
                              product.quantity,
                              totalPrice,
                              product,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SingleChildScrollView(
                  child: Container(
                    color: Color.fromRGBO(56, 37, 51, 1),
                    width: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.width *
                            0.28 // Desktop view
                        : MediaQuery.of(context).size.width > 600
                            ? MediaQuery.of(context).size.width *
                                0.36 // Tablet view
                            : MediaQuery.of(context)
                                .size
                                .width, // Mobile view (not currently used)
                    height: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.height *
                            0.20 // Desktop view
                        : MediaQuery.of(context).size.width > 600
                            ? MediaQuery.of(context).size.height *
                                0.16 // Tablet view
                            : MediaQuery.of(context).size.height *
                                0.40, // Mobile view

                    //  width: MediaQuery.of(context).size.width * 0.28,
                    // height: MediaQuery.of(context).size.height * 0.20,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 150),
                              Column(
                                children: [
                                  Text(
                                    '₹$totalAmount',
                                    style: const TextStyle(
                                        fontSize: 19, color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dis %:',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 7),
                                  Column(children: [
                                    SizedBox(
                                      width: 65,
                                      height: 25,
                                      child: Center(
                                        child: TextFormField(
                                          focusNode: _disAmtFocusNode,
                                          onEditingComplete: () {
                                            print(
                                                'discountAmount: ${discountAmountController.text}');
                                            FocusScope.of(context).requestFocus(
                                                _disPercFocusNode);
                                          },
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .grey), // Border color when enabled
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 9.0,
                                              horizontal: 9.0,
                                            ),
                                          ),
                                          controller:
                                              discountPercentageController,
                                          onChanged: (value) {
                                            if (gstType == 'Including') {
                                              calculateDiscountAmountInclude();
                                            } else if (gstType == 'Excluding') {
                                              calculateDiscountAmountExclude();
                                            } else if (gstType == 'NonGst') {
                                              calculateDisAmtNongst();
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                  ])
                                ]),
                            SizedBox(
                              width: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dis Amt:',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 65,
                                      height: 25,
                                      child: Center(
                                        child: TextFormField(
                                          focusNode: _disPercFocusNode,
                                          onEditingComplete: () {
                                            print(
                                                'discountPerc: ${discountPercentageController.text}');
                                            FocusScope.of(context).requestFocus(
                                                _saveDetailsFocusNode);
                                          },
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .grey), // Border color when enabled
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 9.0,
                                                    horizontal: 9.0),
                                          ),
                                          controller: discountAmountController,
                                          onChanged: (value) {
                                            if (gstType == 'Including') {
                                              calculateDiscountPercentageInclude();
                                            } else if (gstType == 'Excluding') {
                                              calculateDiscountPercentageExclude();
                                            } else if (gstType == 'NonGst') {
                                              calculateDisPercentNongst();
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'RS.',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                              width:
                                                  5), // Space before the vertical line
                                          Container(
                                            width:
                                                1, // Width of the vertical line
                                            height:
                                                30, // Height of the vertical line
                                            color: Colors
                                                .black, // Color of the vertical line
                                          ),
                                          SizedBox(
                                              width:
                                                  6), // Space after the vertical line
                                          Text(
                                            '${fitchfinalAmountController.text.isEmpty ? NumberFormat.currency(
                                                locale: 'en_IN',
                                                symbol: '₹',
                                              ).format(totalAmount) : fitchfinalAmountController.text}/-',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 40),
                            Container(
                              width: 100,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selectedPaymentType == "Credit" &&
                                      cusNameController.text.isEmpty) {
                                    showAlert(context,
                                        "Customer name is required for credit payment type.");
                                    return;
                                  }
                                  await postSerialNumber();
                                  if (!(selectedPaymentType == "Credit")) {
                                    await incomeDetails();
                                  }
                                  String paidAmount =
                                      selectedPaymentType.toLowerCase() ==
                                              'credit'
                                          ? '0.0'
                                          : finalAmount.toStringAsFixed(2);

                                  await saveDetails(context, paidAmount);
                                  setState(() {
                                    // Reset the form fields
                                    tableNumberController.clear();
                                    itemsController.clear();
                                    discountAmountController.clear();
                                    finalAmountController.clear();
                                    scodeController.clear();
                                    cusNameController.clear();
                                    contactController.clear();
                                    discountPercentageController.clear();
                                    taxAmountController.clear();
                                    finalTaxableAmountController.clear();
                                    addressController.clear();
                                    selectedProducts
                                        .clear(); // Deselect products
                                    servantNames.clear();
                                    paymentTypes.clear();
                                  });
                                },
                                focusNode: _saveDetailsFocusNode,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue, // Text color
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15), // Padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
                                  ),
                                ),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ]),
                    ),
                  ),
                )
              ]),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),
      body: _buildSelectedProductDetails(), // Call the method here
    );
  }
}
