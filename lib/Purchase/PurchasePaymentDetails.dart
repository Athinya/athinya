import 'dart:convert';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Purchase/Config/PurchaseCustomer.dart';

class PaymentDetailsPage extends StatefulWidget {
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  bool isFormVisible = false;
  List<Map<String, dynamic>> tableData = [];
  bool isUpdateMode = false;

  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;

  TextEditingController PreviousAMountController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  FocusNode SupplierNameFocusNode = FocusNode();
  FocusNode DateFocuNode = FocusNode();
  FocusNode PaymentTypeFocuNode = FocusNode();
  FocusNode AmountFocusNode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchData();
    FetchSupplierName();
    FetchPaymentType();
    fetchPurchaseRecordNo();
    finalAmountController.text = "0.0";
    PreviousAMountController.text = "0.0";
  }

  double totalAmount = 0.0;

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchData();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchData();
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (searchText.isEmpty) {
      // If the search text is empty, return the original data
      return tableData;
    }

    // Convert search text to lowercase
    String searchTextLower = searchText.toLowerCase();

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = tableData
        .where((data) =>
            (data['agentname'] ?? '').toLowerCase().contains(searchTextLower))
        .toList();

    return filteredData;
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchasePayments/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);
      setState(() {
        tableData = results;
      });
    }
  }

  String searchText = '';

  List<String> SupplierNameList = [];

  Future<void> FetchSupplierName() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PurchaseSupplierNames/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          SupplierNameList.addAll(
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

      // print('All product categories: $SupplierNameList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  String? selectedValue;
  TextEditingController SupplilerNameController = TextEditingController();

  // Widget SupplilerNameDropdown() {
  //   return Autocomplete<String>(
  //     optionsBuilder: (TextEditingValue fruitTextEditingValue) {
  //       final filteredOptions = SupplierNameList.where((String option) {
  //         return option
  //             .toLowerCase()
  //             .contains(fruitTextEditingValue.text.toLowerCase());
  //       }).toList();

  //       if (filteredOptions.isEmpty && fruitTextEditingValue.text.isNotEmpty) {
  //         return ['No items found!!!'];
  //       }

  //       return filteredOptions;
  //     },
  //     onSelected: (String value) async {
  //       // debugPrint('You just selected $value');
  //       setState(() {
  //         selectedValue = value;
  //         SupplilerNameController.text = value;
  //         _isSupplierNameOptionsVisible = true;
  //       });
  //       await fetchpaymentData();
  //       FocusScope.of(context).requestFocus(PaymentTypeFocuNode);
  //     },
  //     displayStringForOption: (String option) => option,
  //     fieldViewBuilder: (BuildContext context,
  //         TextEditingController textEditingController,
  //         FocusNode focusNode,
  //         VoidCallback onFieldSubmitted) {
  //       focusNode:
  //       SupplierNameFocusNode;
  //       textInputAction:
  //       TextInputAction.next;
  //       onSubmitted:
  //       (_) => _fieldFocusChange(
  //           context, SupplierNameFocusNode, PaymentTypeFocuNode);
  //       SupplilerNameController = textEditingController;
  //       return Container(
  //         height: 23,
  //         width: 150,
  //         child: TextField(
  //           controller: textEditingController,
  //           focusNode: focusNode,
  //           decoration: InputDecoration(
  //             suffixIcon: Icon(
  //               Icons.keyboard_arrow_down,
  //               size: 18,
  //               color: Colors.black,
  //             ),
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
  //             ),
  //             contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //             labelStyle: TextStyle(fontSize: 12),
  //           ),
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.black,
  //           ),
  //           onTap: () {
  //             setState(() {
  //               if (!_isSupplierNameOptionsVisible) {
  //                 _isSupplierNameOptionsVisible = true;
  //               }
  //             });
  //           },
  //           onChanged: (value) {
  //             setState(() {
  //               _isSupplierNameOptionsVisible =
  //                   SupplilerNameController.text.isNotEmpty;
  //             });
  //           },
  //           onSubmitted: (value) {
  //             onFieldSubmitted();
  //           },
  //         ),
  //       );
  //     },
  //     optionsViewBuilder: (BuildContext context,
  //         AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
  //       if (_isSupplierNameOptionsVisible) {
  //         return Align(
  //           alignment: Alignment.topLeft,
  //           child: Material(
  //             elevation: 4.0,
  //             child: SizedBox(
  //               height: 150.0,
  //               width: 150,
  //               child: ListView(
  //                 children: options.map((String option) {
  //                   return Container(
  //                     height: 25,
  //                     child: ListTile(
  //                       title: Column(
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 option,
  //                                 style: TextStyle(fontSize: 12),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       onTap: () {
  //                         onSelected(option);
  //                         setState(() {
  //                           _isSupplierNameOptionsVisible = true;
  //                         });
  //                       },
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //         );
  //       } else {
  //         return SizedBox.shrink();
  //       }
  //     },
  //   );
  // }

  // Widget _buildSupplierNameDropdown() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 0.0),
  //     child: Row(
  //       children: [
  //         Icon(Icons.person),
  //         SizedBox(width: 3),
  //         Container(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(height: 0),
  //               Container(
  //                   height: 23, width: 110, child: SupplilerNameDropdown()),
  //             ],
  //           ),
  //         ),
  //         SizedBox(width: 3),
  //         Padding(
  //           padding: const EdgeInsets.only(top: 6.0),
  //           child: InkWell(
  //             onTap: () {
  //               showDialog(
  //                 context: context,
  //                 builder: (BuildContext context) {
  //                   return AlertDialog(
  //                     content: Container(
  //                       width: 1100,
  //                       child: StaffDetailsPage(),
  //                     ),
  //                   );
  //                 },
  //               );
  //             },
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(4.0),
  //                 border: Border.all(
  //                   color: Colors.blue.shade200,
  //                   width: 1.0,
  //                   style: BorderStyle.solid,
  //                 ),
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.only(
  //                     left: 6, right: 6, top: 2, bottom: 2),
  //                 child: Text(
  //                   "+",
  //                   style: TextStyle(
  //                       color: subcolor,
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  int? _selectedSuppliernameIndex;

  bool _isSupplierNameOptionsVisible = false;
  int? _SupplierhoveredIndex;
  Widget _buildSupplierNameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          // Icon(Icons.person),
          // SizedBox(width: 3),
          Container(
            height: 40,
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.13
                : MediaQuery.of(context).size.width * 0.48,
            // width: 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.only(
                left: 0,
              ),
              child: SupplilerNameDropdown(), // Use the modified dropdown here
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: 1150,
                          height: 800,
                          padding: EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              PurchaseCustomerSupplier(),
                              Positioned(
                                right: 0.0,
                                top: 0.0,
                                child: IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Colors.red, size: 23),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    FetchSupplierName();
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
                width: 25,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: subcolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 2, bottom: 2),
                  child: Center(
                    child: Text(
                      "+",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SupplilerNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                SupplierNameList.indexOf(SupplilerNameController.text);
            if (currentIndex < SupplierNameList.length - 1) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex + 1;
                SupplilerNameController.text =
                    SupplierNameList[currentIndex + 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                SupplierNameList.indexOf(SupplilerNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex - 1;
                SupplilerNameController.text =
                    SupplierNameList[currentIndex - 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: SupplierNameFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchpaymentData();
            _fieldFocusChange(
                context, SupplierNameFocusNode, PaymentTypeFocuNode);
          },
          controller: SupplilerNameController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'Supplier Name',
            labelStyle: commonLabelTextStyle.copyWith(
              color: const Color.fromARGB(255, 116, 116, 116),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_sharp,
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
          onChanged: (text) async {
            setState(() {
              _isSupplierNameOptionsVisible = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isSupplierNameOptionsVisible && pattern.isNotEmpty) {
            return SupplierNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return SupplierNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = SupplierNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _SupplierhoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _SupplierhoveredIndex = null;
            }),
            child: Container(
              color: _selectedSuppliernameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedSuppliernameIndex == null &&
                          SupplierNameList.indexOf(
                                  SupplilerNameController.text) ==
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
            SupplilerNameController.text = suggestion!;
            selectedValue = suggestion;
            _isSupplierNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(PaymentTypeFocuNode);
          });
          await fetchpaymentData();
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

  TextEditingController PaymentTypeListController = TextEditingController();
  String? PaymentTypeselectedValue;
  bool _isPayTypeOptionsVisible = false;

  List<String> PaymentTypeList = [];

  String? selectedPaytype;

  int? _selectedPayTypeIndex;
  int? _PayTypehoveredIndex;

  Future<void> FetchPaymentType() async {
    String? cusid = await SharedPrefs.getCusId();
    try {
      String url = '$IpAddress/PaymentMethod/$cusid/';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<String> fetchedPaytypes = [];

        for (var item in data) {
          String PaymentTypeList = item['paytype'];
          fetchedPaytypes.add(PaymentTypeList);
        }

        setState(() {
          PaymentTypeList = fetchedPaytypes;
        });
      }

      // print('All PaymentTypeList: $PaymentTypeList');
    } catch (e) {
      // print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  Widget _buildPayTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          // Icon(Icons.payment),
          // SizedBox(width: 3),
          Container(
            height: 40,
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.15
                : MediaQuery.of(context).size.width * 0.42,
            // width: 200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.only(
                left: 0,
              ),
              child: Paymenttypedropdown(), // Use the modified dropdown here
            ),
          ),
        ],
      ),
    );
  }

  Widget Paymenttypedropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeListController.text);
            if (currentIndex < PaymentTypeList.length - 1) {
              setState(() {
                _selectedPayTypeIndex = currentIndex + 1;
                PaymentTypeListController.text =
                    PaymentTypeList[currentIndex + 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                PaymentTypeList.indexOf(PaymentTypeListController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedPayTypeIndex = currentIndex - 1;
                PaymentTypeListController.text =
                    PaymentTypeList[currentIndex - 1];
                _isPayTypeOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: PaymentTypeFocuNode,
          onSubmitted: (_) =>
              _fieldFocusChange(context, PaymentTypeFocuNode, AmountFocusNode),
          controller: PaymentTypeListController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'PaymentType',
            labelStyle: commonLabelTextStyle.copyWith(
              color: const Color.fromARGB(255, 116, 116, 116),
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_sharp,
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
              _isPayTypeOptionsVisible = true;
              selectedPaytype = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isPayTypeOptionsVisible && pattern.isNotEmpty) {
            return PaymentTypeList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return PaymentTypeList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = PaymentTypeList.indexOf(suggestion);
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
                          PaymentTypeList.indexOf(
                                  PaymentTypeListController.text) ==
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
            PaymentTypeListController.text = suggestion!;
            selectedPaytype = suggestion;
            _isPayTypeOptionsVisible = false;
            FocusScope.of(context).requestFocus(AmountFocusNode);
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

  TextEditingController _DateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Payment Details', // Add your title here

                            style: HeadingStyle,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[300],
                    ),
                    if (Responsive.isDesktop(context))
                      Column(
                        children: [
                          Row(
                            children: [_cardview(), _tableview()],
                          ),
                        ],
                      ),
                    if (Responsive.isMobile(context))
                      Column(
                        children: [
                          Row(
                            children: [_cardview()],
                          ),
                          Row(
                            children: [_tableview()],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchpaymentData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchasePayments/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalPayAMount =
        0; // Variable to store total amount for agentname "jasim"

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if agentname is "jasim"
        if (entry['agentname'] == SupplilerNameController.text) {
          // Parse and add the amount to totalPayAMount
          double amount = double.parse(entry['amount'] ?? '0');
          totalPayAMount += amount;
        }
      }
      print("total pryment : $totalPayAMount");
      await fetchPurchaseRoundAmount(totalPayAMount);
    }
  }

  void _addItem() async {
    if (SupplilerNameController.text.isEmpty ||
        PaymentTypeListController.text.isEmpty ||
        finalAmountController.text.isEmpty) {
      WarninngMessage(context);
    } else
      try {
        if (!mounted) return;

        String recordno = PurchasePaymentRecordNo.text;
        String supplierName = SupplilerNameController.text;
        String paymentType = PaymentTypeListController.text;
        String finalAmount = finalAmountController.text;

        String? cusid = await SharedPrefs.getCusId();
        Map<String, dynamic> postData = {
          "cusid": "$cusid",
          "date": _DateController.text,
          "agentname": supplierName,
          "paytype": paymentType,
          "amount": finalAmount,
          "name": "Null"
        };

        String jsonData = jsonEncode(postData);

        String apiUrl = '$IpAddress/PurchasePaymentsAlldatas/';
        http.Response response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        if (response.statusCode == 201) {
          // print('Data posted successfully');

          if (mounted) {
            await logreports(
                "Purchase Payment: ${recordno}_${supplierName}_${finalAmount}_Paid");
            await postDataWithIncrementedSerialNo();

            successfullySavedMessage(context);
            fetchData();
            SupplilerNameController.text = '';
            PaymentTypeListController.text = '';
            PreviousAMountController.text = '';
            finalAmountController.text = "0.0";
            fetchPurchaseRecordNo();
            fetchData();
          }
        } else {
          print(
              'Failed to post data: ${response.statusCode}, ${response.body}');
        }
      } catch (e) {
        // print('Error: $e');
      }
  }

  TextEditingController PurchasePaymentRecordNo = TextEditingController();

  Future<void> fetchPurchaseRecordNo() async {
    try {
      String? cusid = await SharedPrefs.getCusId(); // Fetch the customer ID
      final response =
          await http.get(Uri.parse('$IpAddress/PurchasePaymentSNo/$cusid/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Null safety check: Ensure 'payno' exists and is an integer
        int currentPayno =
            jsonData['payno'] != null ? jsonData['payno'] as int : 0;

        // Add 1 to the current payno if it's valid, or set a default value
        int nextPayno = currentPayno + 1;

        setState(() {
          PurchasePaymentRecordNo.text = nextPayno
              .toString(); // Update the controller with the record number
        });
      } else {
        throw Exception(
            'Failed to load serial number. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error or handle it accordingly
      print('Error fetching Purchase Record No: $e');
    }
  }

  void _addRowMaterial() async {
    try {
      if (!mounted) return;
      String recordno = PurchasePaymentRecordNo.text;
      String Suppliername = SupplilerNameController.text;
      String description = "$recordno - $Suppliername";

      String paymentType = PaymentTypeListController.text;
      String finalAmount = finalAmountController.text;

      String? cusid = await SharedPrefs.getCusId();
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "dt": _DateController.text,
        "cat": "PurchasePayment",
        "description": description,
        "amount": finalAmount,
        "type": paymentType,
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/Purchase_Expenses/';
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        // print('Data posted successfully');

        // if (mounted) {
        //   postDataWithIncrementedSerialNo();
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //     builder: (context) => PaymentDetailsPage(),
        //   ));
        //   successfullySavedMessage();
        //   fetchData();
        // }
      } else {
        // print('Failed to post data: ${response.statusCode}, ${response.body}');

        // postDataWithIncrementedSerialNo();
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => PaymentDetailsPage(),
        // ));
        // successfullySavedMessage();
        // fetchData();
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    int incrementedSerialNo = int.parse(
      PurchasePaymentRecordNo.text,
    );

    String? cusid = await SharedPrefs.getCusId();
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "payno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse('$IpAddress/PurchasePaymentSNoalldatas/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        // print('Data posted successfully');
      } else {
        // print('Failed to post data. Error code: ${response.statusCode}');
        // print('Response body: ${response.body}');
      }
    } catch (e) {
      // print('Failed to post data. Error: $e');
    }
  }

  Future<void> fetchPurchaseRoundAmount(double totalPayAmount) async {
    double totalPurchasePayment = 0;

    String? cusid = await SharedPrefs.getCusId();
    String? apiUrl = '$IpAddress/PurchaseRoundDetails/$cusid/';

    while (apiUrl != null) {
      http.Response response = await http.get(Uri.parse(apiUrl));
      var jsonData = json.decode(response.body);

      if (jsonData != null && jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        for (var entry in results) {
          String purchaserName = entry['purchasername'];
          double amount = double.parse(entry['total'] ?? '0');

          // Filter based on purchaser name
          if (purchaserName == SupplilerNameController.text) {
            totalPurchasePayment += amount;
          }
        }

        // Update apiUrl for the next page, if available
        apiUrl = jsonData['next'];
      } else {
        // No more pages to fetch
        apiUrl = null;
      }
    }

    double differencePaymentAmount = totalPurchasePayment - totalPayAmount;
    PreviousAMountController.text = differencePaymentAmount.toString();

    print(
        "total amount $differencePaymentAmount = $totalPurchasePayment - $totalPayAmount");
  }

  Widget _cardview() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
              height: Responsive.isDesktop(context) ? screenHeight * 0.9 : 400,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: Responsive.isDesktop(context)
                            ? screenHeight * 0.9
                            : 350,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 22, left: 15, right: 10, bottom: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purchase Payment',
                                style: HeadingStyle,
                              ),
                              SizedBox(
                                height: 22,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (Responsive.isDesktop(context))
                                    Row(
                                      children: [
                                        // Text(
                                        //   'RecordNo: ',
                                        //   style: commonLabelTextStyle,
                                        // ),
                                        SizedBox(height: 5),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: Responsive.isDesktop(
                                                        context)
                                                    ? 10
                                                    : 5,
                                                top: 8),
                                            child: buildTextField(
                                                'RecNo',
                                                PurchasePaymentRecordNo,
                                                Responsive.isDesktop(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.15 // Width for desktop
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28, // Width for mobile
                                                Icons.inventory_rounded,
                                                null,
                                                null,
                                                context: context)),
                                      ],
                                    ),

                                  if (Responsive.isDesktop(context))
                                    SizedBox(height: 15),
                                  if (Responsive.isDesktop(context))
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Text(
                                        //   'Supplier Name',
                                        //   style: commonLabelTextStyle,
                                        // ),
                                        // SizedBox(height: 5),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left:
                                                  Responsive.isDesktop(context)
                                                      ? 10
                                                      : 5,
                                              top: 5),
                                          child: _buildSupplierNameDropdown(),
                                        ),
                                      ],
                                    ),
                                  if (!Responsive.isDesktop(context))
                                    Row(
                                      children: [
                                        // Text(
                                        //   'RecordNo: ',
                                        //   style: commonLabelTextStyle,
                                        // ),
                                        SizedBox(height: 5),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: Responsive.isDesktop(
                                                        context)
                                                    ? 10
                                                    : 5,
                                                top: 8),
                                            child: buildTextField(
                                                'RecNo',
                                                PurchasePaymentRecordNo,
                                                Responsive.isDesktop(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.45 // Width for desktop
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.28, // Width for mobile
                                                Icons.inventory_rounded,
                                                null,
                                                null,
                                                context: context)),
                                        SizedBox(width: 2),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Text(
                                            //   'Supplier Name',
                                            //   style: commonLabelTextStyle,
                                            // ),
                                            // SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 5,
                                                  top: 5),
                                              child:
                                                  _buildSupplierNameDropdown(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  // Text(
                                  //   PurchasePaymentRecordNo.text,
                                  //   style: TextStyle(fontSize: 12),
                                  // ),
                                ],
                              ),

                              SizedBox(height: 15),
                              Responsive.isDesktop(context)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 10,
                                            top: 15.0,
                                          ),
                                          child: buildTextField(
                                            'Pre.Balance',
                                            PreviousAMountController,
                                            Responsive.isDesktop(context)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15 // Width for desktop
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.42, // Width for mobile
                                            Icons.inventory_rounded,
                                            null,
                                            null,
                                            onChangedCallback: (newValue) {
                                              PreviousAMountController.text =
                                                  newValue;
                                            },
                                            context: context,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 10,
                                            top: 10.0,
                                          ),
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.15),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15, // Width for desktop,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12.0),
                                                  child: Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.black87,
                                                    size: 18,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Date',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 8,
                                                        child: DateTimePicker(
                                                          controller:
                                                              _DateController,
                                                          focusNode:
                                                              DateFocuNode,
                                                          firstDate:
                                                              DateTime(2000),
                                                          lastDate:
                                                              DateTime(2100),
                                                          dateLabelText: '',
                                                          onChanged: (val) {
                                                            setState(() {
                                                              selectedDate =
                                                                  DateTime
                                                                      .parse(
                                                                          val);
                                                            });
                                                          },
                                                          style: textStyle,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
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
                                    )
                                  : Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 5.0),
                                              child: buildTextField(
                                                'Pre.Balance',
                                                PreviousAMountController,
                                                Responsive.isDesktop(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.15 // Width for desktop
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.42, // Width for mobile
                                                Icons.inventory_rounded,
                                                null,
                                                null,
                                                onChangedCallback: (newValue) {
                                                  PreviousAMountController
                                                      .text = newValue;
                                                },
                                                context: context,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 10.0),
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.15),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.38,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12.0),
                                                      child: Icon(
                                                        Icons.calendar_month,
                                                        color: Colors.black87,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Date',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 16,
                                                            child:
                                                                DateTimePicker(
                                                              controller:
                                                                  _DateController,
                                                              focusNode:
                                                                  DateFocuNode,
                                                              firstDate:
                                                                  DateTime(
                                                                      2000),
                                                              lastDate:
                                                                  DateTime(
                                                                      2100),
                                                              dateLabelText: '',
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  selectedDate =
                                                                      DateTime
                                                                          .parse(
                                                                              val);
                                                                });
                                                              },
                                                              style: textStyle,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
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
                                        )
                                      ],
                                    ),

                              SizedBox(height: 15),
                              if (Responsive.isDesktop(context))
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0, top: 10.0),
                                      child: _buildPayTypeDropdown(),
                                    ),
                                    SizedBox(height: 15),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, top: 10.0),
                                      child: buildTextField(
                                        'Amount',
                                        finalAmountController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile
                                        Icons.inventory_rounded,
                                        AmountFocusNode,
                                        saveButtonFocusNode,
                                        isNumeric: true,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                ),

                              // Conditional layout for Mobile view
                              if (Responsive.isMobile(context))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.0, top: 5.0),
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: _buildPayTypeDropdown()),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.0, top: 10.0),
                                        child: buildTextField(
                                          'Amount',
                                          finalAmountController,
                                          Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.12 // Width for desktop
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42, // Width for mobile
                                          Icons.inventory_rounded,
                                          AmountFocusNode,
                                          saveButtonFocusNode,
                                          isNumeric: true,
                                          context: context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              SizedBox(
                                  height:
                                      15), // Adjust the spacing between Date and Amount
                              Padding(
                                padding: EdgeInsets.only(
                                    left: Responsive.isDesktop(context)
                                        ? 15.0
                                        : 5.0,
                                    top: Responsive.isMobile(context) ? 10 : 5),
                                child: ElevatedButton(
                                  focusNode: saveButtonFocusNode,
                                  onPressed: () {
                                    double previousAmount = double.tryParse(
                                            PreviousAMountController.text) ??
                                        0;
                                    double finalAmount = double.tryParse(
                                            finalAmountController.text) ??
                                        0;

                                    // print(
                                    //     "payment amount : ${PreviousAMountController.text}");
                                    // print(
                                    //     "payment amount : ${finalAmountController.text}");

                                    if (previousAmount < finalAmount) {
                                      AmountWarningMessage();
                                      finalAmountController.clear();
                                    } else {
                                      _addItem();
                                      _addRowMaterial();
                                      fetchData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: subcolor,
                                      minimumSize: Size(45.0, 31.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  child: Text(
                                    'Save',
                                    style: commonWhiteStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ])),
        ));
  }

  String PaymentId = '';
  Future<bool?> _showDeleteConfirmationDialog(
      String PaymentId, String date, String agentname, String amount) async {
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
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              focusNode: saveButtonFocusNode,
              onPressed: () async {
                await logreports(
                    "Purchase Payment : ${date}_${agentname}_${amount}_Deleted");
                deletedata(PaymentId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        );
      },
    );
  }

  void deletedata(String PaymentId) async {
    // Make PUT request to the API
    String apiUrl = '$IpAddress/PurchasePaymentsAlldatas/$PaymentId';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check response status
    if (response.statusCode == 204) {
      print("Data updated successfully");
      successfullyDeleteMessage(context);
      fetchData();

      fetchpaymentData();
    } else {
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
  }

  Widget _tableview() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      flex: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.9 : 300,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Add horizontal scrolling
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCell(Icons.numbers, "ID", 265.0),
                        _buildHeaderCell(Icons.date_range, "Date", 265.0),
                        _buildHeaderCell(Icons.payment, "PayType", 265.0),
                        _buildHeaderCell(Icons.attach_money, "Amount", 265.0),
                        _buildHeaderCell(Icons.delete, "Delete", 265.0),
                      ],
                    ),
                  ),
                ),
                if (getFilteredData().isNotEmpty)
                  ...getFilteredData()
                      .where((data) => data['agentname'] == selectedValue)
                      .map((data) {
                    var id = data['id'].toString();
                    var date = data['date'].toString();
                    var paytype = data['paytype'].toString();
                    var amount = data['amount'].toString();
                    var agentname = data['agentname'].toString();
                    bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                    Color? rowColor = isEvenRow
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(224, 255, 255, 255);

                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10,
                        bottom: 2.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal, // Add horizontal scrolling
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildDataCell(id, 255.0, rowColor),
                            _buildDataCell(date, 255.0, rowColor),
                            _buildDataCell(paytype, 255.0, rowColor),
                            _buildDataCell(amount, 255.0, rowColor),
                            _buildDeleteCell(agentname, date, data, rowColor),
                          ],
                        ),
                      ),
                    );
                  }).toList()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(IconData icon, String text, double width) {
    return Container(
      height: Responsive.isDesktop(context) ? 25 : 30,
      width:
          Responsive.isMobile(context) ? 100.0 : 180, // Adjust width for mobile
      decoration: TableHeaderColor,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.blue),
            SizedBox(width: 5),
            Text(text,
                textAlign: TextAlign.center, style: commonLabelTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String data, double width, Color rowColor) {
    return Container(
      height: 30,
      width: Responsive.isMobile(context)
          ? 100.0
          : width, // Adjust width for mobile
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(
          color: Color.fromARGB(255, 226, 225, 225),
        ),
      ),
      child: Center(
        child:
            Text(data, textAlign: TextAlign.center, style: TableRowTextStyle),
      ),
    );
  }

  Widget _buildDeleteCell(String agentname, String date,
      Map<String, dynamic> data, Color rowColor) {
    return Container(
      height: 30,
      width: Responsive.isMobile(context)
          ? 100.0
          : 255.0, // Adjust width for mobile
      decoration: BoxDecoration(
        color: rowColor,
        border: Border.all(
          color: Color.fromARGB(255, 226, 225, 225),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  PaymentId = data['id'].toString();
                });
                _showDeleteConfirmationDialog(
                    PaymentId, date, agentname, data['amount'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _tableview() {
  //   double screenHeight = MediaQuery.of(context).size.height;
  //   return Expanded(
  //     flex: 8,
  //     child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Container(
  //           height: Responsive.isDesktop(context) ? screenHeight * 0.9 : 300,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.5),
  //                 spreadRadius: 2,
  //                 blurRadius: 5,
  //                 offset: Offset(0, 3),
  //               ),
  //             ],
  //           ),
  //           padding: EdgeInsets.all(10),
  //           child: SingleChildScrollView(
  //             child: Column(children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 10.0, right: 10),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Flexible(
  //                       child: Container(
  //                         height: Responsive.isDesktop(context) ? 25 : 30,
  //                         width: 265.0,
  //                         decoration: TableHeaderColor,
  //                         child: Center(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.numbers,
  //                                 size: 15,
  //                                 color: Colors.blue,
  //                               ),
  //                               SizedBox(width: 5),
  //                               Text("ID",
  //                                   textAlign: TextAlign.center,
  //                                   style: commonLabelTextStyle),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       child: Container(
  //                         height: Responsive.isDesktop(context) ? 25 : 30,
  //                         width: 265.0,
  //                         decoration: TableHeaderColor,
  //                         child: Center(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.date_range,
  //                                 size: 15,
  //                                 color: Colors.blue,
  //                               ),
  //                               SizedBox(width: 5),
  //                               Text("Date",
  //                                   textAlign: TextAlign.center,
  //                                   style: commonLabelTextStyle),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       child: Container(
  //                         height: Responsive.isDesktop(context) ? 25 : 30,
  //                         width: Responsive.isDesktop(context) ? 265.0 : 300,
  //                         decoration: TableHeaderColor,
  //                         child: Center(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.payment,
  //                                 size: 15,
  //                                 color: Colors.blue,
  //                               ),
  //                               SizedBox(width: 5),
  //                               SingleChildScrollView(
  //                                 scrollDirection: Axis.horizontal,
  //                                 child: Text("PayType",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       child: Container(
  //                         height: Responsive.isDesktop(context) ? 25 : 30,
  //                         width: Responsive.isDesktop(context) ? 265.0 : 300,
  //                         decoration: TableHeaderColor,
  //                         child: Center(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.attach_money,
  //                                 size: 15,
  //                                 color: Colors.blue,
  //                               ),
  //                               SizedBox(width: 5),
  //                               SingleChildScrollView(
  //                                 scrollDirection: Axis.horizontal,
  //                                 child: Text("Amount",
  //                                     textAlign: TextAlign.center,
  //                                     style: commonLabelTextStyle),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       child: Container(
  //                         height: Responsive.isDesktop(context) ? 25 : 30,
  //                         width: Responsive.isDesktop(context) ? 265.0 : 300,
  //                         decoration: TableHeaderColor,
  //                         child: Center(
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.delete,
  //                                 size: 15,
  //                                 color: Colors.blue,
  //                               ),
  //                               SizedBox(width: 5),
  //                               Text("Delete",
  //                                   textAlign: TextAlign.center,
  //                                   style: commonLabelTextStyle),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (getFilteredData().isNotEmpty)
  //                 ...getFilteredData()
  //                     .where((data) => data['agentname'] == selectedValue)
  //                     .map((data) {
  //                   var id = data['id'].toString();
  //                   var date = data['date'].toString();
  //                   var paytype = data['paytype'].toString();
  //                   var agentname = data['agentname'].toString();
  //                   var amount = data['amount'].toString();
  //                   var name = data['name'].toString();
  //                   bool isEvenRow = tableData.indexOf(data) % 2 == 0;
  //                   Color? rowColor = isEvenRow
  //                       ? Color.fromARGB(224, 255, 255, 255)
  //                       : Color.fromARGB(224, 255, 255, 255);

  //                   return Padding(
  //                     padding: const EdgeInsets.only(
  //                       left: 10.0,
  //                       right: 10,
  //                       bottom: 2.0,
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Flexible(
  //                           child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 id,
  //                                 textAlign: TextAlign.center,
  //                                 style: TableRowTextStyle,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 date,
  //                                 textAlign: TextAlign.center,
  //                                 style: TableRowTextStyle,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 paytype,
  //                                 textAlign: TextAlign.center,
  //                                 style: TableRowTextStyle,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Center(
  //                               child: Text(
  //                                 amount,
  //                                 textAlign: TextAlign.center,
  //                                 style: TableRowTextStyle,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: Container(
  //                             height: 30,
  //                             width: 255.0,
  //                             decoration: BoxDecoration(
  //                               color: rowColor,
  //                               border: Border.all(
  //                                 color: Color.fromARGB(255, 226, 225, 225),
  //                               ),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(bottom: 0),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   IconButton(
  //                                     icon: Icon(
  //                                       Icons.delete,
  //                                       color: Colors.red,
  //                                       size: 18,
  //                                     ),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         PaymentId = data['id'].toString();
  //                                       });
  //                                       _showDeleteConfirmationDialog(
  //                                           PaymentId, date, agentname, amount);
  //                                     },
  //                                     color: Colors.black,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList()
  //             ]),
  //           ),
  //         )),
  //   );
  // }

  void AmountWarningMessage() {
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
                'Please Check the Payment Details For this Supplier',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
  }
}
