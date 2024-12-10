import 'package:ProductRestaurant/Reports/Purchase/PurchaseReport.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(IncomeEntry());
}

class IncomeEntry extends StatefulWidget {
  @override
  State<IncomeEntry> createState() => _IncomeEntryState();
}

class _IncomeEntryState extends State<IncomeEntry> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  @override
  void initState() {
    super.initState();
    fetchIncomeDetails();
    _AmountController.text = "0.0";
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchIncomeDetails();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchIncomeDetails();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['description'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  String? selectedAmount;
  String? selectedproduct;
  Future<void> fetchIncomeDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/IncomeEntryDetail/$cusid/?page=$currentPage&size=$pageSize';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        tableData = results;
        // You might need to adjust the key names based on your actual API response
        hasNextPage = jsonData['next'] != null;
        hasPreviousPage = jsonData['previous'] != null;
        int totalCount = jsonData['count'];
        totalPages = (totalCount + pageSize - 1) ~/ pageSize;
      });
    }
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var data in tableData) {
      total += double.parse(data['amount'].toString());
    }
    return total;
  }

  void setState(VoidCallback fn) {
    super.setState(fn);
    totalAmount = calculateTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> filteredData;
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
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income Entry',
                        style: HeadingStyle,
                      ),
                      SizedBox(height: 15),
                      _buildContainer(),
                      SizedBox(height: 15),
                      Container(
                        height: Responsive.isDesktop(context)
                            ? screenHeight * 0.8
                            : 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Income',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                SizedBox(),
                                Text(
                                  totalAmount.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Income',
                                suffixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: getFilteredData().isNotEmpty
                                      ? getFilteredData().map((data) {
                                          var dt = data['dt'].toString();
                                          var description =
                                              data['description'].toString();
                                          var amount =
                                              data['amount'].toString();

                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border(
                                                left: BorderSide(
                                                  color: Colors.green,
                                                  width: 5,
                                                ),
                                                top: BorderSide(
                                                  color: Colors.green,
                                                  width: 2,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.green,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                    radius: 15.0,
                                                    child: Image.asset(
                                                        'assets/imgs/receive-1.png')),
                                                SizedBox(width: 20),
                                                Expanded(
                                                    child: Text(dt,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black87))),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text(description,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black54))),
                                                SizedBox(width: 10),
                                                Expanded(
                                                    child: Text(amount,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black87))),
                                              ],
                                            ),
                                          );
                                        }).toList()
                                      : [
                                          Text('No data available',
                                              style:
                                                  TextStyle(color: Colors.grey))
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_left),
                              onPressed: hasPreviousPage
                                  ? () => loadPreviousPage()
                                  : null,
                            ),
                            SizedBox(width: 5),
                            Text('$currentPage / $totalPages',
                                style: commonLabelTextStyle),
                            SizedBox(width: 5),
                            IconButton(
                              icon: Icon(Icons.keyboard_arrow_right),
                              onPressed:
                                  hasNextPage ? () => loadNextPage() : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _AmountController = TextEditingController();
  TextEditingController _DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  void _saveDataToAPI() async {
    String? description = _descriptionController.text;
    String? amount = _AmountController.text;

    if (description == null || description.isEmpty) {
      WarninngMessage(context);
      _descriptionController.text = "";

      _descriptionFocusNode.requestFocus();

      return;
    }
    if (amount == "0.0" || amount.isEmpty) {
      WarninngMessage(context);
      _AmountController.text = "0.0";

      _amountFocusNode.requestFocus();

      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/IncomeEntryDetailalldatas/';
    Map<String, dynamic> postData = {
      "cusid": cusid,
      'dt': _DateController.text,
      'description': description,
      'amount': amount,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(postData),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        // Check if the widget is still mounted before updating the state
        if (response.statusCode == 201) {
          print('Data saved successfully');
          await logreports("Income Entry: Description-${description}_Inserted");
          fetchIncomeDetails();
          successfullySavedMessage(context);
          _descriptionController.text = "";
          _AmountController.text = "0.0";

          _descriptionFocusNode.requestFocus();
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
          // print('Response content: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error as needed
    }
  }

  void showIncomeEmptyWarning() {
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
                'Kindly check your income details.!!!',
                style: TextStyle(fontSize: 13, color: maincolor),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  FocusNode buttonFocusNode = FocusNode();
  Widget _buildContainer() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                _buildDescTextField("Description"),
                SizedBox(width: 10),
                _buildAmountTextField("Amount"),
                SizedBox(width: 10),
                _buildDateTimePickerField("Date"),
                SizedBox(width: 10),
                ElevatedButton(
                  focusNode: buttonFocusNode,
                  onPressed: () {
                    _saveDataToAPI();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: Size(75.0, 28.0),
                  ),
                  child: Text('Add', style: commonWhiteStyle),
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildDescTextField("Description"),
                    SizedBox(width: 5),
                    _buildAmountTextField("Amount"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildDateTimePickerField("Date"),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: ElevatedButton(
                        focusNode: buttonFocusNode,
                        onPressed: () {
                          _saveDataToAPI();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(25.0, 23.0), // Set width and height
                        ),
                        child: Text('Add', style: commonWhiteStyle),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  FocusNode _amountFocusNode = FocusNode();

  Widget _buildAmountTextField(String label) {
    return Container(
      width: Responsive.isDesktop(context) ? 180 : 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: Responsive.isDesktop(context) ? 180 : 150,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _AmountController,
              focusNode: _amountFocusNode,
              onSubmitted: (_) =>
                  _fieldFocusChange(context, _amountFocusNode, DateFocusNode),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  size: 18,
                  color: Colors.black,
                ),
                labelText: label,
                labelStyle: commonLabelTextStyle.copyWith(
                  color: const Color.fromARGB(255, 116, 116, 116),
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
              style: AmountTextStyle,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ],
      ),
    );
  }

  FocusNode _descriptionFocusNode = FocusNode();

  Widget _buildDescTextField(String label) {
    return Container(
      width: Responsive.isDesktop(context) ? 180 : 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: Responsive.isDesktop(context) ? 180 : 150,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
                focusNode: _descriptionFocusNode,
                onSubmitted: (_) => _fieldFocusChange(
                    context, _descriptionFocusNode, _amountFocusNode),
                controller: _descriptionController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.description,
                    size: 18,
                    color: Colors.black,
                  ),
                  labelText: label,
                  labelStyle: commonLabelTextStyle.copyWith(
                    color: const Color.fromARGB(255, 116, 116, 116),
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
                style: textStyle),
          ),
        ],
      ),
    );
  }

  late DateTime selectedDate;
  FocusNode DateFocusNode = FocusNode();

  Widget _buildDateTimePickerField(String label) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;
    return Container(
      // color: Subcolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35, // Adjust height for proper alignment
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              borderRadius:
                  BorderRadius.circular(6), // Optional: make the border rounded
            ),

            width: Responsive.isDesktop(context)
                ? 180 // Width for desktop
                : MediaQuery.of(context).size.width * 0.42,
            child: Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  size: 15,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      height: isDesktop ? 2 : 10,
                      width: 100,
                      color: Colors.grey[200],
                      child: DateTimePicker(
                        focusNode: DateFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _fieldFocusChange(
                            context, DateFocusNode, buttonFocusNode),
                        initialValue: DateTime.now().toString(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        dateLabelText: '',
                        onChanged: (val) => print(val),
                        validator: (val) {
                          print(val);
                          return null;
                        },
                        onSaved: (val) => print(val),
                        style: textStyle, // Font size can be adjusted as needed
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
