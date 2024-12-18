import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Settings/AddProductsDetails.dart';
import 'package:ProductRestaurant/Settings/StaffDetails.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

final _formKey = GlobalKey<FormState>();

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        String? role = await getrole();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => sidebar(
                    onItemSelected: (content) {},
                    settingsproductcategory:
                        role == 'admin' ? true : settingsproductcategory,
                    settingsproductdetails:
                        role == 'admin' ? true : settingsproductdetails,
                    settingsgstdetails:
                        role == 'admin' ? true : settingsgstdetails,
                    settingsstaffdetails:
                        role == 'admin' ? true : settingsstaffdetails,
                    settingspaymentmethod:
                        role == 'admin' ? true : settingspaymentmethod,
                    settingsaddsalespoint:
                        role == 'admin' ? true : settingsaddsalespoint,
                    settingsprinterdetails:
                        role == 'admin' ? true : settingsprinterdetails,
                    settingslogindetails:
                        role == 'admin' ? true : settingslogindetails,
                    purchasenewpurchase:
                        role == 'admin' ? true : purchasenewpurchase,
                    purchaseeditpurchase:
                        role == 'admin' ? true : purchaseeditpurchase,
                    purchasepaymentdetails:
                        role == 'admin' ? true : purchasepaymentdetails,
                    purchaseproductcategory:
                        role == 'admin' ? true : purchaseproductcategory,
                    purchaseproductdetails:
                        role == 'admin' ? true : purchaseproductdetails,
                    purchaseCustomer: role == 'admin' ? true : purchaseCustomer,
                    salesnewsales: role == 'admin' ? true : salesnewsale,
                    saleseditsales: role == 'admin' ? true : saleseditsales,
                    salespaymentdetails:
                        role == 'admin' ? true : salespaymentdetails,
                    salescustomer: role == 'admin' ? true : salescustomer,
                    salestablecount: role == 'admin' ? true : salestablecount,
                    quicksales: role == 'admin' ? true : quicksales,
                    ordersalesnew: role == 'admin' ? true : ordersalesnew,
                    ordersalesedit: role == 'admin' ? true : ordersalesedit,
                    ordersalespaymentdetails:
                        role == 'admin' ? true : ordersalespaymentdetails,
                    vendorsalesnew: role == 'admin' ? true : vendorsalesnew,
                    vendorsalespaymentdetails:
                        role == 'admin' ? true : vendorsalespaymentdetails,
                    vendorcustomer: role == 'admin' ? true : vendorcustomer,
                    stocknew: role == 'admin' ? true : stocknew,
                    wastageadd: role == 'admin' ? true : wastageadd,
                    kitchenusagesentry:
                        role == 'admin' ? true : kitchenusagesentry,
                    report: role == 'admin' ? true : report,
                    daysheetincomeentry:
                        role == 'admin' ? true : daysheetincomeentry,
                    daysheetexpenseentry:
                        role == 'admin' ? true : daysheetexpenseentry,
                    daysheetexepensescategory:
                        role == 'admin' ? true : daysheetexepensescategory,
                    graphsales: role == 'admin' ? true : graphsales,
                  )),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Add Stock",
                                    style: HeadingStyle,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 60,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Responsive.isDesktop(context)
                            ? Row(children: [
                                Expanded(flex: 4, child: RightWidget(context)),
                                Expanded(flex: 8, child: LeftWidget(context))
                              ])
                            : Column(children: [
                                RightWidget(context),
                                LeftWidget(context)
                              ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? selectedValue;
  String? selectedproduct;
  TextEditingController _qtyController = TextEditingController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAllProductName();
    fetchEmployeeName();
    fetchStockRecordNo();
    fetchProductDetails();
    // fetchLastSno();
    _qtyController.text = "0";

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchStockRecordNo();
    });
    _timer?.cancel();
  }

  TextEditingController RecordnoController = TextEditingController();
  TextEditingController _DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

  late DateTime selectedDate;

  FocusNode DateFocus = FocusNode();

  Future<void> fetchStockRecordNo() async {
    String? cusid = await SharedPrefs.getCusId();
    final response = await http.get(Uri.parse('$IpAddress/Stock_Sno/$cusid/'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      int currentPayno = jsonData['serialno'];
      // Add 1 to the current payno
      int nextPayno = currentPayno + 1;
      setState(() {
        RecordnoController.text = nextPayno.toString();
      });
      // print("Purchase RecordNo : $PurchasePaymentRecordNo");
    } else {
      throw Exception('Failed to load serial number');
    }
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    int incrementedSerialNo = int.parse(
      RecordnoController.text,
    );

    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "serialno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse('$IpAddress/Stock_Snoalldata/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Data posted successfully');
        fetchStockRecordNo();
      } else {
        print('Failed to post data. Error code: ${response.statusCode}');
        print('Response body: ${response.body}');
        fetchStockRecordNo();
      }
    } catch (e) {
      // print('Failed to post data. Error: $e');
    }
  }

  Widget RightWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isDesktop(context) ? 15 : 40,
        vertical: 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 250, 247, 247),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isDesktop(context) ? 40 : 30,
            vertical: 25,
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            runSpacing: Responsive.isDesktop(context) ? 17 : 10,
            children: [
              _buildRecordNumber(),
              _buildEmployeeName(),
              _buildDate(),
              _buildProductName(),
              _buildQuantity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record No',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    RecordnoController.text,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  ShowBillnoIncreaeMessage();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: subcolor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "+",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: EmployeeDropdown()),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: Responsive.isDesktop(context) ? 1300 : 300,
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              Container(
                                width: 1500,
                                height: 800,
                                child: StaffDetailsPage(),
                              ),
                              Positioned(
                                right: 10.0,
                                top: 5.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchEmployeeName();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black54),
              SizedBox(width: 10),
              Expanded(
                child: DateTimePicker(
                  onFieldSubmitted: (_) =>
                      _fieldFocusChange(context, DateFocus, ProdNameFocus),
                  focusNode: DateFocus,
                  controller: _DateController,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  onChanged: (val) {
                    selectedDate = DateTime.parse(val);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: ProductNamedropdown()),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: Responsive.isDesktop(context) ? 1300 : 300,
                          padding: EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              Container(
                                width: 1500,
                                height: 800,
                                child: AddProductDetailsPage(),
                              ),
                              Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchAllProductName();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onSubmitted: (value) {
                    _AddTabledata();
                  },
                  keyboardType: TextInputType.number,
                  controller: _qtyController,
                  focusNode: _qtyfocus,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _AddTabledata,
              style: ElevatedButton.styleFrom(
                backgroundColor: subcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: Size(50, 40),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  FocusNode _qtyfocus = FocusNode();
  void _AddTabledata() async {
    setState(() {
      String? qty = _qtyController.text;
      if (ProductCategoryController.text == "" ||
          _employeeController.text == "") {
        showEmptyWarning();
        return;
      }
      if (qty.isEmpty || qty == "0") {
        showQuantityWarning();
        _qtyfocus.requestFocus();
        return;
      }
      tableData.add({
        'prodname': ProductCategoryController.text,
        'qty': _qtyController.text,
      });
      ProductCategoryController.text = "";
      _qtyController.text = "0";
    });
  }

  void _deleteTableData(int index) {
    setState(() {
      if (index >= 0 && index < tableData.length) {
        tableData.removeAt(index);
      }
    });
  }

  void showEmptyWarning() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.yellowAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kindly check your stock detailss..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void showQuantityWarning() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.yellow, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.yellowAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.yellow, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kindly check your stock qty..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void _saveStockDetailsAndRoundToAPI() async {
    if (tableData.isEmpty || _employeeController.text.isEmpty) {
      showEmptyWarning();
      return;
    }

    List<Map<String, dynamic>> StockDetailsData = [];
    String RecordNo = RecordnoController.text;
    Set<String> uniqueItems = Set<String>();

    for (var i = 0; i < tableData.length; i++) {
      var rowData = tableData[i];

      String productName = rowData['prodname'];
      int qty = int.tryParse(rowData['qty'].toString()) ?? 0;

      // Add the product name to the set of unique items
      uniqueItems.add(productName);

      StockDetailsData.add({
        'serialno': RecordNo,
        'agentname': _employeeController.text,
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
      'agentname': _employeeController.text,
      'itemcount': itemCount.toString(), // Use the count of unique items
      'status': 'ManualStock',
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

          await logreports('Stock Entry: ${_employeeController.text}_Inserted');
          successfullySavedMessage(context);
          postDataWithIncrementedSerialNo();
          _employeeController.clear();
          _qtyController.text = "0";
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<String> ProductCategoryList = [];

  Future<void> fetchAllProductName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/Settings_ProductDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductCategoryList.addAll(
              results.map<String>((item) => item['name'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      //  print('All product categories: $ProductCategoryList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController ProductCategoryController = TextEditingController();
  String? selectedProductName;
  FocusNode ProdNameFocus = FocusNode();

  int? _selectedProdIndex;
  bool _ProdNamefilterEnabled = true;
  int? _ProdNamehoveredIndex;

  Widget ProductNamedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex < ProductCategoryList.length - 1) {
              setState(() {
                _selectedProdIndex = currentIndex + 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex + 1];
                _ProdNamefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductCategoryList.indexOf(ProductCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProdIndex = currentIndex - 1;
                ProductCategoryController.text =
                    ProductCategoryList[currentIndex - 1];
                _ProdNamefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: ProdNameFocus,
          onSubmitted: (_) =>
              _fieldFocusChange(context, ProdNameFocus, _qtyfocus),
          controller: ProductCategoryController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.fastfood,
              size: 18,
              color: Colors.black,
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 7.0,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _ProdNamefilterEnabled = true;
              selectedProductName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_ProdNamefilterEnabled && pattern.isNotEmpty) {
            return ProductCategoryList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ProductCategoryList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ProductCategoryList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _ProdNamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _ProdNamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProdIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProdIndex == null &&
                          ProductCategoryList.indexOf(
                                  ProductCategoryController.text) ==
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
            ProductCategoryController.text = suggestion!;
            selectedProductName = suggestion;
            _ProdNamefilterEnabled = false;
            FocusScope.of(context).requestFocus(_qtyfocus);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  void clearProductSelection() {
    setState(() {
      selectedProductName = null;
      ProductCategoryController.clear();
    });
  }

  List<String> EmployeeNameList = [];

  Future<void> fetchEmployeeName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/StaffDetails/$cusid';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          EmployeeNameList.addAll(
              results.map<String>((item) => item['serventname'].toString()));

          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            url = data['next'];
          }
        } else {
          throw Exception(
              'Failed to load categories: ${response.reasonPhrase}');
        }
      }

      //   print('All product categories: $EmployeeNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController _employeeController = TextEditingController();
  String? selectedEmployeeName;
  FocusNode EmployeeFocus = FocusNode();

  int? _selectedEmpIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget EmployeeDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                EmployeeNameList.indexOf(_employeeController.text);
            if (currentIndex < EmployeeNameList.length - 1) {
              setState(() {
                _selectedEmpIndex = currentIndex + 1;
                _employeeController.text = EmployeeNameList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                EmployeeNameList.indexOf(_employeeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedEmpIndex = currentIndex - 1;
                _employeeController.text = EmployeeNameList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: EmployeeFocus,
          controller: _employeeController,
          onSubmitted: (_) =>
              _fieldFocusChange(context, EmployeeFocus, DateFocus),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              size: 18,
              color: Colors.black,
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 7.0,
            ),
          ),
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _filterEnabled = true;
              selectedEmployeeName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return EmployeeNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return EmployeeNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = EmployeeNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedEmpIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedEmpIndex == null &&
                          EmployeeNameList.indexOf(_employeeController.text) ==
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
        onSuggestionSelected: (suggestion) {
          setState(() {
            _employeeController.text = suggestion;
            selectedEmployeeName = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(DateFocus);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  void ShowBillnoIncreaeMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.question_mark_rounded,
                color: maincolor,
              ),
              SizedBox(width: 10), // Spacing between icon and text
              Expanded(
                child: Text(
                  'Do you want to increase your addstock bill number?',
                  style: textStyle.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    postDataWithIncrementedSerialNo();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize:
                        Size(50.0, 30.0), // Adjust size for better look
                  ),
                  child: Text('Yes',
                      style: TextStyle(color: sidebartext, fontSize: 12)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize:
                        Size(50.0, 30.0), // Adjust size for better look
                  ),
                  child: Text('No',
                      style: TextStyle(color: sidebartext, fontSize: 12)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['prodname'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  Widget LeftWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Responsive.isDesktop(context) ? 15 : 10,
        right: Responsive.isDesktop(context) ? 15 : 10,
        bottom: 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  child: Text(
                    "No.Of.Product:",
                    style: textStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                  ),
                  child: Container(
                    width: Responsive.isDesktop(context) ? 70 : 70,
                    child: Container(
                      height: 27,
                      width: 100,
                      // color: Colors.grey[200],
                      child: Text(
                        tableData.length.toString(),
                        style: commonLabelTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  child: Container(
                    height: 30,
                    width: 130,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        contentPadding: EdgeInsets.only(left: 10.0, right: 4.0),
                      ),
                      style: textStyle,
                    ),
                  ),
                ),
              ],
            ),
            tableView(context),
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _saveStockDetailsAndRoundToAPI();
                                _printResult();
                                tableData.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                backgroundColor: subcolor,
                                minimumSize: Size(45.0, 31.0),
                              ),
                              child: Text(
                                'Save',
                                style: commonWhiteStyle,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tableData.clear();
                                  _employeeController.text = "";
                                  selectedEmployeeName = "";
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                backgroundColor: subcolor,
                                minimumSize: Size(45.0, 31.0),
                              ),
                              child: Text(
                                'Refresh',
                                style: commonWhiteStyle,
                              ),
                            ),
                          ],
                        )
                      ],
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

  Map<String, Uint8List?> productImages = {};

  Future<void> fetchProductDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    bool hasNextPage = true;
    List<dynamic> allFetchedItems = [];

    try {
      String apiUrl = '$IpAddress/Settings_ProductDetails/$cusid/';
      while (hasNextPage) {
        http.Response response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          dynamic fetchedItems = data['results'];

          if (fetchedItems is List) {
            allFetchedItems.addAll(fetchedItems);

            for (var item in fetchedItems) {
              String name = item['name'] ?? 'Unknown';
              String? base64Image = item['image'];

              Uint8List? imageBytes;
              if (base64Image != null && base64Image.isNotEmpty) {
                imageBytes = base64Decode(base64Image);
                print('Fetched image for $name');
              } else {
                print('No image for $name');
                imageBytes = null;
              }

              productImages[name] = imageBytes;
            }

            setState(() {});
          } else {
            print('Expected a List, but received: $fetchedItems');
          }
          hasNextPage = data['next'] != null;
          if (hasNextPage) {
            apiUrl = data['next'];
          }
        } else {
          print(
              'Failed to fetch product details. Status code: ${response.statusCode}');
          break;
        }
      }

      print('Total items fetched: ${allFetchedItems.length}');
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  Widget tableView(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: Responsive.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Container(
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.60
              : MediaQuery.of(context).size.width * 0.90,
          height: Responsive.isDesktop(context)
              ? screenHeight * 0.65
              : MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            color: Color(0xFFECE9E6),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stock Details', style: HeadingStyle),
                  SizedBox(height: 20),
                  if (getFilteredData().isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: getFilteredData().length,
                      itemBuilder: (context, index) {
                        var data = getFilteredData()[index];
                        var productName = data['prodname'];
                        var qty = data['qty']!;
                        return _buildProductRow(productName, qty, index);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(String productName, String qty, int index) {
    Uint8List? imageBytes = productImages[productName];

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage:
                    imageBytes != null ? MemoryImage(imageBytes!) : null,
                child: imageBytes == null
                    ? Icon(Icons.image, size: 20.0, color: Colors.grey)
                    : null,
              ),
              Text(
                productName,
                style: commonLabelTextStyle,
              ),
              Text(
                'Qty: $qty',
                style: textStyle,
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey, size: 24),
                onPressed: () {
                  _deleteTableData(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  TextEditingController billnoController = TextEditingController(text: '1');
  Future<void> _printResult() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime currentDatetime = DateTime.now();
      String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);
      String formattedDateTime = DateFormat('hh:mm a').format(currentDatetime);
      String billno = billnoController.text;
      String date = formattedDate;
      String? addby = selectedEmployeeName;
      String time = formattedDateTime;
      String count = tableData.length.toString();

      List<String> productDetails = [];
      for (var data in tableData) {
        // Format each product detail as "{productName},{amount}"
        productDetails.add("${data['prodname']}-${data['qty']}");
      }

      String productDetailsString = productDetails.join(',');
      // print("product details : $productDetailsString   ");
      // print(
      //     "billno : $billno   , date : $date ,  paytype : $paytype ,    time :$time    ,customername : $Customername,  customercontact : $CustomerContact  ,    table No : $Tableno,   Tableservent : $tableservent,    total count :  $count,  total qty : $totalQty,    totalamt : $totalamt,    discount amt : $discount,    finalamount:  $FinalAmt");
      // print(
      //     "url : http://127.0.0.1:8000/StockAddedPrint3Inch/$billno-$date-$addby-$time/$count/$productDetailsString");

      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/StockAddedPrint3Inch/$billno-$date-$addby-$time/$count/$productDetailsString'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, print the response body.
        print('Response: ${response.body}');
      } else {
        // If the server did not return a 200 OK response, print the status code.
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any potential errors.
      print('Error: $e');
    }
  }
}
