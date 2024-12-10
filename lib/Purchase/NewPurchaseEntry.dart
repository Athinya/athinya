import 'dart:async';
import 'dart:convert';
import 'package:ProductRestaurant/Purchase/SubPurchaseForm.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';
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
import 'package:ProductRestaurant/Purchase/Config/PurchaseCustomer.dart';
import 'package:ProductRestaurant/Purchase/Config/PurchaseProductDetails.dart';

class NewPurchaseEntryPage extends StatefulWidget {
  const NewPurchaseEntryPage({Key? key}) : super(key: key);

  @override
  State<NewPurchaseEntryPage> createState() => _NewPurchaseEntryPageState();
}

class _NewPurchaseEntryPageState extends State<NewPurchaseEntryPage> {
  // String? selectedValue;
  String? selectedproduct;
  List<bool> isSGSTSelected = [true, false, false, false, false];
  List<bool> isCGSTSelected = [true, false, false, false, false];
  Timer? _timer;
  String searchText = '';
  String productName = ' ';
  @override
  void initState() {
    super.initState();
    fetchSupplierNamelist();
    fetchPurchaseRecordNo();
    fetchAllProductNames();
    fetchGSTMethod();
    // fetchAndCheckProduct(productName);
    getProductCount(tableData);
    quantityController.text = "0";
    TotalController.text = "0.0";
    discountPercentageController.text = "0";
    taxableController.text = "0.0";
    discountAmountController.text = "0";
    finalAmountController.text = "0.0";
    cgstAmountController.text = "0.0";
    sgstAmountController.text = "0.0";
    rateController.text = "0.0";
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchPurchaseRecordNo(); // Fetch serial number every 10 sec
    });
    _timer?.cancel(); // Cancel the timer when the widget is disposed
  }

  final TextEditingController productCountController = TextEditingController();

  TextEditingController purchaseRecordNoController = TextEditingController();
  TextEditingController purchaseInvoiceNoController = TextEditingController();
  TextEditingController purchaseContactNoontroller = TextEditingController();
  TextEditingController purchaseSupplierAgentidController =
      TextEditingController();
  TextEditingController purchaseSuppliergstnoController =
      TextEditingController();

  TextEditingController purchaseGstMethodController = TextEditingController();

  TextEditingController productNameController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController stockcheckController = TextEditingController();

  TextEditingController quantityController = TextEditingController();
  TextEditingController TotalController = TextEditingController();

  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController taxableController = TextEditingController();
  TextEditingController cgstPercentageController = TextEditingController();
  TextEditingController cgstAmountController = TextEditingController();
  TextEditingController sgstPercentageController = TextEditingController();
  TextEditingController sgstAmountController = TextEditingController();
  TextEditingController finalAmountController = TextEditingController();
  TextEditingController ProductCategoryController = TextEditingController();
  String? supplierName;
  // Date value
  DateTime selectedDate = DateTime.now();

  FocusNode productNameFocusNode = FocusNode();
  FocusNode quantityFocusMode = FocusNode();
  FocusNode DisAmtFocusMode = FocusNode();
  FocusNode DisPercFocusMode = FocusNode();
  FocusNode FinalAmtFocusMode = FocusNode();
  FocusNode saveButtonFocusNode = FocusNode();
  FocusNode InvoiceNooFocustNode = FocusNode();
  FocusNode SupplierNameFocustNode = FocusNode();
  FocusNode DateFocustNode = FocusNode();
  FocusNode finaldiscountPercFocusNode = FocusNode();

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  String PurchaserecordNo = '';
  Future<void> fetchPurchaseRecordNo() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      if (cusid == null) {
        throw Exception('Customer ID is null');
      }

      final response =
          await http.get(Uri.parse('$IpAddress/Purchase_serialNo/$cusid/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Use safe type casting and provide a default value if serialNo is null or not an integer
        int currentPayno = (jsonData['serialNo'] as int?) ??
            0; // Default to 0 if null or not an int
        int nextPayno = currentPayno + 1;

        setState(() {
          purchaseRecordNoController.text = nextPayno.toString();
        });

        // print("Purchase Serial No: ${purchaseRecordNoController.text}");
        // print("Purchase cusid No: ${cusid}");
      } else {
        throw Exception('Failed to load serial number: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching purchase record number: $error');
    }
  }

  Future<void> postDataWithIncrementedSerialNo() async {
    // Increment the serial number
    int incrementedSerialNo = int.parse(purchaseRecordNoController.text);

    String? cusid = await SharedPrefs.getCusId();
    // Prepare the data to be sent
    Map<String, dynamic> postData = {
      "cusid": "$cusid",
      "serialno": incrementedSerialNo,
    };

    // Convert the data to JSON format
    String jsonData = jsonEncode(postData);

    print("serialno : $incrementedSerialNo");

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
        fetchPurchaseRecordNo();
      } else {
        // print('Response body: ${response.statusCode}');
        fetchPurchaseRecordNo();
      }
    } catch (e) {
      print('Failed to post data. Error: $e');
      fetchPurchaseRecordNo();
    }
    fetchPurchaseRecordNo();
  }

  void ShowBillnoIncreaeMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.question_mark_rounded, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Expanded(
                // Use Expanded to allow text to take available space
                child: Text(
                  'Do you want to increase your Purchase Record No?...',
                  style: TextStyle(fontSize: 12, color: maincolor),
                  maxLines: 2, // Limit the number of lines
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if overflow occurs
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
                    // incrementAndInsert();
                    postDataWithIncrementedSerialNo();
                    Navigator.of(context).pop(true);
                    fetchPurchaseRecordNo();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize: Size(30.0, 20.0), // Set width and height
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(color: sidebartext, fontSize: 11),
                  ),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    fetchPurchaseRecordNo();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: maincolor,
                    minimumSize: Size(30.0, 23.0), // Set width and height
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(color: sidebartext, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // void ShowBillnoIncreaeMessage() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  //         content: Row(
  //           children: [
  //             IconButton(
  //               icon: Icon(Icons.question_mark_rounded, color: maincolor),
  //               onPressed: () => Navigator.of(context).pop(false),
  //             ),
  //             Text(
  //               'Do you want to increase your Purchase Record No?...',
  //               style: TextStyle(fontSize: 12, color: maincolor),
  //               maxLines: 2, // Limit the number of lines
  //               overflow:
  //                   TextOverflow.ellipsis, // Add ellipsis if overflow occurs
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // incrementAndInsert();
  //                   postDataWithIncrementedSerialNo();

  //                   Navigator.of(context).pop(true);
  //                   fetchPurchaseRecordNo();
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(2.0),
  //                   ),
  //                   backgroundColor: maincolor,
  //                   minimumSize: Size(30.0, 20.0), // Set width and height
  //                 ),
  //                 child: Text('Yes',
  //                     style: TextStyle(color: sidebartext, fontSize: 11)),
  //               ),
  //               SizedBox(width: 5),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   fetchPurchaseRecordNo();
  //                   Navigator.of(context).pop(true);
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(2.0),
  //                   ),
  //                   backgroundColor: maincolor,
  //                   minimumSize: Size(30.0, 23.0), // Set width and height
  //                 ),
  //                 child: Text('No',
  //                     style: TextStyle(color: sidebartext, fontSize: 11)),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    double desktopcontainerdwidth = MediaQuery.of(context).size.width * 0.14;

    bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 15 : 0, top: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: Responsive.isDesktop(context) ? 0 : 20),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Purchase Entry", style: HeadingStyle)
                              ],
                            ),
                            if (Responsive.isDesktop(context))
                              Padding(
                                padding: EdgeInsets.only(left: 00, right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () async {
                                          String? role = await getrole();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => sidebar(
                                                      onItemSelected:
                                                          (content) {},
                                                      settingsproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductcategory,
                                                      settingsproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsproductdetails,
                                                      settingsgstdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsgstdetails,
                                                      settingsstaffdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingsstaffdetails,
                                                      settingspaymentmethod:
                                                          role == 'admin'
                                                              ? true
                                                              : settingspaymentmethod,
                                                      settingsaddsalespoint:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsaddsalespoint,
                                                      settingsprinterdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : settingsprinterdetails,
                                                      settingslogindetails: role ==
                                                              'admin'
                                                          ? true
                                                          : settingslogindetails,
                                                      purchasenewpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchasenewpurchase,
                                                      purchaseeditpurchase: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseeditpurchase,
                                                      purchasepaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchasepaymentdetails,
                                                      purchaseproductcategory:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductcategory,
                                                      purchaseproductdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : purchaseproductdetails,
                                                      purchaseCustomer: role ==
                                                              'admin'
                                                          ? true
                                                          : purchaseCustomer,
                                                      salesnewsales:
                                                          role == 'admin'
                                                              ? true
                                                              : salesnewsale,
                                                      saleseditsales:
                                                          role == 'admin'
                                                              ? true
                                                              : saleseditsales,
                                                      salespaymentdetails: role ==
                                                              'admin'
                                                          ? true
                                                          : salespaymentdetails,
                                                      salescustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : salescustomer,
                                                      salestablecount:
                                                          role == 'admin'
                                                              ? true
                                                              : salestablecount,
                                                      quicksales:
                                                          role == 'admin'
                                                              ? true
                                                              : quicksales,
                                                      ordersalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesnew,
                                                      ordersalesedit:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalesedit,
                                                      ordersalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : ordersalespaymentdetails,
                                                      vendorsalesnew:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalesnew,
                                                      vendorsalespaymentdetails:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorsalespaymentdetails,
                                                      vendorcustomer:
                                                          role == 'admin'
                                                              ? true
                                                              : vendorcustomer,
                                                      stocknew: role == 'admin'
                                                          ? true
                                                          : stocknew,
                                                      wastageadd:
                                                          role == 'admin'
                                                              ? true
                                                              : wastageadd,
                                                      kitchenusagesentry: role ==
                                                              'admin'
                                                          ? true
                                                          : kitchenusagesentry,
                                                      report: role == 'admin'
                                                          ? true
                                                          : report,
                                                      daysheetincomeentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetincomeentry,
                                                      daysheetexpenseentry: role ==
                                                              'admin'
                                                          ? true
                                                          : daysheetexpenseentry,
                                                      daysheetexepensescategory:
                                                          role == 'admin'
                                                              ? true
                                                              : daysheetexepensescategory,
                                                      graphsales:
                                                          role == 'admin'
                                                              ? true
                                                              : graphsales,
                                                    )),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   children: [
                            //     SizedBox(
                            //       width: 60,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 2, // Set the spacing between lines
                      children: [
                        //  Record No
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                // child: Text("Record No",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 10),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextField(
                                          "RecordNo",
                                          purchaseRecordNoController,
                                          Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14 // Width for desktop
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42, // Width for mobile
                                          Icons.inventory_rounded,
                                          null,
                                          null,

                                          context: context,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0),
                                        child: InkWell(
                                          onTap: () {
                                            ShowBillnoIncreaeMessage();
                                          },
                                          child: Container(
                                            height: 32,
                                            decoration:
                                                BoxDecoration(color: subcolor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              child: Center(
                                                child: Text(
                                                  "+",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
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
//                          // Invoice No
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 5,
                                    top: 8),
                                // child: Text("Invoice No",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.14
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                          'Invoice No',
                                          purchaseInvoiceNoController,
                                          Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14 // Width for desktop
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42, // Width for mobile,
                                          Icons.numbers_rounded,
                                          InvoiceNooFocustNode,
                                          SupplierNameFocustNode,
                                          context: context)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Supplier Name
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 15),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width * 0.14
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                            child:
                                                _buildSupplierNameDropdown()),
                                        // SizedBox(width: 3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Contact No
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                                // child: Text("Contact No",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                          'Contact No',
                                          purchaseContactNoontroller,
                                          Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14 // Width for desktop
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42, // Width for mobile,
                                          Icons.call,
                                          null,
                                          null,
                                          context: context,
                                          isNumeric: true)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                // child:
                                //     Text("Date", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 6),
                                child: Container(
                                  height:
                                      35, // Adjust height for proper alignment
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
                                    borderRadius: BorderRadius.circular(
                                        6), // Optional: make the border rounded
                                  ),

                                  width: Responsive.isDesktop(context)
                                      ? MediaQuery.of(context).size.width *
                                          0.14 // Width for desktop
                                      : MediaQuery.of(context).size.width *
                                          0.42,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              focusNode: DateFocustNode,
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) =>
                                                  _fieldFocusChange(
                                                      context,
                                                      DateFocustNode,
                                                      productNameFocusNode),
                                              initialValue:
                                                  DateTime.now().toString(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                              dateLabelText: '',
                                              onChanged: (val) => print(val),
                                              validator: (val) {
                                                print(val);
                                                return null;
                                              },
                                              onSaved: (val) => print(val),
                                              style:
                                                  textStyle, // Font size can be adjusted as needed
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
                              ),
                            ],
                          ),
                        ),

                        //  Gst Method
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 5,
                                    top: 8),
                                // child: Text("GST Method",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'GST Method',
                                        purchaseGstMethodController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.type_specimen_outlined,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Product Name
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    width: Responsive.isDesktop(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.14
                                        : MediaQuery.of(context).size.width *
                                            0.42,
                                    child: Column(
                                      children: [
                                        _buildProduct5NameDropdown(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  Rate
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                                // child:
                                //     Text("Rate", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Rate',
                                        rateController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.currency_rupee,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quantity
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 20,
                                    top: 8),
                                // child: Text("Quantity",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      // Icon(
                                      //   Icons.production_quantity_limits,
                                      //   size: 15,
                                      // ),
                                      // SizedBox(
                                      //   width: 5,
                                      // ),

                                      buildTextField(
                                        'Quantity',
                                        quantityController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.production_quantity_limits,
                                        quantityFocusMode,
                                        DisPercFocusMode,
                                        context: context,
                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updateTotal();
                                          updatediscountamt();
                                          updatediscountpercentage();
                                          updatetaxableamount();
                                          updateCGSTAmount();
                                          updateSGSTAmount();
                                          updateFinalAmount();
                                        },
                                      )
                                      // Container(
                                      //   height: 24,
                                      //   width: Responsive.isDesktop(context)
                                      //       ? desktoptextfeildwidth
                                      //       : MediaQuery.of(context)
                                      //               .size
                                      //               .width *
                                      //           0.32,
                                      //   color: Colors.grey[200],
                                      // child: Focus(
                                      //   onKey: (FocusNode node,
                                      //       RawKeyEvent event) {
                                      //     if (event is RawKeyDownEvent) {
                                      //       if (event.logicalKey ==
                                      //           LogicalKeyboardKey
                                      //               .arrowDown) {
                                      //         FocusScope.of(context).requestFocus(
                                      //             finaldiscountPercFocusNode);
                                      //         return KeyEventResult.handled;
                                      //       } else if (event.logicalKey ==
                                      //           LogicalKeyboardKey.enter) {
                                      //         FocusScope.of(context)
                                      //             .requestFocus(
                                      //                 DisPercFocusMode);
                                      //         return KeyEventResult.handled;
                                      //       }
                                      //     }
                                      //     return KeyEventResult.ignored;
                                      //   },
                                      //     child: TextFormField(
                                      //         focusNode: quantityFocusMode,
                                      //         textInputAction:
                                      //             TextInputAction.next,
                                      //         controller: quantityController,
                                      //         onFieldSubmitted: (_) {
                                      //           _fieldFocusChange(
                                      //             context,
                                      //             quantityFocusMode,
                                      //             DisPercFocusMode,
                                      //           );
                                      //         },
                                      // onChanged: (newValue) {
                                      //   // quantityController.text = newValue;
                                      //   updateTotal();
                                      //   updatediscountamt();
                                      //   updatediscountpercentage();
                                      //   updatetaxableamount();
                                      //   updateCGSTAmount();
                                      //   updateSGSTAmount();
                                      //   updateFinalAmount();
                                      // },
                                      //         decoration: InputDecoration(
                                      //           enabledBorder:
                                      //               OutlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color:
                                      //                     const Color.fromARGB(
                                      //                         0, 255, 255, 255),
                                      //                 width: 1.0),
                                      //           ),
                                      //           focusedBorder:
                                      //               OutlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.black,
                                      //                 width: 1.0),
                                      //           ),
                                      //           contentPadding:
                                      //               EdgeInsets.symmetric(
                                      //             vertical: 4.0,
                                      //             horizontal: 7.0,
                                      //           ),
                                      //         ),
                                      //         style: textStyle),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Total
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                                // child:
                                //     Text("Total", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Total',
                                        TotalController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.attach_money_rounded,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                        onChangedCallback: (_) => updateTotal(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Discount Percentage
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 20,
                                    top: 8),
                                // child: Text("Discount %",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Discount %',
                                        discountPercentageController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.percent,
                                        DisPercFocusMode,
                                        DisAmtFocusMode,
                                        context: context,

                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updatediscountamt();
                                          updatetaxableamount();
                                          updateCGSTAmount();
                                          updateSGSTAmount();
                                          updateFinalAmount();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Discount Amount
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                                // child: Text("Discount ₹",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Discount ₹',
                                        discountAmountController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.discount_outlined,
                                        DisAmtFocusMode,
                                        FinalAmtFocusMode,
                                        context: context,

                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updatediscountpercentage();
                                          updatetaxableamount();
                                          updateCGSTAmount();
                                          updateSGSTAmount();
                                          updateFinalAmount();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Taxable Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 20,
                                    top: 8),
                                // child: Text("Taxable ₹",
                                //     style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 30 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Taxable ₹',
                                        taxableController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.payment_outlined,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updateCGSTAmount();
                                          updateSGSTAmount();
                                          updateFinalAmount();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //cgst
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                                // child:
                                //     Text("CGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 20 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'CGST ₹',
                                        cgstAmountController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.currency_rupee,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updateFinalAmount();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sgst Percentage
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 20,
                                    top: 8),
                                // child:
                                //     Text("SGST ₹", style: commonLabelTextStyle),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'SGST ₹',
                                        sgstAmountController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.currency_rupee,
                                        null,
                                        null,
                                        context: context,
                                        isReadOnly: true,
                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          updateFinalAmount();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Final Amount
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 5,
                                    top: 8),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 10,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                        'Final ₹',
                                        finalAmountController,
                                        Responsive.isDesktop(context)
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.14 // Width for desktop
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.42, // Width for mobile,
                                        Icons.paid_outlined,
                                        FinalAmtFocusMode,
                                        saveButtonFocusNode,
                                        context: context,
                                        isReadOnly: true,
                                        onChangedCallback: (newValue) {
                                          // quantityController.text = newValue;
                                          finalAmountController.text = newValue;
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //stock
                        Container(
                          // color: Subcolor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 10 : 20,
                                    top: 8),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        Responsive.isDesktop(context) ? 15 : 25,
                                    top: 8),
                                child: Container(
                                  width: Responsive.isDesktop(context)
                                      ? desktopcontainerdwidth
                                      : MediaQuery.of(context).size.width *
                                          0.42, // Width for mobile,
                                  child: Row(
                                    children: [
                                      buildTextField(
                                          'Add Stock',
                                          AddStockController,
                                          Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.14 // Width for desktop
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42, // Width for mobile,
                                          Icons.paid_outlined,
                                          null,
                                          null,
                                          context: context,
                                          isReadOnly: true,
                                          onChangedCallback: (newValue) {
                                        // quantityController.text = newValue;
                                        AddStockController.text = newValue;
                                      })
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (Responsive.isDesktop(context))
                          Container(
                            // color: Subcolor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(""),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isDesktop(context)
                                          ? 20
                                          : 10,
                                      bottom: 30,
                                      top: 2),
                                  child: Container(
                                    width:
                                        Responsive.isDesktop(context) ? 60 : 60,
                                    child: ElevatedButton(
                                      focusNode: saveButtonFocusNode,
                                      onPressed: () {
                                        saveData();
                                        FocusScope.of(context)
                                            .requestFocus(productNameFocusNode);

                                        getFinalAmtCGST0(tableData);
                                        // getProductCount(tableData);
                                        // getTotalTaxable(tableData);
                                        // gettaxableAmtSGST0(tableData);
                                        // gettaxableAmtSGST25(tableData);
                                        // gettaxableAmtSGST6(tableData);
                                        // gettaxableAmtSGST9(tableData);
                                        // gettaxableAmtSGST14(tableData);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                        ),
                                        backgroundColor: subcolor,
                                        minimumSize: Size(
                                            45.0, 31.0), // Set width and height
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 10.0),
                                      ),
                                      child: Text('Add',
                                          style: commonWhiteStyle.copyWith(
                                              fontSize: 14)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (!Responsive.isDesktop(context))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // color: Subcolor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isDesktop(context)
                                              ? 40
                                              : 30,
                                          top: 15),
                                      child: Container(
                                        width: Responsive.isDesktop(context)
                                            ? 60
                                            : 60,
                                        child: ElevatedButton(
                                          focusNode: saveButtonFocusNode,
                                          onPressed: () {
                                            saveData();
                                            FocusScope.of(context).requestFocus(
                                                productNameFocusNode);

                                            getFinalAmtCGST0(tableData);
                                            // getProductCount(tableData);
                                            // getTotalTaxable(tableData);
                                            // gettaxableAmtSGST0(tableData);
                                            // gettaxableAmtSGST25(tableData);
                                            // gettaxableAmtSGST6(tableData);
                                            // gettaxableAmtSGST9(tableData);
                                            // gettaxableAmtSGST14(tableData);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
                                              ),
                                              backgroundColor: subcolor,
                                              minimumSize: Size(
                                                  Responsive.isDesktop(context)
                                                      ? 45.0
                                                      : 30,
                                                  Responsive.isDesktop(context)
                                                      ? 31.0
                                                      : 25), // Set width and height
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 16.0)),
                                          child: Text('Add',
                                              style: commonWhiteStyle.copyWith(
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // Container(
                        //   // color: Subcolor,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 0, top: 8),
                        //         child: Text(
                        //           "",
                        //           style: TextStyle(fontSize: 13),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: EdgeInsets.only(
                        //             left:
                        //                 Responsive.isDesktop(context) ? 20 : 15,
                        //             top: 0),
                        //         child: Container(
                        //           width:
                        //               Responsive.isDesktop(context) ? 70 : 70,
                        //           child: ElevatedButton(
                        //             onPressed: () {
                        //               // Handle form submission
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
                        //             child: Text(
                        //               'Delete',
                        //               style: TextStyle(
                        //                 color: Colors.white,
                        //                 fontSize: 12,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // // if (!Responsive.isDesktop(context))
                        //   SizedBox(width: 150),
                        // if (Responsive.isDesktop(context)) SizedBox(width: 220),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 30.0),
                        //   child: Container(
                        //     height: 30,
                        //     width: 130,
                        //     child: TextField(
                        //       onChanged: (value) {
                        //         setState(() {
                        //           searchText = value;
                        //         });
                        //       },
                        //       decoration: InputDecoration(
                        //         labelText: 'Search',
                        //         suffixIcon: Icon(
                        //           Icons.search,
                        //           color: Colors.grey,
                        //         ),
                        //         floatingLabelBehavior:
                        //             FloatingLabelBehavior.never,
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //           borderRadius: BorderRadius.circular(1),
                        //         ),
                        //         contentPadding:
                        //             EdgeInsets.only(left: 10.0, right: 4.0),
                        //       ),
                        //       style: TextStyle(fontSize: 13),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    if (!Responsive.isDesktop(context)) SizedBox(height: 25),
                    Responsive.isDesktop(context)
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Container(child: tableView())),
                              Expanded(
                                flex: 1,
                                child: PurchaseDiscountForm(
                                    finaldiscountPercFocusNode:
                                        finaldiscountPercFocusNode,
                                    clearTableData: clearTableData,
                                    recordonorefresh: recordonorefresh,
                                    tableData: tableData,
                                    getProductCountCallback: getProductCount,
                                    getTotalQuantityCallback: getTotalQuantity,
                                    getTotalTaxableCallback: getTotalTaxable,
                                    getTotalFinalTaxableCallback:
                                        getTotalFinalTaxable,
                                    getTotalCGSTAmtCallback: getTotalCGSTAmt,
                                    getTotalSGSTAMtCallback: getTotalSGSTAmt,
                                    getTotalFinalAmtCallback: getTotalFinalAmt,
                                    getTotalAmtCallback: getTotalAmt,
                                    getProductDiscountCallBack:
                                        getProductZDiscount,
                                    gettaxableAmtCGST0callback:
                                        gettaxableAmtCGST0,
                                    gettaxableAmtCGST25callback:
                                        gettaxableAmtCGST25,
                                    gettaxableAmtCGST6callback:
                                        gettaxableAmtCGST6,
                                    gettaxableAmtCGST9callback:
                                        gettaxableAmtCGST9,
                                    gettaxableAmtCGST14callback:
                                        gettaxableAmtCGST14,
                                    gettaxableAmtSGST0callback:
                                        gettaxableAmtSGST0,
                                    gettaxableAmtSGST25callback:
                                        gettaxableAmtSGST25,
                                    gettaxableAmtSGST6callback:
                                        gettaxableAmtSGST6,
                                    gettaxableAmtSGST9callback:
                                        gettaxableAmtSGST9,
                                    gettaxableAmtSGST14callback:
                                        gettaxableAmtSGST14,
                                    getFinalAmtCGST0callback: getFinalAmtCGST0,
                                    getFinalAmtCGST25callback:
                                        getFinalAmtCGST25,
                                    getFinalAmtCGST6callback: getFinalAmtCGST6,
                                    getFinalAmtCGST9callback: getFinalAmtCGST9,
                                    getFinalAmtCGST14callback:
                                        getFinalAmtCGST14,
                                    getFinalAmtSGST0callback: getFinalAmtSGST0,
                                    getFinalAmtSGST25callback:
                                        getFinalAmtSGST25,
                                    getFinalAmtSGST6callback: getFinalAmtSGST6,
                                    getFinalAmtSGST9callback: getFinalAmtSGST9,
                                    getFinalAmtSGST14callback:
                                        getFinalAmtSGST14,
                                    purchaseRecordNoController:
                                        purchaseRecordNoController,
                                    purchaseInvoiceNoController:
                                        purchaseInvoiceNoController,
                                    purchaseGSTMethodController:
                                        purchaseGstMethodController,
                                    purchaseContactController:
                                        purchaseContactNoontroller,
                                    purchaseSupplierAgentidController:
                                        purchaseSupplierAgentidController,
                                    purchaseSuppliergstnoController:
                                        purchaseSuppliergstnoController,
                                    purchaseSupplierNameController:
                                        SupplierNameController,
                                    ProductCategoryController:
                                        productCountController,
                                    selectedDate: selectedDate),
                              )
                            ],
                          )
                        : Column(
                            children: [
                              Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  tableView(),
                                ],
                              )),
                              if (!Responsive.isDesktop(context))
                                SizedBox(height: 30),
                              PurchaseDiscountForm(
                                finaldiscountPercFocusNode:
                                    finaldiscountPercFocusNode,
                                tableData: tableData,
                                recordonorefresh: recordonorefresh,
                                getProductCountCallback: getProductCount,
                                getTotalQuantityCallback: getTotalQuantity,
                                getTotalTaxableCallback: getTotalTaxable,
                                getTotalFinalTaxableCallback:
                                    getTotalFinalTaxable,
                                getTotalCGSTAmtCallback: getTotalCGSTAmt,
                                getTotalSGSTAMtCallback: getTotalSGSTAmt,
                                getTotalFinalAmtCallback: getTotalFinalAmt,
                                getTotalAmtCallback: getTotalAmt,
                                getProductDiscountCallBack: getProductZDiscount,
                                gettaxableAmtCGST0callback: gettaxableAmtCGST0,
                                gettaxableAmtCGST25callback:
                                    gettaxableAmtCGST25,
                                gettaxableAmtCGST6callback: gettaxableAmtCGST6,
                                gettaxableAmtCGST9callback: gettaxableAmtCGST9,
                                gettaxableAmtCGST14callback:
                                    gettaxableAmtCGST14,
                                gettaxableAmtSGST0callback: gettaxableAmtSGST0,
                                gettaxableAmtSGST25callback:
                                    gettaxableAmtSGST25,
                                gettaxableAmtSGST6callback: gettaxableAmtSGST6,
                                gettaxableAmtSGST9callback: gettaxableAmtSGST9,
                                gettaxableAmtSGST14callback:
                                    gettaxableAmtSGST14,
                                getFinalAmtCGST0callback: getFinalAmtCGST0,
                                getFinalAmtCGST25callback: getFinalAmtCGST25,
                                getFinalAmtCGST6callback: getFinalAmtCGST6,
                                getFinalAmtCGST9callback: getFinalAmtCGST9,
                                getFinalAmtCGST14callback: getFinalAmtCGST14,
                                getFinalAmtSGST0callback: getFinalAmtSGST0,
                                getFinalAmtSGST25callback: getFinalAmtSGST25,
                                getFinalAmtSGST6callback: getFinalAmtSGST6,
                                getFinalAmtSGST9callback: getFinalAmtSGST9,
                                getFinalAmtSGST14callback: getFinalAmtSGST14,
                                purchaseRecordNoController:
                                    purchaseRecordNoController,
                                purchaseInvoiceNoController:
                                    purchaseInvoiceNoController,
                                purchaseGSTMethodController:
                                    purchaseGstMethodController,
                                purchaseContactController:
                                    purchaseContactNoontroller,
                                purchaseSupplierAgentidController:
                                    purchaseSupplierAgentidController,
                                purchaseSuppliergstnoController:
                                    purchaseSuppliergstnoController,
                                purchaseSupplierNameController:
                                    SupplierNameController,
                                ProductCategoryController:
                                    productCountController,
                                selectedDate: selectedDate,
                                clearTableData: clearTableData,
                              )
                            ],
                          )
                  ],
                ),
              ),
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

  void recordonorefresh() {
    fetchPurchaseRecordNo();
    setState(() {
      SupplierselectedValue = '';
      SupplierNameController.clear();
    });
  }

  void updateTotal() {
    double rate = double.tryParse(rateController.text) ?? 0;
    double quantity = double.tryParse(quantityController.text) ?? 0;
    double total = rate * quantity;
    TotalController.text =
        total.toStringAsFixed(2); // Format total to 2 decimal places
  }

  void updatediscountamt() {
    double total = double.tryParse(TotalController.text) ?? 0;

    double discountPercentage =
        double.tryParse(discountPercentageController.text) ?? 0;
    double discountAmount = (total * discountPercentage) / 100;
    discountAmountController.text = discountAmount.toStringAsFixed(2);
  }

  void updatediscountpercentage() {
    double total = double.tryParse(TotalController.text) ?? 0;

    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double discountPercentage = (discountAmount * 100) / total;
    discountPercentageController.text = discountPercentage.toStringAsFixed(2);
  }

  void updatetaxableamount() {
    double total = double.tryParse(TotalController.text) ?? 0;
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;
    double cgstAmount = double.tryParse(cgstAmountController.text) ?? 0;
    double sgstAmount = double.tryParse(sgstAmountController.text) ?? 0;
    double cgstPercentage = double.tryParse(cgstPercentageController.text) ?? 0;
    double sgstPercentage = double.tryParse(sgstPercentageController.text) ?? 0;

    double numeratorPart1 = total - discountAmount;

    if (purchaseGstMethodController.text == "Excluding") {
      // Calculate taxable amount excluding GST
      double taxableAmount = numeratorPart1;
      taxableController.text = taxableAmount.toStringAsFixed(2);
    } else if (purchaseGstMethodController.text == "Including") {
      double cgstsgst = cgstPercentage + sgstPercentage;
      double cgstnumerator = numeratorPart1 * cgstPercentage;
      double cgstdenominator = 100 + cgstsgst;
      double cgsttaxable = cgstnumerator / cgstdenominator;
      double sgstnumerator = numeratorPart1 * sgstPercentage;
      double sgstdenominator = 100 + cgstsgst;
      double sgsttaxable = sgstnumerator / sgstdenominator;

      double taxableAmount = numeratorPart1 - (cgsttaxable + sgsttaxable);

      taxableController.text = taxableAmount.toStringAsFixed(2);
      // print("cgst taxable amount : $cgsttaxable");
      // print("sgst taxable amount : $sgsttaxable");
      // print("Total taxable amount : $taxableAmount");
    } else {
      double taxableAmount = numeratorPart1;
      taxableController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  void updateFinalAmount() {
    double total = double.tryParse(TotalController.text) ?? 0;
    double discountAmount = double.tryParse(discountAmountController.text) ?? 0;

    double cgstAmount = double.tryParse(cgstAmountController.text) ?? 0;
    double sgstAmount = double.tryParse(sgstAmountController.text) ?? 0;
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double denominator = cgstAmount + sgstAmount;

    if (purchaseGstMethodController.text == "Excluding") {
      double finalAmount = taxableAmount + denominator;

      // Update the final amount controller
      finalAmountController.text = finalAmount.toStringAsFixed(2);
    } else if (purchaseGstMethodController.text == "Including") {
      double totalfinalamount = total - discountAmount;
      finalAmountController.text = totalfinalamount.toStringAsFixed(2);
    } else {
      double taxableAmount = total - discountAmount;
      finalAmountController.text = taxableAmount.toStringAsFixed(2);
    }
  }

  void updateCGSTAmount() {
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double cgstPercentage = double.tryParse(cgstPercentageController.text) ?? 0;
    double numerator = (taxableAmount * cgstPercentage);
    // Calculate the CGST amount
    double cgstAmount = numerator / 100;

    // Update the CGST amount controller
    cgstAmountController.text = cgstAmount.toStringAsFixed(2);
  }

  void updateSGSTAmount() {
    double taxableAmount = double.tryParse(taxableController.text) ?? 0;
    double sgstPercentage = double.tryParse(sgstPercentageController.text) ?? 0;
    double numerator = (taxableAmount * sgstPercentage);
    // Calculate the CGST amount
    double sgstAmount = numerator / 100;

    // Update the CGST amount controller
    sgstAmountController.text = sgstAmount.toStringAsFixed(2);
  }

  Future<void> fetchCGSTPercentages() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalAmount = 0; // Initialize total amount to 0

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if product name matches
        if (entry['name'] == ProductNameController.text) {
          // Parse and accumulate the amount
          double amount = double.parse(entry['cgstperc'] ?? '0');
          totalAmount += amount;
        }
      }

      // Update cgstPercentageController with the fetched value
      cgstPercentageController.text = totalAmount.toString();

      // Enable the corresponding button based on the fetched value
      setState(() {
        isCGSTSelected = ['0', '2.5', '6', '9', '14']
            .map((value) => value == cgstPercentageController.text)
            .toList();
      });

      // Print the total amount after the loop
      // print(
      //     "CGST percentage of the ${ProductNameController.text} is ${cgstPercentageController.text}");
    }
  }

  Future<void> fetchSGSTPercentages() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    double totalAmount = 0; // Initialize total amount to 0

    if (jsonData['results'] != null) {
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(jsonData['results']);

      // Iterate through each entry in the results
      for (var entry in results) {
        // Check if product name matches
        if (entry['name'] == ProductNameController.text) {
          // Parse and accumulate the amount
          double amount = double.parse(entry['sgstperc'] ?? '0');
          totalAmount += amount;
        }
      }

      // Update cgstPercentageController with the fetched value
      sgstPercentageController.text = totalAmount.toString();

      // Enable the corresponding button based on the fetched value
      setState(() {
        isSGSTSelected = ['0', '2.5', '6', '9', '14']
            .map((value) => value == sgstPercentageController.text)
            .toList();
      });

      // Print the total amount after the loop
      // print(
      //     "SGST percentage of the ${ProductNameController.text} is ${sgstPercentageController.text}");
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
      if (entry['name'] == "Purchase") {
        // Retrieve the GST method for "Sales"
        gstMethod = entry['gst'];
        break; // Exit the loop once the entry is found
      }
    }

    // Update rateController if needed
    if (gstMethod.isNotEmpty) {
      purchaseGstMethodController.text = gstMethod;
      // print("GST method for Sales: $gstMethod");
    } else {
      // print("No GST method found for Sales");
    }
  }

  Future<void> fetchSupplierContact() async {
    String? cusid = await SharedPrefs.getCusId();
    String baseUrl = '$IpAddress/PurchaseSupplierNames/$cusid/';
    String supplierName = SupplierNameController.text;
    bool contactFound = false;

    try {
      String url = baseUrl;

      while (!contactFound) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          // Iterate through each supplier entry
          for (var entry in results) {
            if (entry['name'] == supplierName) {
              // Retrieve the contact number for the supplier
              String contactno = entry['contact'];
              String agentId = entry['id'].toString();
              String gstNo = entry['gstno'];
              if (contactno.isNotEmpty) {
                purchaseContactNoontroller.text = contactno;
                purchaseSupplierAgentidController.text = agentId;
                purchaseSuppliergstnoController.text = gstNo;
                // print("Contact number for $supplierName: $contactno");
                contactFound = true;
                break; // Exit the loop once the contact number is found
              }
            }
          }

          // Check if there are more pages
          if (!contactFound && data['next'] != null) {
            url = data['next'];
          } else {
            // Exit the loop if no more pages or contact number found
            break;
          }
        } else {
          throw Exception(
              'Failed to load supplier contact information: ${response.reasonPhrase}');
        }
      }

      // Print a message if contact number not found
      if (!contactFound) {
        print("No contact number found for $supplierName");
      }
    } catch (e) {
      print('Error fetching supplier contact information: $e');
    }
  }

  Future<void> fetchProductAmount() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    double totalAmount = 0; // Initialize total amount to 0
    String totalAddStock = ''; // Initialize total add stock as an empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      // Construct the URL with the current page number
      String url = '$apiUrl?page=$page';

      // Make the HTTP GET request
      http.Response response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      // Check if results exist
      if (jsonData['results'] != null) {
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(jsonData['results']);

        // Iterate through each entry in the results
        for (var entry in results) {
          // Check if product name matches
          if (entry['name'] == ProductNameController.text) {
            // Parse and accumulate the amount
            double amount = double.parse(entry['amount'] ?? '0');
            totalAmount += amount;

            // Extract addstock as a string
            String addstockString = entry['addstock'] ?? '0';

            // Append addstockString to totalAddStock
            totalAddStock += addstockString;
          }
        }

        // Increment page number for next request
        page++;

        // Check if there are more pages
        hasMorePages = jsonData['next'] != null;
      } else {
        // No results found
        hasMorePages = false;
      }
    }

    // Set the rate and stock check controllers' text values
    rateController.text = totalAmount
        .toStringAsFixed(2); // Convert to string with 2 decimal places
    stockcheckController.text = totalAddStock;

    // Print the total amount after fetching all pages
    // print("stock check of ${stockcheckController.text} ");
  }

  Future<void> fetchProductCategory() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    String totalCategory = ''; // Initialize total category to empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        // Construct the URL with the current page number
        String url = '$apiUrl?page=$page';

        // Make the HTTP GET request
        http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          if (jsonData['results'] != null) {
            List<Map<String, dynamic>> results =
                List<Map<String, dynamic>>.from(jsonData['results']);

            // Iterate through each entry in the results
            for (var entry in results) {
              // Check if product name matches
              if (entry['name'] == ProductNameController.text) {
                // Accumulate the categories
                String category = entry['category'] ?? '';
                totalCategory += category + ', ';
              }
            }

            // Check if there are more pages
            if (jsonData['next'] != null) {
              // Increment page number for next request
              page++;
            } else {
              // No more pages, exit the loop
              hasMorePages = false;
            }
          } else {
            // No results found, exit the loop
            hasMorePages = false;
          }
        } else {
          throw Exception(
              'Failed to load product details: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching product category: $e');
        // Exit the loop on error
        hasMorePages = false;
      }
    }

    // Remove the trailing comma and space
    if (totalCategory.isNotEmpty) {
      totalCategory = totalCategory.substring(0, totalCategory.length - 2);
    }

    // Update the ProductCategoryController text
    ProductCategoryController.text = totalCategory;

    // print(
    //     "Product Category Controller text is ${ProductCategoryController.text}");
  }

  List<String> SupplierNameList = [];

  Future<void> fetchSupplierNamelist() async {
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
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController SupplierNameController = TextEditingController();
  String? SupplierselectedValue;

  int? _selectedSuppliernameIndex;

  bool _isSupplierNameOptionsVisible = false;
  int? _SupplierhoveredIndex;

  Widget _buildSupplierNameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          // Icon(
          //   Icons.person_pin_outlined,
          //   size: 18,
          // ),
          // SizedBox(width: 3),
          Container(
            height: 35,
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.12
                : MediaQuery.of(context).size.width * 0.35,
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
                          width: Responsive.isDesktop(context) ? 1150 : 500,
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
                                    fetchSupplierNamelist();
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
                SupplierNameList.indexOf(SupplierNameController.text);
            if (currentIndex < SupplierNameList.length - 1) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex + 1;
                SupplierNameController.text =
                    SupplierNameList[currentIndex + 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                SupplierNameList.indexOf(SupplierNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedSuppliernameIndex = currentIndex - 1;
                SupplierNameController.text =
                    SupplierNameList[currentIndex - 1];
                _isSupplierNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: SupplierNameFocustNode,
          onSubmitted: (String? suggestion) async {
            await fetchSupplierContact();
            _fieldFocusChange(context, SupplierNameFocustNode, DateFocustNode);
          },
          controller: SupplierNameController,
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
              SupplierselectedValue = text.isEmpty ? null : text;
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
                                  SupplierNameController.text) ==
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
            SupplierNameController.text = suggestion!;
            SupplierselectedValue = suggestion;
            _isSupplierNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(DateFocustNode);
          });
          await fetchSupplierContact();
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

  List<String> ProductNameList = [];
  final TextEditingController AddStockController = TextEditingController();

//fetch stock correct code
  Future<void> fetchAddStock() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PurchaseProductDetails/$cusid/';
    String totalStock = ''; // Initialize total stock to empty string

    // Page number starts from 1
    int page = 1;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        // Construct the URL with the current page number
        String url = '$apiUrl?page=$page';

        // Make the HTTP GET request
        http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);

          if (jsonData['results'] != null) {
            List<Map<String, dynamic>> results =
                List<Map<String, dynamic>>.from(jsonData['results']);

            // Iterate through each entry in the results
            for (var entry in results) {
              // Check if product name matches
              if (entry['name'] == ProductNameController.text) {
                // Accumulate the stock details
                String stock = entry['addstock'] ?? '0';
                totalStock = stock;
              }
            }

            // Check if there are more pages
            if (jsonData['next'] != null) {
              // Increment page number for next request
              page++;
            } else {
              // No more pages, exit the loop
              hasMorePages = false;
            }
          } else {
            // No results found, exit the loop
            hasMorePages = false;
          }
        } else {
          throw Exception(
              'Failed to load add stock details: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching add stock: $e');
        // Exit the loop on error
        hasMorePages = false;
      }
    }

    // Update the AddStockController text
    AddStockController.text = totalStock;

    // Optionally print the result for debugging
    // print("AddStockController text is ${AddStockController.text}");
  }

  //stock fetch
  // Future<void> fetchAddStock() async {
  //   try {
  //     String? cusid = await SharedPrefs.getCusId();
  //     String url = '$IpAddress/PurchaseProductDetails/$cusid/';
  //     bool hasNextPage = true;

  //     while (hasNextPage) {
  //       final response = await http.get(Uri.parse(url));

  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> data = jsonDecode(response.body);
  //         final List<dynamic> results = data['results'];

  //         for (var item in results) {
  //           String productName = item['name'].toString();
  //           String addStock =
  //               item['addstock'].toString(); // Fetch the addstock value

  //           // Add product name to the list
  //           ProductNameList.add(productName);

  //           // Print the product name and addstock value
  //           print('Product: $productName, Add Stock: $addStock');
  //         }

  //         hasNextPage = data['next'] != null;
  //         if (hasNextPage) {
  //           url = data['next'];
  //         }
  //       } else {
  //         throw Exception(
  //             'Failed to load categories: ${response.reasonPhrase}');
  //       }
  //     }

  //     // Uncomment this line to print all product names if needed
  //     // print('All product categories: $ProductNameList');
  //   } catch (e) {
  //     print('Error fetching categories: $e');
  //     rethrow; // Rethrow the error to propagate it further
  //   }
  // }

  Future<void> fetchAllProductNames() async {
    try {
      String? cusid = await SharedPrefs.getCusId();
      String url = '$IpAddress/PurchaseProductDetails/$cusid/';
      bool hasNextPage = true;

      while (hasNextPage) {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> results = data['results'];

          ProductNameList.addAll(
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

      // print('All product categories: $ProductNameList');
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow; // Rethrow the error to propagate it further
    }
  }

  TextEditingController ProductNameController = TextEditingController();

  String? selectedProductName;
  bool _isProdNameOptionsVisible = false;

  int? _productnamehoveredIndex;
  int? _selectedProductnameIndex;

  Widget _buildProduct5NameDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(children: [
        Expanded(
          // Use Expanded to ensure it takes up the available width
          child: Container(
            width: MediaQuery.of(context).size.width * 0.14,
            height: 35,
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
              padding: const EdgeInsets.only(left: 0),
              child: ProductNameDropdown(),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: 1300,
                      height: 800,
                      padding: EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          PurchaseProductDetails(),
                          Positioned(
                            right: 0.0,
                            top: 0.0,
                            child: IconButton(
                              icon: Icon(Icons.cancel,
                                  color: Colors.red, size: 23),
                              onPressed: () {
                                Navigator.of(context).pop();
                                fetchAllProductNames();
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
            width: 20,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: subcolor,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
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
      ]),
    );
  }

  // Future<void> fetchAndCheckProduct(String productName) async {
  //   final url = 'http://192.168.10.117:88/Settings_ProductDetails/BTRM_23/';
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final List<dynamic> products = data[
  //           'results']; // Adjust according to the actual response structure

  //       bool productExists = products.any((product) =>
  //           product['name'].toLowerCase() == productName.toLowerCase());

  //       if (productExists) {
  //         print('The product name "$productName" already exists.');
  //       } else {
  //         print('The product name "$productName" does not exist.');
  //       }
  //     } else {
  //       print('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  Widget ProductNameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex < ProductNameList.length - 1) {
              setState(() {
                _selectedProductnameIndex = currentIndex + 1;
                ProductNameController.text = ProductNameList[currentIndex + 1];
                _isProdNameOptionsVisible = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                ProductNameList.indexOf(ProductNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedProductnameIndex = currentIndex - 1;
                ProductNameController.text = ProductNameList[currentIndex - 1];
                _isProdNameOptionsVisible = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: productNameFocusNode,
          onSubmitted: (String? suggestion) async {
            await fetchProductAmount();
            await fetchCGSTPercentages();
            await fetchSGSTPercentages();
            await fetchProductCategory();
            await fetchAddStock();
            _fieldFocusChange(context, productNameFocusNode, quantityFocusMode);
          },
          controller: ProductNameController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.family_restroom_outlined,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'ProdName',
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
              _isProdNameOptionsVisible = true;
              selectedProductName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_isProdNameOptionsVisible && pattern.isNotEmpty) {
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
              _productnamehoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _productnamehoveredIndex = null;
            }),
            child: Container(
              color: _selectedProductnameIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedProductnameIndex == null &&
                          ProductNameList.indexOf(ProductNameController.text) ==
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
          await fetchProductAmount();
          await fetchCGSTPercentages();
          await fetchSGSTPercentages();
          await fetchProductCategory();
          await fetchAddStock();

          setState(() {
            ProductNameController.text = suggestion!;
            selectedProductName = suggestion;
            _isProdNameOptionsVisible = false;

            FocusScope.of(context).requestFocus(quantityFocusMode);
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

// dropdwon with fetch and check
  // Widget ProductNameDropdown() {
  //   return RawKeyboardListener(
  //     focusNode: FocusNode(),
  //     onKey: (RawKeyEvent event) {
  //       if (event is RawKeyDownEvent) {
  //         if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
  //           // Handle arrow down event
  //           int currentIndex =
  //               ProductNameList.indexOf(ProductNameController.text);
  //           if (currentIndex < ProductNameList.length - 1) {
  //             setState(() {
  //               _selectedProductnameIndex = currentIndex + 1;
  //               ProductNameController.text = ProductNameList[currentIndex + 1];
  //               _isProdNameOptionsVisible = false;
  //             });
  //           }
  //         } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
  //           // Handle arrow up event
  //           int currentIndex =
  //               ProductNameList.indexOf(ProductNameController.text);
  //           if (currentIndex > 0) {
  //             setState(() {
  //               _selectedProductnameIndex = currentIndex - 1;
  //               ProductNameController.text = ProductNameList[currentIndex - 1];
  //               _isProdNameOptionsVisible = false;
  //             });
  //           }
  //         }
  //       }
  //     },
  //     child: TypeAheadFormField<String>(
  //       textFieldConfiguration: TextFieldConfiguration(
  //         focusNode: productNameFocusNode,
  //         onSubmitted: (String? suggestion) async {
  //           if (suggestion != null && suggestion.isNotEmpty) {
  //             await fetchAndCheckProduct(suggestion);
  //           }
  //           await fetchProductAmount();
  //           await fetchCGSTPercentages();
  //           await fetchSGSTPercentages();
  //           await fetchProductCategory();
  //           await fetchAddStock();
  //           _fieldFocusChange(context, productNameFocusNode, quantityFocusMode);
  //         },
  //         controller: ProductNameController,
  //         decoration: const InputDecoration(
  //           border: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Colors.black, width: 1.0),
  //           ),
  //           contentPadding: EdgeInsets.only(bottom: 10, left: 5),
  //           labelStyle: DropdownTextStyle,
  //           suffixIcon: Icon(
  //             Icons.keyboard_arrow_down,
  //             size: 18,
  //           ),
  //         ),
  //         style: DropdownTextStyle,
  //         onChanged: (text) async {
  //           setState(() {
  //             _isProdNameOptionsVisible = true;
  //             selectedProductName = text.isEmpty ? null : text;
  //           });
  //         },
  //       ),
  //       suggestionsCallback: (pattern) {
  //         if (_isProdNameOptionsVisible && pattern.isNotEmpty) {
  //           return ProductNameList.where(
  //               (item) => item.toLowerCase().contains(pattern.toLowerCase()));
  //         } else {
  //           return ProductNameList;
  //         }
  //       },
  //       itemBuilder: (context, suggestion) {
  //         final index = ProductNameList.indexOf(suggestion);
  //         return MouseRegion(
  //           onEnter: (_) => setState(() {
  //             _productnamehoveredIndex = index;
  //           }),
  //           onExit: (_) => setState(() {
  //             _productnamehoveredIndex = null;
  //           }),
  //           child: Container(
  //             color: _selectedProductnameIndex == index
  //                 ? Colors.grey.withOpacity(0.3)
  //                 : _selectedProductnameIndex == null &&
  //                         ProductNameList.indexOf(ProductNameController.text) ==
  //                             index
  //                     ? Colors.grey.withOpacity(0.1)
  //                     : Colors.transparent,
  //             height: 28,
  //             child: ListTile(
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 10.0,
  //               ),
  //               dense: true,
  //               title: Padding(
  //                 padding: const EdgeInsets.only(bottom: 5.0),
  //                 child: Text(
  //                   suggestion,
  //                   style: DropdownTextStyle,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //       suggestionsBoxDecoration: const SuggestionsBoxDecoration(
  //         constraints: BoxConstraints(maxHeight: 150),
  //       ),
  //       onSuggestionSelected: (String? suggestion) async {
  //         await fetchProductAmount();
  //         await fetchCGSTPercentages();
  //         await fetchSGSTPercentages();
  //         await fetchProductCategory();
  //         await fetchAddStock();
  //         if (suggestion != null && suggestion.isNotEmpty) {
  //           await fetchAndCheckProduct(suggestion);
  //         }
  //         setState(() {
  //           ProductNameController.text = suggestion!;
  //           selectedProductName = suggestion;
  //           _isProdNameOptionsVisible = false;

  //           FocusScope.of(context).requestFocus(quantityFocusMode);
  //         });
  //       },
  //       noItemsFoundBuilder: (context) => Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Text(
  //           'No Items Found!!!',
  //           style: TextStyle(fontSize: 12, color: Colors.grey),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  void saveData() {
    // Check if any required field is empty
    if (purchaseInvoiceNoController.text.isEmpty ||
        SupplierNameController.text.isEmpty ||
        purchaseContactNoontroller.text.isEmpty ||
        ProductNameController.text.isEmpty ||
        rateController.text.isEmpty ||
        quantityController.text.isEmpty ||
        TotalController.text.isEmpty ||
        discountPercentageController.text.isEmpty ||
        discountAmountController.text.isEmpty ||
        taxableController.text.isEmpty ||
        cgstPercentageController.text.isEmpty ||
        cgstAmountController.text.isEmpty ||
        sgstPercentageController.text.isEmpty ||
        sgstAmountController.text.isEmpty ||
        finalAmountController.text.isEmpty) {
      // Show error message
      WarninngMessage(context);
      return;
    }

    String productName = ProductNameController.text;
    String rate = rateController.text;
    String stockcheck = stockcheckController.text;
    String quantity = quantityController.text;
    String total = TotalController.text;
    String discountPercentage = discountPercentageController.text;
    String discountAmount = discountAmountController.text;
    String taxable = taxableController.text;
    String cgstPercentage = purchaseGstMethodController.text.isEmpty
        ? "0"
        : cgstPercentageController.text;

    String cgstAmount = purchaseGstMethodController.text.isEmpty
        ? "0"
        : cgstAmountController.text;
    String sgstPercentage = purchaseGstMethodController.text.isEmpty
        ? "0"
        : sgstPercentageController.text;
    String sgstAmount = purchaseGstMethodController.text.isEmpty
        ? "0"
        : sgstAmountController.text;
    String finalAmount = finalAmountController.text;
    String stock = AddStockController.text;

    // Check if the product already exists in tableData
    bool found = false;
    for (var item in tableData) {
      if (item['productName'] == productName) {
        // Update quantity
        item['quantity'] =
            (int.parse(item['quantity']) + int.parse(quantity)).toString();
        // Update total, discountpercentage, discountamount, taxableAmount, cgstAmount, sgstAmount, finalAmount
        item['total'] =
            (double.parse(item['total']) + double.parse(total)).toString();
        item['discountpercentage'] = (double.parse(item['discountpercentage']) +
                double.parse(discountPercentage))
            .toString();
        item['discountamount'] = (double.parse(item['discountamount']) +
                double.parse(discountAmount))
            .toString();
        item['taxableAmount'] =
            (double.parse(item['taxableAmount']) + double.parse(taxable))
                .toString();
        item['cgstAmount'] =
            (double.parse(item['cgstAmount']) + double.parse(cgstAmount))
                .toStringAsFixed(2);
        item['sgstAmount'] =
            (double.parse(item['sgstAmount']) + double.parse(sgstAmount))
                .toStringAsFixed(2);
        item['finalAmount'] =
            (double.parse(item['finalAmount']) + double.parse(finalAmount))
                .toString();
        item['addstock'] =
            (double.parse(item['addstock']) + double.parse(stock)).toString();
        found = true;
        break;
      }
    }

    // If the product doesn't exist, add it to tableData
    if (!found) {
      setState(() {
        tableData.add({
          'productName': productName,
          'rate': rate,
          'quantity': quantity,
          "total": total,
          "discountpercentage": discountPercentage,
          "discountamount": discountAmount,
          "taxableAmount": taxable,
          "cgstpercentage": cgstPercentage,
          "cgstAmount": cgstAmount,
          "sgstPercentage": sgstPercentage,
          "sgstAmount": sgstAmount,
          "finalAmount": finalAmount,
          "addstock": stock
        });
      });
    }

    // Clear text controllers
    setState(() {
      // ProductName = null;
      ProductNameController.clear(); // Clear the text field
    });
    rateController.clear();
    quantityController.clear();
    TotalController.clear();
    discountPercentageController.clear();
    discountAmountController.clear();
    taxableController.clear();
    cgstPercentageController.clear();
    cgstAmountController.clear();
    sgstPercentageController.clear();
    sgstAmountController.clear();
    finalAmountController.clear();
    AddStockController.clear();
    isCGSTSelected = [true, false, false, false, false];
    isSGSTSelected = [true, false, false, false, false];
  }

  void _deleteRow(int index) {
    setState(() {
      tableData.removeAt(index);
    });
    successfullyDeleteMessage(context);
  }

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

  void clearTableData() {
    setState(() {
      tableData.clear();
    });
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.68 : 320,
          // height: Responsive.isDesktop(context) ? 350 : 320,
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Container(
                width: Responsive.isDesktop(context)
                    ? MediaQuery.of(context).size.width * 0.77
                    : MediaQuery.of(context).size.width * 1.8,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.fastfood,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 1),
                                  Text("P.Name",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.attach_money,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Rate",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.add_box,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.currency_exchange_outlined,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Total",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.pie_chart,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Dis %",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.monetization_on,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Dis ₹",
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.currency_exchange_outlined,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Taxable",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Flexible(
                        //   child: Container(
                        //     height: Responsive.isDesktop(context) ? 25 : 30,
                        //     width: 265.0,
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey[200],
                        //     ),
                        //     child: Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           // Icon(
                        //           //   Icons.pie_chart,
                        //           //   size: 15,
                        //           //   color: Colors.blue,
                        //           // ),
                        //           // SizedBox(width: 5),
                        //           Text(
                        //             "Cgst%",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.black,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.local_atm,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Cgst %-₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Flexible(
                        //   child: Container(
                        //     height: Responsive.isDesktop(context) ? 25 : 30,
                        //     width: 265.0,
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey[200],
                        //     ),
                        //     child: Center(
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           // Icon(
                        //           //   Icons.pie_chart,
                        //           //   size: 15,
                        //           //   color: Colors.blue,
                        //           // ),
                        //           // SizedBox(width: 5),
                        //           Text(
                        //             "Sgst%",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.black,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        Flexible(
                          child: Container(
                            height: Responsive.isDesktop(context) ? 25 : 30,
                            width: 265.0,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.local_atm,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("Sgst %-₹",
                                      textAlign: TextAlign.center,
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              height: Responsive.isDesktop(context) ? 25 : 30,
                              width: Responsive.isDesktop(context) ? 265.0 : 80,
                              decoration: TableHeaderColor,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon(
                                    //   Icons.attach_money,
                                    //   size: 15,
                                    //   color: Colors.blue,
                                    // ),
                                    // SizedBox(width: 5),
                                    Text("Add Stock",
                                        textAlign: TextAlign.center,
                                        style: commonLabelTextStyle),
                                  ],
                                ),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.attach_money,
                                  //   size: 15,
                                  //   color: Colors.blue,
                                  // ),
                                  // SizedBox(width: 5),
                                  Text("FinAmt",
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
                            width: 100,
                            decoration: TableHeaderColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                  // SizedBox(width: 5),
                                  // Text(
                                  //   "Delete",
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.black,
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tableData.isNotEmpty)
                    ...tableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> data = entry.value;
                      var productName = data['productName'].toString();
                      var rate = data['rate'].toString();
                      var quantity = data['quantity'].toString();
                      var total = data['total'].toString();
                      var discountpercentage =
                          data['discountpercentage'].toString();
                      var discountamount = data['discountamount'].toString();
                      var taxableAmount = data['taxableAmount'].toString();
                      var cgstpercentage = data['cgstpercentage'] ?? 0;

                      var cgstAmount = data['cgstAmount'].toString();
                      var sgstPercentage = data['sgstPercentage'] ?? 0;
                      var sgstAmount = data['sgstAmount'].toString();
                      var finalAmount = data['finalAmount'].toString();
                      var addstock = data['addstock'].toString();
                      // print("stock checkkkk : $addstock");

                      bool isEvenRow = tableData.indexOf(data) % 2 == 0;
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
                                  child: Text(rate,
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
                                width: 265.0,
                                decoration: BoxDecoration(
                                  color: rowColor,
                                  border: Border.all(
                                    color: Color.fromARGB(255, 226, 225, 225),
                                  ),
                                ),
                                child: Center(
                                  child: Text(total,
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
                                  child: Text(discountpercentage,
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
                                  child: Text(discountamount,
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
                                  child: Text(taxableAmount,
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
                                  child: Text(
                                      "${cgstpercentage.toString()}-$cgstAmount", // Convert to string explicitly
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: Container(
                            //     height: 30,
                            //     width: 265.0,
                            //     decoration: BoxDecoration(
                            //       color: rowColor,
                            //       border: Border.all(
                            //         color: Color.fromARGB(255, 226, 225, 225),
                            //       ),
                            //     ),
                            //     child: Center(
                            //       child: Text(
                            //         cgstAmount,
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w400,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                  child: Text(
                                      "${sgstPercentage.toString()}-${sgstAmount}",
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: Container(
                            //     height: 30,
                            //     width: 265.0,
                            //     decoration: BoxDecoration(
                            //       color: rowColor,
                            //       border: Border.all(
                            //         color: Color.fromARGB(255, 226, 225, 225),
                            //       ),
                            //     ),
                            //     child: Center(
                            //       child: Text(
                            //         sgstAmount,
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w400,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                  child: Text(addstock,
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
                                  child: Text(finalAmount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 30,
                                width: 100,
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
                                      // Padding(
                                      //   padding: const EdgeInsets.only(left: 0),
                                      //   child: Container(
                                      //     child: IconButton(
                                      //       icon: Icon(
                                      //         Icons.add,
                                      //         color: Colors.blue,
                                      //         size: 18,
                                      //       ),
                                      //       onPressed: () {
                                      //         print(
                                      //             "Serial No | Date | Product Name | Quantity | Rate | Discount % | Total | CGST % | CGST Amount | SGST % | SGST Amount | Final Amount | DiscountPercentage | Taxable Amount | igstperc | igstamnt | cessperc | cessamnt");

                                      //         // Print data from each row
                                      //         for (var data in tableData) {
                                      //           print(
                                      //               "${purchaseRecordNoController.text} | ${DateFormat('yyyy-MM-dd').format(selectedDate)} | ${data['productName']} | ${data['quantity']} | ${data['rate']} | ${data['discountpercentage']} | ${data['total']} | ${data['cgstpercentage']} | ${data['cgstAmount']} | ${data['sgstPercentage']} | ${data['sgstAmount']} | ${data['finalAmount']}|  ${data['discountamount']} | | ${data['taxableAmount']} 0 | 0 | 0 | 0");
                                      //         }

                                      //         // Call postDataToAPI method after the loop
                                      //         Post__purchaseDetails(
                                      //             tableData,
                                      //             purchaseRecordNoController
                                      //                 .text,
                                      //             selectedDate);
                                      //       },
                                      //       color: Colors.black,
                                      //     ),
                                      //   ),
                                      // ),
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
                    }).toList()
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int getProductCount(List<Map<String, dynamic>> tableData) {
  int count = tableData.length;
  // print('Product count: $count');
  return count;
}

int getTotalQuantity(List<Map<String, dynamic>> tableData) {
  int totalQuantity = 0;
  for (var data in tableData) {
    int quantity = int.tryParse(data['quantity']!) ?? 0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalTaxable(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['taxableAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  // print('Product count: $totalQuantity');

  totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
  return totalQuantity;
}

double getTotalFinalTaxable(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['taxableAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  // print('Product count: $totalQuantity');

  totalQuantity = double.parse(totalQuantity.toStringAsFixed(2));
  return totalQuantity;
}

double getTotalCGSTAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['cgstAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalSGSTAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['sgstAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalFinalAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['finalAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getTotalAmt(List<Map<String, dynamic>> tableData) {
  double totalQuantity = 0.0;
  for (var data in tableData) {
    double quantity = double.tryParse(data['finalAmount']!) ?? 0.0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double gettaxableAmtCGST0(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 0) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST25(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 2.5) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST6(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 6) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST9(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 9) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtCGST14(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage']!);
    if (cgstPercentage != null && cgstPercentage == 14) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }
  }
  return taxableAmount;
}

double gettaxableAmtSGST0(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 0) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 0 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST25(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 2.5) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 2.5 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST6(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 6) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 6 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST9(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 9) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 9 :$taxableAmount ");
  }
  return taxableAmount;
}

double gettaxableAmtSGST14(List<Map<String, dynamic>> tableData) {
  double taxableAmount = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage']!);
    if (cgstPercentage != null && cgstPercentage == 14) {
      // Parse 'taxableAmount' to double before adding it to taxableAmount
      double? parsedTaxableAmount = double.tryParse(data['taxableAmount']);
      if (parsedTaxableAmount != null) {
        taxableAmount += parsedTaxableAmount;
      }
    }

    // print("SGSt 14 :$taxableAmount ");
  }
  return taxableAmount;
}

double getFinalAmtCGST0(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 0) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  // print("Total amount with CGST 0%: $totalAmountCGST0 ");
  return totalAmountCGST0;
}

double getFinalAmtCGST25(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 2.5) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST6(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 6) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST9(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 9) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtCGST14(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['cgstpercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 14) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST0(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 0) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST25(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 2.5) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST6(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 6) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST9(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 9) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getFinalAmtSGST14(List<Map<String, dynamic>> tableData) {
  double totalAmountCGST0 = 0.0;
  for (var data in tableData) {
    double? cgstPercentage = double.tryParse(data['sgstPercentage'] ?? '0');
    double? parsedFinalAmount = double.tryParse(data['finalAmount'] ?? '0');

    if (cgstPercentage != null && cgstPercentage == 14) {
      if (parsedFinalAmount != null) {
        totalAmountCGST0 += parsedFinalAmount;
      }
    }
  }
  return totalAmountCGST0;
}

double getProductZDiscount(List<Map<String, dynamic>> tableData) {
  double totalProductDiscount = 0.0;
  for (var data in tableData) {
    // Parse discountpercentage as a double
    double productDiscount = double.tryParse(data['discountamount']!) ?? 0.0;
    totalProductDiscount += productDiscount;
  }
  return totalProductDiscount;
}
