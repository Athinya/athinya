import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'dart:convert';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(ExpenseCategory());
}

class ExpenseCategory extends StatefulWidget {
  @override
  State<ExpenseCategory> createState() => _ExpenseCategoryState();
}

class _ExpenseCategoryState extends State<ExpenseCategory> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';
  final TextEditingController _categoryController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) => (data['name'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return filteredData;
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/ExpenseCat/$cusid';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> catlist = [];

      for (var item in data) {
        int catID = item['id'];
        String catName = item['name'];

        catlist.add({
          'id': catID,
          'name': catName,
        });
      }

      // Sort the data by 'id' in ascending order
      catlist.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        tableData = catlist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expense Category', style: HeadingStyle),
                      SizedBox(height: 30),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              _buildTextField(),
                              SizedBox(width: 8),
                              _buildAddButton(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: Responsive.isDesktop(context)
                            ? screenHeight * 0.8
                            : 420,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (getFilteredData().isNotEmpty)
                                      ...getFilteredData().map((data) {
                                        var id = data['id'].toString();
                                        var name = data['name'].toString();

                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color:
                                                        Colors.grey.shade300)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 12.0,
                                                  child: Image.asset(
                                                      'assets/imgs/category.png')),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Text(name,
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  _showDeleteConfirmationDialog(
                                                      data);
                                                },
                                                tooltip: "Delete this entry",
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
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

  Future<bool?> _showDeleteConfirmationDialog(Map<String, dynamic> data) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Delete', style: commonLabelTextStyle),
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
                style: textStyle,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _deleteData(data['id']);
                Navigator.of(context).pop(true);
                successfullyDeleteMessage(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Delete', style: commonWhiteStyle),
            ),
          ],
        );
      },
    );
  }

  void successfullyDeleteMessage(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Successfully Deleted..!!',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  void _deleteData(int id) async {
    // Make API request to delete the data
    String apiUrl = '$IpAddress/ExpenseCatalldata/$id/';

    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    print('Delete Request: $apiUrl');
    print('Delete Response Status Code: ${response.statusCode}');
    print('Delete Response Body: ${response.body}');

    if (response.statusCode == 204) {
      // Successfully deleted data, you can handle the response accordingly
      print('Data deleted successfully');
      // Fetch updated data
      fetchData();
    } else {
      // Handle error in deleting data
      print('Failed to delete data. Status code: ${response.statusCode}');
      // You may want to display an error message to the user
    }
  }

  Widget _buildTextField() {
    return Container(
      width: 150,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Name',
            style: commonLabelTextStyle,
          ),
          SizedBox(height: 8),
          Container(
            width: 150,
            child: Container(
              height: 27,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: TextFormField(
                key: Key('category'), // Add a key
                onFieldSubmitted: (_) {
                  addExpenseCategory();
                }, // Set autofocus to true
                controller: _categoryController,
                focusNode: _categoryFocusNode,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 7.0,
                  ),
                ),
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Padding(
      padding: EdgeInsets.only(top: isDesktop ? 25.0 : 20.0),
      child: ElevatedButton(
        onPressed: () {
          addExpenseCategory();
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          backgroundColor: subcolor,
          minimumSize: Size(35.0, 28.0),
        ),
        child: Text(
          'Save',
          style: commonWhiteStyle,
        ),
      ),
    );
  }

  FocusNode _categoryFocusNode = FocusNode();

  Future<void> addExpenseCategory() async {
    String? category = _categoryController.text;
// Check if paymentType is empty
    if (category == null || category.isEmpty) {
      WarninngMessage(context);
      _categoryController.text = "";

      // Set focus on the _categoryController
      _categoryFocusNode.requestFocus();

      return;
    }

    if (isCategoryAlreadyAdded(category)) {
      // Display a warning message
      showDuplicateCategoryWarning();
      _categoryController.text = "";
      _categoryFocusNode.requestFocus();

      return; // Stop further execution
    }
    String apiUrl = '$IpAddress/ExpenseCatalldata/';

    String? cusid = await SharedPrefs.getCusId();
    // Replace the following with the actual data you want to add
    Map<String, dynamic> data = {
      "cusid": cusid,
      'name': category,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // Successfully added, fetch updated data
      await logreports("Expense Category: ${category}_Inserted");
      successfullySavedMessage(context);
      fetchData();
      _categoryController.text = "";
      _categoryFocusNode.requestFocus();
    } else {
      // Handle error
      print(
          'Failed to add expense category. Status code: ${response.statusCode}');
    }
  }

  bool isCategoryAlreadyAdded(String? paymentType) {
    return tableData.any((data) => data['name'] == paymentType);
  }

  void showDuplicateCategoryWarning() {
    showDialog(
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
                    'Category already exists..!!',
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
}
