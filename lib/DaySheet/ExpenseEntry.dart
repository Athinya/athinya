import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

void main() {
  runApp(ExpenseEntry());
}

class ExpenseEntry extends StatefulWidget {
  @override
  State<ExpenseEntry> createState() => _ExpenseEntryState();
}

class _ExpenseEntryState extends State<ExpenseEntry> {
  @override
  void initState() {
    super.initState();
    fetchExpenseDetails();
    fetchExpenseCategory();
    fetchPaytype();
    amountController.text = "0.0";
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  String searchText = '';
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchExpenseDetails();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchExpenseDetails();
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
  Future<void> fetchExpenseDetails() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl =
        '$IpAddress/ExpenseEntryDetail/$cusid/?page=$currentPage&size=$pageSize';
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
    bool isDesktop = MediaQuery.of(context).size.width > 768;
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
                        'Expense Entry',
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense Overview',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Expense:',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.redAccent),
                                  ),
                                  Text(
                                    totalAmount.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search Expenses...',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon:
                                      Icon(Icons.search, color: Colors.red),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Displaying each expense as a card
                              if (getFilteredData().isNotEmpty)
                                ...getFilteredData().map((data) {
                                  return _buildExpenseCard(data);
                                }).toList()
                              else
                                Center(
                                    child: Text('No expenses found',
                                        style: TextStyle(color: Colors.grey))),
                            ],
                          ),
                        ),
                      ),

// Build individual expense card
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
                            Text(
                              '$currentPage / $totalPages',
                              style: commonLabelTextStyle,
                            ),
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

  Widget _buildExpenseCard(Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border(
            left: BorderSide(
              color: Colors.red,
              width: 5,
            ),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['cat'].toString(),
                    style: HeadingStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.currency_rupee,
                  color: Colors.red,
                  size: 28,
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['description'].toString(), style: textStyle),
                Text(data['amount'].toString(), style: AmountTextStyle),
              ],
            ),
            SizedBox(height: 5),
            Text(data['dt'].toString(), style: textStyle),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['type'].toString(), style: textStyle),
                CircleAvatar(
                    radius: 25.0,
                    child: Image.asset('assets/imgs/cash-on-delivery.png')),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  FocusNode ButtonFocus = FocusNode();
  Widget _buildContainer() {
    return Column(
      children: [
        if (Responsive.isDesktop(context))
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                _buildCategoryDropdown("Category"),
                SizedBox(width: 8),
                _buildDescTextField("Description"),
                SizedBox(width: 8),
                _buildAmountTextField("Amount"),
                SizedBox(width: 8),
                _buildDateTimePickerField("Date"),
                SizedBox(width: 8),
                _buildPayTypeDropdown('Paytype'),
                SizedBox(width: 8),
                ElevatedButton(
                  focusNode: ButtonFocus,
                  onPressed: () {
                    _saveDataToAPI();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: Size(35.0, 28.0),
                  ),
                  child: Text('Add', style: commonWhiteStyle),
                ),
              ],
            ),
          ),
        if (Responsive.isMobile(context))
          Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCategoryDropdown("Category"),
                      SizedBox(width: 5),
                      _buildDescTextField("Description"),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    _buildAmountTextField("Amount"),
                    SizedBox(width: 5),
                    _buildDateTimePickerField("Date"),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    _buildPayTypeDropdown('Paytype'),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveDataToAPI();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          backgroundColor: subcolor,
                          minimumSize: Size(35.0, 28.0), // Set width and height
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

  TextEditingController ExpenseCategoryController = TextEditingController();

  Widget _buildCategoryDropdown(String label) {
    return Container(
      width: Responsive.isDesktop(context) ? 170 : 150,
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
              child: ExpenseCategoryDropdown()),
        ],
      ),
    );
  }

  Widget _buildPayTypeDropdown(String label) {
    return Container(
      width: Responsive.isDesktop(context) ? 170 : 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 40,
              width: Responsive.isDesktop(context) ? 170 : 150,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Paymenttypedropdown()),
        ],
      ),
    );
  }

  TextEditingController amountController = TextEditingController();
  FocusNode AmountFocus = FocusNode();

  Widget _buildAmountTextField(String label) {
    return Container(
      width: Responsive.isDesktop(context) ? 170 : 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.isDesktop(context) ? 180 : 150,
            child: Container(
              height: 40,
              width: 150,
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
                controller: amountController,
                focusNode: AmountFocus,
                onSubmitted: (_) =>
                    _fieldFocusChange(context, AmountFocus, DateFocus),
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
          ),
        ],
      ),
    );
  }

  TextEditingController _descriptionController = TextEditingController();
  FocusNode DescriptionFocus = FocusNode();

  Widget _buildDescTextField(String label) {
    return Container(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.isDesktop(context)
                ? 180
                : MediaQuery.of(context).size.width * 0.4,
            child: Container(
              height: 40,
              width: 150,
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
                  focusNode: DescriptionFocus,
                  onSubmitted: (_) =>
                      _fieldFocusChange(context, DescriptionFocus, AmountFocus),
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
          ),
        ],
      ),
    );
  }

  FocusNode DateFocus = FocusNode();
  late DateTime selectedDate;
  TextEditingController _DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  Widget _buildDateTimePickerField(String label) {
    bool isDesktop = MediaQuery.of(context).size.width > 768;
    return Container(
      // color: Subcolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40, // Adjust height for proper alignment
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
                ? 170 // Width for desktop
                : MediaQuery.of(context).size.width * 0.40,
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
                      height: isDesktop ? 2 : 12,
                      width: 100,
                      color: Colors.grey[200],
                      child: DateTimePicker(
                        focusNode: DateFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _fieldFocusChange(context, DateFocus, PaytypeFocus),
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

  List<String> ExpenseCategoryList = [];

  Future<void> fetchExpenseCategory() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/ExpenseCat/$cusid';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      ExpenseCategoryList.addAll(
          data.map<String>((item) => item['name'].toString()));

      setState(() {
        ExpenseCategoryList;
      });
    }
  }

  String? selectedExpenseCategory;

  FocusNode ExpeCategoryFocus = FocusNode();

  bool _filterEnabled = true;
  int? _selectedExpIndex;
  int? _hoveredIndex;
  Widget ExpenseCategoryDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ExpenseCategoryList.indexOf(ExpenseCategoryController.text);
            if (currentIndex < ExpenseCategoryList.length - 1) {
              setState(() {
                _selectedExpIndex = currentIndex + 1;
                ExpenseCategoryController.text =
                    ExpenseCategoryList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ExpenseCategoryList.indexOf(ExpenseCategoryController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedExpIndex = currentIndex - 1;
                ExpenseCategoryController.text =
                    ExpenseCategoryList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: ExpenseCategoryController,
          onSubmitted: (_) =>
              _fieldFocusChange(context, ExpeCategoryFocus, DescriptionFocus),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.category,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'Category',
            labelStyle: commonLabelTextStyle.copyWith(
              color: const Color.fromARGB(255, 116, 116, 116),
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
              selectedExpenseCategory = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return ExpenseCategoryList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return ExpenseCategoryList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = ExpenseCategoryList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedExpIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedExpIndex == null &&
                          ExpenseCategoryList.indexOf(
                                  ExpenseCategoryController.text) ==
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
            ExpenseCategoryController.text = suggestion;
            selectedExpenseCategory = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(DescriptionFocus);
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

  List<String> PaytypeList = [];

  Future<void> fetchPaytype() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PaymentMethod/$cusid';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<String> fetchedPaytypes = [];

      for (var item in data) {
        String paytype = item['paytype'];
        fetchedPaytypes.add(paytype);
      }

      setState(() {
        PaytypeList = fetchedPaytypes;
      });
    }
  }

  TextEditingController _PaytypeController = TextEditingController();
  String? selectedPaytype;
  FocusNode PaytypeFocus = FocusNode();
  bool _PayTypefilterEnabled = true;
  int? _PayTypehoveredIndex;
  int? _selectedPayTypeIndex;

  Widget Paymenttypedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = PaytypeList.indexOf(_PaytypeController.text);
            if (currentIndex < PaytypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                _PaytypeController.text = PaytypeList[currentIndex + 1];
                _PayTypefilterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = PaytypeList.indexOf(_PaytypeController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                _PaytypeController.text = PaytypeList[currentIndex - 1];
                _PayTypefilterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PaytypeFocus,
          controller: _PaytypeController,
          onSubmitted: (_) =>
              _fieldFocusChange(context, PaytypeFocus, ButtonFocus),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.payment,
              size: 18,
              color: Colors.black,
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'Payment Type',
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
          style: DropdownTextStyle,
          onChanged: (text) {
            setState(() {
              _PayTypefilterEnabled = true;
              selectedPaytype = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_PayTypefilterEnabled && pattern.isNotEmpty) {
            return PaytypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return PaytypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = PaytypeList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _PayTypehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _PayTypehoveredIndex = null;
            }),
            child: Container(
              color: _selectedPayTypeIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedPayTypeIndex == null &&
                          PaytypeList.indexOf(_PaytypeController.text) == index
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
            _PaytypeController.text = suggestion;
            selectedPaytype = suggestion;
            _PayTypefilterEnabled = false;
            FocusScope.of(context).requestFocus(ButtonFocus);
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

  void _saveDataToAPI() async {
    String? description = _descriptionController.text;
    String? ExpenseCategory = ExpenseCategoryController.text;
    String? amount = amountController.text;
    if (description == "" ||
        _PaytypeController.text == "" ||
        ExpenseCategory == "" ||
        amount == "0.0" ||
        amount == "") {
      WarninngMessage(context);

      return;
    }

    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/ExpenseEntryDetailalldata/';
    Map<String, dynamic> postData = {
      "cusid": cusid,
      'dt': _DateController.text,
      'description': description,
      'cat': ExpenseCategory,
      'type': _PaytypeController.text,
      'amount': amount,
    };

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
              "Expense Entry: Category-${ExpenseCategory}_${amount}_Inserted");

          fetchExpenseDetails();
          successfullySavedMessage(context);
          _descriptionController.text = "";
          _PaytypeController.text = "";
          ExpenseCategoryController.text = "";
          amountController.text = "0.0";
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          _DateController.text = formatter.format(DateTime.now());
          ExpeCategoryFocus.requestFocus();
        } else {
          print('Failed to save data. Status code: ${response.statusCode}');
          print('Response content: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
