import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

class printerdetails extends StatefulWidget {
  const printerdetails({Key? key}) : super(key: key);

  @override
  State<printerdetails> createState() => _printerdetailsState();
}

class _printerdetailsState extends State<printerdetails> {
  String? selectedValue;
  String? selectedproduct;
  String? selectedCount;
  int selectedRadio = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController printerController = TextEditingController();
  TextEditingController countController = TextEditingController(text: "0");

  List<String> printersizevalue = ["3Inch", "4Inch", "A4", "A5"];
  List<bool> isSelectedPrinterSize = [
    true,
    false,
    false,
    false
  ]; // Initial state
  String selectedPrinterSizePercentges =
      "3Inch"; // Initialize with a default value

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/Settings_PrinterDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData != null) {
      tableData = List<Map<String, dynamic>>.from(jsonData);
    } else {
      tableData = []; // Initialize tableData as empty list if jsonData is null
    }

    if (mounted) {
      setState(() {
        // Example of calculating total amount from tableData
        totalAmount = tableData.isNotEmpty
            ? tableData
                .map((data) => double.tryParse(data['count'].toString()) ?? 0.0)
                .reduce((value, element) => value + element)
            : 0.0;
      });
    }
  }

  List<Map<String, dynamic>> tableData = [];

  FocusNode NameFocus = FocusNode();
  FocusNode DefaultPrintFocus = FocusNode();
  FocusNode PrintCountFocus = FocusNode();
  FocusNode GstFocus = FocusNode();
  int printCountValue = 0;

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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 10,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Printer Details",
                            style: HeadingStyle,
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Responsive.isDesktop(context)
                            ? Row(
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 10
                                                      : 50,
                                                  top: 8),
                                              child: Text(
                                                "Selected Type",
                                                style: commonLabelTextStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 55,
                                                  top: 8),
                                              child: Container(
                                                color: Colors.grey[200],
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 180
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Radio button for option 1
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Transform.scale(
                                                              scale: 0.7,
                                                              child: Radio(
                                                                value: 1,
                                                                groupValue:
                                                                    selectedRadio,
                                                                onChanged: (int?
                                                                    value) {
                                                                  setState(() {
                                                                    selectedRadio =
                                                                        value!;
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            NameFocus);
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            Text(
                                                              'Sales',
                                                              style: textStyle,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Transform.scale(
                                                              scale: 0.7,
                                                              child: Radio(
                                                                value: 2,
                                                                groupValue:
                                                                    selectedRadio,
                                                                onChanged: (int?
                                                                    value) {
                                                                  setState(() {
                                                                    selectedRadio =
                                                                        value!;
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            NameFocus);
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            Text(
                                                              'Kitchen',
                                                              style: textStyle,
                                                            ),
                                                          ],
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
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 55,
                                                  top: 30),
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 180
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.3,
                                                child: Container(
                                                  height: 40,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.15),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    onSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            NameFocus,
                                                            DefaultPrintFocus),
                                                    controller: nameController,
                                                    focusNode: NameFocus,
                                                    decoration: InputDecoration(
                                                      labelText: 'Name',
                                                      labelStyle:
                                                          commonLabelTextStyle
                                                              .copyWith(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 116, 116, 116),
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 7.0,
                                                      ),
                                                    ),
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 55,
                                                  top: 30),
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 180
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.3,
                                                child: Container(
                                                  height: 40,
                                                  width: 150,
                                                  color: Colors.grey[200],
                                                  child: TextField(
                                                    controller:
                                                        printerController,
                                                    focusNode:
                                                        DefaultPrintFocus,
                                                    onSubmitted: (_) =>
                                                        _fieldFocusChange(
                                                            context,
                                                            DefaultPrintFocus,
                                                            PrintCountFocus),
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Default Printer',
                                                      labelStyle:
                                                          commonLabelTextStyle
                                                              .copyWith(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 116, 116, 116),
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 7.0,
                                                      ),
                                                    ),
                                                    style: textStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              'Print Count',
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      // Decrease the value by 1 when "-" button is tapped
                                                      int currentValue =
                                                          int.tryParse(
                                                                  countController
                                                                      .text) ??
                                                              0;
                                                      if (currentValue > 0) {
                                                        countController.text =
                                                            (currentValue - 1)
                                                                .toString();
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              159,
                                                              207,
                                                              247),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 8),
                                                      child: Text(
                                                        "-",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: Container(
                                                      width: 45,
                                                      child: TextField(
                                                        controller:
                                                            countController,
                                                        focusNode:
                                                            PrintCountFocus,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onSubmitted: (value) {
                                                          _fieldFocusChange(
                                                              context,
                                                              PrintCountFocus,
                                                              GstFocus);
                                                        },
                                                        onChanged: (value) {
                                                          setState(() {
                                                            printCountValue =
                                                                int.tryParse(
                                                                        value) ??
                                                                    0;
                                                          });
                                                        },
                                                        style: AmountTextStyle,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors
                                                              .grey.shade100,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          6.0),
                                                        ),
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                      )),
                                                ),
                                                SizedBox(width: 4),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      // Decrease the value by 1 when "-" button is tapped
                                                      int currentValue =
                                                          int.tryParse(
                                                                  countController
                                                                      .text) ??
                                                              0;
                                                      countController.text =
                                                          (currentValue + 1)
                                                              .toString();
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              159,
                                                              207,
                                                              247),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 8),
                                                      child: Text(
                                                        "+",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 50,
                                                  top: 8),
                                              child: Text(
                                                "Print Size",
                                                style: commonLabelTextStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 55,
                                                  top: 8),
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 200
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.7,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: Container(
                                                            height: 27,
                                                            width: 200,
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.15),
                                                                  blurRadius: 4,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child:
                                                                PrinterSizeToggle()),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // color: Colors.blue,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0, top: 10),
                                              child: Text(
                                                "",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 5
                                                      : 5,
                                                  top: 10),
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 65
                                                    : 60,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    saveData();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0),
                                                    ),
                                                    backgroundColor: subcolor,
                                                    minimumSize:
                                                        Size(80.0, 31.0),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical:
                                                            10.0), // Add padding
                                                  ),
                                                  child: Text(
                                                    'Save',
                                                    style: commonWhiteStyle
                                                        .copyWith(fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, top: 10),
                                              child: Text(
                                                "",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 5
                                                      : 5,
                                                  top: 10),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  nameController.clear();
                                                  printerController.clear();
                                                  countController.clear();
                                                  setState(() {
                                                    isSelectedPrinterSize = [
                                                      true,
                                                      false,
                                                      false,
                                                      false
                                                    ];
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  backgroundColor: subcolor,
                                                  minimumSize: Size(80.0,
                                                      31.0), // Adjusted width and height
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical:
                                                          10.0), // Add padding
                                                ),
                                                child: Text(
                                                  'Clear',
                                                  style: commonWhiteStyle.copyWith(
                                                      fontSize:
                                                          14), // Ensure the font size is readable
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: Responsive.isDesktop(
                                                        context)
                                                    ? 20
                                                    : 13,
                                              ),
                                              child: Text(
                                                "Selected Type",
                                                style: commonLabelTextStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 5,
                                                  top: 8),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Container(
                                                  color: Colors.grey[200],
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Radio button for option 1
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Transform.scale(
                                                                scale: 0.7,
                                                                child: Radio(
                                                                  value: 1,
                                                                  groupValue:
                                                                      selectedRadio,
                                                                  onChanged: (int?
                                                                      value) {
                                                                    setState(
                                                                        () {
                                                                      selectedRadio =
                                                                          value!;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              Text(
                                                                'Sales',
                                                                style:
                                                                    textStyle,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Transform.scale(
                                                                scale: 0.7,
                                                                child: Radio(
                                                                  value: 2,
                                                                  groupValue:
                                                                      selectedRadio,
                                                                  onChanged: (int?
                                                                      value) {
                                                                    setState(
                                                                        () {
                                                                      selectedRadio =
                                                                          value!;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              Text(
                                                                'Kitchen',
                                                                style:
                                                                    textStyle,
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: Responsive.isDesktop(
                                                            context)
                                                        ? 20
                                                        : 5,
                                                    top: 8),
                                                child: Container(
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? 180
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.42,
                                                  child: Container(
                                                    height: 40,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.15),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          printerController,

                                                      // controller: retailAmount,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Default Printer',
                                                        labelStyle:
                                                            commonLabelTextStyle
                                                                .copyWith(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              116, 116, 116),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 7.0,
                                                        ),
                                                      ),
                                                      style: textStyle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: Responsive.isDesktop(
                                                            context)
                                                        ? 20
                                                        : 5,
                                                    top: 8),
                                                child: Container(
                                                  width: Responsive.isDesktop(
                                                          context)
                                                      ? 180
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.42,
                                                  child: Container(
                                                    height: 40,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.15),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          nameController,

                                                      // controller: retailAmount,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Name',
                                                        labelStyle:
                                                            commonLabelTextStyle
                                                                .copyWith(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              116, 116, 116),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 7.0,
                                                        ),
                                                      ),
                                                      style: textStyle,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, left: 10.0),
                                            child: Text(
                                              'Print Count',
                                              style: commonLabelTextStyle,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1.0, left: 5.0),
                                            child: Container(
                                              height: 35,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 1,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        // Decrease the value by 1 when "-" button is tapped
                                                        int currentValue =
                                                            int.tryParse(
                                                                    countController
                                                                        .text) ??
                                                                0;
                                                        if (currentValue > 0) {
                                                          countController.text =
                                                              (currentValue - 1)
                                                                  .toString();
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 159, 207, 247),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 8),
                                                        child: Text(
                                                          "-",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: Container(
                                                        width: 45,
                                                        child: TextField(
                                                          controller:
                                                              countController,
                                                          focusNode:
                                                              PrintCountFocus,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          onSubmitted: (value) {
                                                            _fieldFocusChange(
                                                                context,
                                                                PrintCountFocus,
                                                                GstFocus);
                                                          },
                                                          onChanged: (value) {
                                                            setState(() {
                                                              printCountValue =
                                                                  int.tryParse(
                                                                          value) ??
                                                                      0;
                                                            });
                                                          },
                                                          style:
                                                              AmountTextStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors
                                                                .grey.shade100,
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            6.0),
                                                          ),
                                                          inputFormatters: <TextInputFormatter>[
                                                            FilteringTextInputFormatter
                                                                .digitsOnly,
                                                          ],
                                                        )),
                                                  ),
                                                  SizedBox(width: 4),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        // Decrease the value by 1 when "-" button is tapped
                                                        int currentValue =
                                                            int.tryParse(
                                                                    countController
                                                                        .text) ??
                                                                0;
                                                        countController.text =
                                                            (currentValue + 1)
                                                                .toString();
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 159, 207, 247),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 8),
                                                        child: Text(
                                                          "+",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 5,
                                                  top: 5),
                                              child: Text(
                                                "Print Size",
                                                style: commonLabelTextStyle,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: Responsive.isDesktop(
                                                          context)
                                                      ? 20
                                                      : 10,
                                                  top: 10),
                                              child: Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 250
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.5,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: Container(
                                                            height: 27,
                                                            width: 200,
                                                            child:
                                                                PrinterSizeToggle()),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 60
                                                    : 60,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    saveData();
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
                                                              45.0, 31.0),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0)),
                                                  child: Text('Save',
                                                      style: commonWhiteStyle
                                                          .copyWith(
                                                              fontSize: 14)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? 65
                                                    : 65,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    nameController.clear();
                                                    printerController.clear();
                                                    countController.text = "0";
                                                    setState(() {
                                                      isSelectedPrinterSize = [
                                                        true,
                                                        false,
                                                        false,
                                                        false
                                                      ];
                                                    });
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
                                                              85.0, 31.0),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical:
                                                                      5.0)),
                                                  child: Text('Clear',
                                                      style: commonWhiteStyle
                                                          .copyWith(
                                                              fontSize: 14)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                      ),
                      Divider(color: Colors.grey[300]),
                      tableView()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget PrinterSizeToggle() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Focus(
        focusNode: GstFocus,
        child: ToggleButtons(
          borderColor: Colors.grey.shade400,
          fillColor: Colors.green,
          borderWidth: 1,
          selectedColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                '3Inch',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                '4Inch',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'A4',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'A5',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
          onPressed: (int index) {
            setState(() {
              for (int i = 0; i < isSelectedPrinterSize.length; i++) {
                isSelectedPrinterSize[i] = i == index;
              }
              if (isSelectedPrinterSize[index]) {
                selectedPrinterSizePercentges = printersizevalue[index];
              }
              // print("Selected Printer size: $selectedPrinterSizePercentges");
            });
          },
          isSelected: isSelectedPrinterSize,
        ),
      ),
    );
  }

  double totalAmount = 0.0;

  TextEditingController editNameController = TextEditingController();
  TextEditingController editPrinterController = TextEditingController();
  TextEditingController editCountController = TextEditingController();

  List<bool> editisSelectedPrinterSize = [false, false, false, false];
  List<String> editprintersizevalue = ["3Inch", "4Inch", "A4", "A5"];
  String editselectedPrinterSizePercentges = '';

  Future<void> saveData() async {
    if (nameController.text.isEmpty ||
        printerController.text.isEmpty ||
        countController.text.isEmpty ||
        countController.text == "0") {
      WarninngMessage(context);
      print('Please fill in all fields');
    } else if (tableData.any((data) =>
        data['type'].toLowerCase() ==
        (selectedRadio == 1 ? 'Sales' : 'Kitchen').toLowerCase())) {
      AlreadyExistWarninngMessage();
      print('Product name already exists');
    } else {
      String type = selectedRadio == 1 ? 'Sales' : 'Kitchen';
      String name = nameController.text;
      String printer = printerController.text;
      print("Selected Printer size: $selectedPrinterSizePercentges");

      String? cusid = await SharedPrefs.getCusId();
      // Prepare data to be posted
      Map<String, dynamic> postData = {
        "cusid": "$cusid",
        "type": type,
        "name": name,
        "printer": printer,
        "count": countController.text,
        "size": selectedPrinterSizePercentges
      };

      // Convert data to JSON format
      String jsonData = jsonEncode(postData);

      // Make POST request to the API
      String apiUrl = '$IpAddress/SettingsPrinterDetailsalldatas/';
      try {
        http.Response response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        // Check response status
        if (response.statusCode == 201) {
          // Data posted successfully
          print('Data posted successfully');
        } else {
          // Data posting failed
          print(
              'Failed to post data: ${response.statusCode}, ${response.body}');
        }
        await logreports("Printer Details: ${type}_${name}_Inserted");
        nameController.clear();
        printerController.clear();
        countController.text = "0";
        setState(() {
          isSelectedPrinterSize = [true, false, false, false];
        });
        selectedValue = '';
        selectedPrinterSizePercentges = '3Inch';
        fetchData();
        successfullySavedMessage(context);
      } catch (e) {
        print('Failed to post data: $e');
      }
    }
  }

  Future<void> UpdateData(String Productid) async {
    String type = selectedRadio == 1 ? 'Sales' : 'Kitchen';
    String name = editNameController.text;
    String printer = editPrinterController.text;
    print('Edittable printer size : $editselectedPrinterSizePercentges');
    String size = '';
    if (editisSelectedPrinterSize[0]) {
      size = "3Inch";
    } else if (editisSelectedPrinterSize[1]) {
      size = "4Inch";
    } else if (editisSelectedPrinterSize[2]) {
      size = "A4";
    } else if (editisSelectedPrinterSize[3]) {
      size = "A5";
    }

    String? cusid = await SharedPrefs.getCusId();
    // Prepare data to be posted
    Map<String, dynamic> putData = {
      "cusid": "$cusid",
      "type": type,
      "name": name,
      "printer": printer,
      "count": editCountController.text,
      "size": size
    };

    String jsonData = jsonEncode(putData);

    String apiUrl = '$IpAddress/SettingsPrinterDetailsalldatas/$Productid/';
    try {
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
      await logreports("Printer Details: ${type}_${name}_Updated");

      fetchData();
      Navigator.of(context).pop();
      successfullyUpdateMessage(context);
    } catch (e) {
      print('Failed to post data: $e');
    }
  }

  void deletedata(int id) async {
    String apiUrl = '$IpAddress/SettingsPrinterDetailsalldatas/$id/';
    String type = selectedRadio == 1 ? 'Sales' : 'Kitchen';
    String name = editNameController.text;
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == response.statusCode) {
      print('Data updated successfully');
      successfullyDeleteMessage(context);
    } else {
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
    await logreports("Printer Details: ${type}_${name}_Deleted");

    fetchData();
  }

  void editData(BuildContext context, int index, {String? productId}) {
    Map<String, dynamic> selectedRow = tableData[index];
    editNameController.text = selectedRow['name'] ?? '';
    editPrinterController.text = selectedRow['printer'] ?? '';
    double currentValue =
        double.tryParse(selectedRow['count'].toString()) ?? 0.0;
    int intValue = currentValue.toInt();
    editCountController.text = intValue.toString();
    setState(() {
      selectedRadio = selectedRow['type'] == 'Sales' ? 1 : 2;
    });

    String selectedSize = selectedRow['size'] ?? '';
    setState(() {
      editisSelectedPrinterSize = List.generate(
          4, (index) => selectedSize == editprintersizevalue[index]);
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Printer Details', style: commonLabelTextStyle),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 10 : 10,
                              top: 1,
                            ),
                            child: Text(
                              "Selected Type",
                              style: commonLabelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 20 : 20,
                              top: 13,
                            ),
                            child: Container(
                              color: Colors.grey[200],
                              width: Responsive.isDesktop(context)
                                  ? 180
                                  : MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.7,
                                            child: Radio(
                                              value: 1,
                                              groupValue: selectedRadio,
                                              onChanged: null,
                                            ),
                                          ),
                                          Text(
                                            'Sales',
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.7,
                                            child: Radio(
                                              value: 2,
                                              groupValue: selectedRadio,
                                              onChanged: null,
                                            ),
                                          ),
                                          Text(
                                            'Kitchen',
                                            style: textStyle,
                                          ),
                                        ],
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
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 10 : 10,
                              top: 13,
                            ),
                            child: Text("Name", style: commonLabelTextStyle),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 20 : 20,
                              top: 13,
                            ),
                            child: Container(
                              width: Responsive.isDesktop(context)
                                  ? 180
                                  : MediaQuery.of(context).size.width * 0.3,
                              child: Container(
                                height: 27,
                                width: 100,
                                color: Colors.grey[200],
                                child: TextField(
                                  controller: editNameController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
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
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 10 : 10,
                              top: 8,
                            ),
                            child: Text("Default Printer",
                                style: commonLabelTextStyle),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 20 : 20,
                              top: 13,
                            ),
                            child: Container(
                              width: Responsive.isDesktop(context)
                                  ? 180
                                  : MediaQuery.of(context).size.width * 0.3,
                              child: Container(
                                height: 27,
                                width: 100,
                                color: Colors.grey[200],
                                child: TextField(
                                  controller: editPrinterController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
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
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context) ? 10 : 10,
                            top: 8,
                          ),
                          child: Text(
                            'Print Count',
                            style: commonLabelTextStyle,
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 20 : 20,
                              top: 4),
                          child: Container(
                            width: 120,
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 1,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // Decrease the value by 1 when "-" button is tapped
                                      int currentValue = int.tryParse(
                                              editCountController.text) ??
                                          0;
                                      if (currentValue > 0) {
                                        editCountController.text =
                                            (currentValue - 1).toString();
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: subcolor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 6, right: 6, top: 2, bottom: 2),
                                      child: Text(
                                        "-",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Container(
                                      width: 45,
                                      child: TextField(
                                        controller: editCountController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            printCountValue =
                                                int.tryParse(value) ?? 0;
                                          });
                                        },
                                        style: AmountTextStyle,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      )),
                                ),
                                SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // Decrease the value by 1 when "-" button is tapped
                                      int currentValue = int.tryParse(
                                              editCountController.text) ??
                                          0;
                                      editCountController.text =
                                          (currentValue + 1).toString();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: subcolor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 6, right: 6, top: 2, bottom: 2),
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Responsive.isDesktop(context) ? 10 : 10,
                              top: 8,
                            ),
                            child: Text(
                              "Print Size",
                              style: commonLabelTextStyle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isDesktop(context) ? 20 : 20,
                                top: 8),
                            child: Container(
                              width: Responsive.isDesktop(context)
                                  ? 250
                                  : MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Container(
                                        height: 27,
                                        width: 200,
                                        child: ToggleButtons(
                                          borderColor: Colors.grey,
                                          fillColor: Colors.black,
                                          borderWidth: 1,
                                          selectedBorderColor: Colors.black,
                                          selectedColor: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                '3Inch',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                '4Inch',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                'A4',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                'A5',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ],
                                          onPressed: (int index) {
                                            setState(() {
                                              for (int i = 0;
                                                  i <
                                                      editisSelectedPrinterSize
                                                          .length;
                                                  i++) {
                                                editisSelectedPrinterSize[i] =
                                                    i == index;
                                              }
                                              editselectedPrinterSizePercentges =
                                                  editprintersizevalue[index];
                                            });
                                            print(
                                                "edit printer is : $editselectedPrinterSizePercentges");
                                          },
                                          isSelected: editisSelectedPrinterSize,
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
                  ],
                ),
              ),
            );
          }),
          actions: [
            ElevatedButton(
              onPressed: () {
                UpdateData(productId!);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(45.0, 31.0),
              ),
              child: Text(
                'Update',
                style: commonWhiteStyle,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(45.0, 31.0),
              ),
              child: Text(
                'Cancel',
                style: commonWhiteStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  void AlreadyExistWarninngMessage() {
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
                    'Name already exists.!!',
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

  Widget tableView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Sales Section
          SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 152, 189, 250),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            margin: Responsive.isMobile(context)
                ? EdgeInsets.symmetric(vertical: 10)
                : EdgeInsets.only(left: 200, right: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var data
                    in tableData.where((data) => data['type'] == 'Sales'))
                  buildItemCard(data),
              ],
            ),
          ),
          // Kitchen Section
          SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent[100],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            margin: Responsive.isMobile(context)
                ? EdgeInsets.symmetric(vertical: 10)
                : EdgeInsets.only(left: 200, right: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var data
                    in tableData.where((data) => data['type'] == 'Kitchen'))
                  buildItemCard(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Function to build each item card
  Widget buildItemCard(Map<String, dynamic> data) {
    var type = data['type'].toString();
    var name = data['name'].toString();
    var printer = data['printer'].toString();
    var count = data['count'].toString();
    var size = data['size'].toString();
    var productId = data['id'].toString();

    String imagePath;
    switch (type) {
      case 'Kitchen':
        imagePath = 'assets/imgs/sales.png';
        break;
      case 'Sales':
        imagePath = 'assets/imgs/order.png';
        break;
      default:
        imagePath = 'assets/images/picture.png';
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Rounded corners like Card
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Shadow offset
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ensure text doesn't break awkwardly
                Container(
                  width: 100,
                  child: Text(
                    'Type: $type',
                    style: TextStyle(fontSize: 16), // Adjust font size
                  ),
                ),
                SizedBox(height: 3),
                Container(
                  width: 200,
                  child: Text(
                    'Name: $name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 3),
                Container(
                    width: 200,
                    child: Text('Printer: $printer',
                        style: TextStyle(fontSize: 16))),
                SizedBox(height: 3),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    'Count: $count',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 3),
                Container(
                    width: 50,
                    child: Text(size, style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  editData(context, tableData.indexOf(data),
                      productId: productId);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmationDialog(data);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(Map<String, dynamic> data) async {
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
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              onPressed: () {
                deletedata(data['id']);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0),
              ),
              child: Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
