import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(OrderSalesReport());
}

class OrderSalesReport extends StatefulWidget {
  @override
  State<OrderSalesReport> createState() => _OrderSalesReportState();
}

class _OrderSalesReportState extends State<OrderSalesReport> {
  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;
  int currentPage = 1;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalPages = 1;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchdatewiseaOrdersales() async {
    String startdt = _StartDateController.text;
    String enddt = _EndDateController.text;

    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    endDate = endDate.add(Duration(days: 1));

    String foramtedletterstartdt = DateFormat('d MMMM,yyyy').format(startDate);
    String foramtedletterenddt = DateFormat('d MMMM,yyyy').format(endDate);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    print("startdt = $formattedStartDate end date = $formattedEndDate");

    String? cusid = await SharedPrefs.getCusId();
    String url = isChecked
        ? '$IpAddress/DeliveryDatewiseOrderSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'
        : '$IpAddress/DatewiseOrderSalesReport/$cusid/$formattedStartDate/$formattedEndDate/';
    print("urlll : $url");
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
      logreports(
          "OrderSalesReport: ${foramtedletterstartdt} To ${foramtedletterenddt}_Viewd");
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<String> getDisplayedColumns() {
    return [
      'billno',
      'dt',
      'cusname',
      'contact',
      'type',
      'count',
      'finalamount',
      'deliverydate'
    ];
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> tableData) {
    List<String> displayedColumns = getDisplayedColumns();
    return tableData.map((row) {
      return Map.fromEntries(
          row.entries.where((entry) => displayedColumns.contains(entry.key)));
    }).toList();
  }

  late DateTime selectedStartDate;
  TextEditingController _StartDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  TextEditingController _EndDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  late DateTime selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // color: Subcolor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Order Sales Summary',
                              style: HeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 150
                                      : MediaQuery.of(context).size.width *
                                          0.35, // Adjusted for mobile
                                  height:
                                      30, // Set smaller height for the container
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: DateTimePicker(
                                            controller: _StartDateController,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: '',
                                            onChanged: (val) {
                                              setState(() {
                                                selectedStartDate =
                                                    DateTime.parse(val);
                                              });
                                            },
                                            style:
                                                textStyle, // Text style for DateTimePicker text
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Container(
                                //   width: Responsive.isDesktop(context)
                                //       ? 150
                                //       : MediaQuery.of(context).size.width *
                                //           0.32,
                                //   height:
                                //       Responsive.isDesktop(context) ? 25 : 30,
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     border:
                                //         Border.all(color: Colors.grey.shade300),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 3.0),
                                //     child: Row(
                                //       children: [
                                //         Icon(
                                //           Icons.calendar_month,
                                //           color: Colors.grey,
                                //         ),
                                //         SizedBox(width: 8),
                                //         Expanded(
                                //           child: Container(
                                //             height: 30, // Set the height here
                                //             child: DateTimePicker(
                                //               controller: _StartDateController,
                                //               firstDate: DateTime(2000),
                                //               lastDate: DateTime(2100),
                                //               dateLabelText: '',
                                //               onChanged: (val) {
                                //                 // Update selectedDate when the date is changed
                                //                 setState(() {
                                //                   selectedStartDate =
                                //                       DateTime.parse(val);
                                //                 });
                                //                 print(val);
                                //               },
                                //               validator: (val) {
                                //                 print(val);
                                //                 return null;
                                //               },
                                //               onSaved: (val) {
                                //                 print(val);
                                //               },
                                //               style: textStyle,
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To',
                                  style: commonLabelTextStyle,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: Responsive.isDesktop(context)
                                      ? 150
                                      : MediaQuery.of(context).size.width *
                                          0.35, // Adjusted for mobile
                                  height:
                                      30, // Set smaller height for the container
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: DateTimePicker(
                                            controller: _EndDateController,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: '',
                                            onChanged: (val) {
                                              setState(() {
                                                selectedEndDate =
                                                    DateTime.parse(val);
                                              });
                                            },
                                            style:
                                                textStyle, // Text style for DateTimePicker text
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Container(
                                //   width: Responsive.isDesktop(context)
                                //       ? 150
                                //       : MediaQuery.of(context).size.width *
                                //           0.32,
                                //   height:
                                //       Responsive.isDesktop(context) ? 25 : 30,
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     border:
                                //         Border.all(color: Colors.grey.shade300),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 3.0),
                                //     child: Row(
                                //       children: [
                                //         Icon(
                                //           Icons.calendar_month,
                                //           color: Colors.grey,
                                //         ),
                                //         SizedBox(width: 8),
                                //         Expanded(
                                //           child: Container(
                                //             height: 30,
                                //             child: DateTimePicker(
                                //               controller: _EndDateController,
                                //               firstDate: DateTime(2000),
                                //               lastDate: DateTime(2100),
                                //               dateLabelText: '',
                                //               onChanged: (val) {
                                //                 // Update selectedDate when the date is changed
                                //                 setState(() {
                                //                   selectedEndDate =
                                //                       DateTime.parse(val);
                                //                 });
                                //                 print(val);
                                //               },
                                //               validator: (val) {
                                //                 print(val);
                                //                 return null;
                                //               },
                                //               onSaved: (val) {
                                //                 print(val);
                                //               },
                                //               style: textStyle,
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: Responsive.isDesktop(context) ? 27.0 : 0,
                                left: Responsive.isDesktop(context) ? 0 : 10),
                            child: ElevatedButton(
                              onPressed: () {
                                fetchdatewiseaOrdersales();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: subcolor,
                                  minimumSize: Size(10, 30),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero)),
                              child: Icon(
                                Icons.search,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 20,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                    activeColor: subcolor,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Delivery DateWise',
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      List<Map<String, dynamic>> filteredData =
                                          getFilteredData(tableData);
                                      List<List<dynamic>> convertedData =
                                          filteredData
                                              .map((map) => map.values.toList())
                                              .toList();
                                      List<String> columnNames =
                                          getDisplayedColumns();
                                      await createExcel(
                                          columnNames, convertedData);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: subcolor,
                                        padding: EdgeInsets.only(
                                            left: 7,
                                            right: 7,
                                            top: 3,
                                            bottom: 3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: SvgPicture.asset(
                                            'assets/imgs/excel.svg',
                                            width: 20,
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text("Export", style: commonWhiteStyle),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              tableView(),
                              SizedBox(height: 5),
                              if (tableData
                                  .isNotEmpty) // Show this Row only if tableData is not empty
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Check if the width is greater than a certain threshold (e.g., 600 for desktop)
                                    bool isDesktop = constraints.maxWidth > 600;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Conditionally display the icon
                                          if (isDesktop) ...[
                                            Icon(Icons.touch_app),
                                            SizedBox(width: 5),
                                          ],
                                          // Text with responsive behavior
                                          Flexible(
                                            child: Text(
                                              'If double click on the billno you can view the bill details',
                                              style: textStyle,
                                              textAlign: TextAlign.center,
                                              maxLines: isDesktop
                                                  ? 1
                                                  : 2, // Adjust maxLines based on width
                                              overflow: TextOverflow
                                                  .ellipsis, // Optional: handle overflow
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              SizedBox(height: 10),
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
                                      onPressed: hasNextPage
                                          ? () => loadNextPage()
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
    });
    fetchdatewiseaOrdersales();
  }

  void loadPreviousPage() {
    setState(() {
      currentPage--;
    });
    fetchdatewiseaOrdersales();
  }

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection:
          Responsive.isMobile(context) ? Axis.horizontal : Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Container(
                height:
                    Responsive.isDesktop(context) ? screenHeight * 0.60 : 320,
                width: Responsive.isDesktop(context) ? screenWidth * 0.80 : 600,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("BillNo",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Date",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("CusName",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Contact",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Type",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("Count",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("FiAmt",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 300.0,
                                    height:
                                        Responsive.isDesktop(context) ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text("DeliveryDate",
                                          textAlign: TextAlign.center,
                                          style: commonLabelTextStyle),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tableData.isNotEmpty)
                            ...tableData.map((data) {
                              var billno = data['billno'].toString();
                              var dt = data['dt'].toString();
                              var cusname = data['cusname'].toString();
                              var contact = data['contact'].toString();
                              var type = data['type'].toString();
                              var count = data['count'].toString();
                              var finalamount = data['finalamount'].toString();
                              var deliverydate =
                                  data['deliverydate'].toString();

                              bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                              Color? rowColor = isEvenRow
                                  ? Color.fromARGB(224, 255, 255, 255)
                                  : Color.fromARGB(224, 255, 255, 255);

                              return GestureDetector(
                                onDoubleTap: () {
                                  _showDetailsForm(data);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0,
                                      right: 0,
                                      top: 5.0,
                                      bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              billno,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              dt,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              cusname,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              contact,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              type,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              count,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              finalamount,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: rowColor,
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 226, 225, 225),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              deliverydate,
                                              textAlign: TextAlign.center,
                                              style: TableRowTextStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                          else ...{
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 60.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/imgs/document.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                      Center(
                                        child: Text(
                                            'No transactions available to generate report',
                                            style: textStyle),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          },
                        ],
                      ),
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

  void _showDetailsForm(Map<String, dynamic> rowData) {
    List<dynamic> orderDetails = jsonDecode(rowData['OrderDetails']);
    double discount =
        double.tryParse(rowData['discount']?.toString() ?? '0') ?? 0;
    double cgst = double.tryParse(rowData['totcgst']?.toString() ?? '0') ?? 0;
    double sgst = double.tryParse(rowData['totsgst']?.toString() ?? '0') ?? 0;

    double totalAmount = 0.0;

    List<Widget> itemRows = [];

    for (var order in orderDetails) {
      if (order['billno'].toString() == rowData['billno'].toString()) {
        String itemName = order['Itemname'].toString();
        double rate = double.tryParse(order['rate']?.toString() ?? '0') ?? 0;
        double qty = double.tryParse(order['qty']?.toString() ?? '0') ?? 0;
        double taxableAmt =
            double.tryParse(order['retail']?.toString() ?? '0') ?? 0;
        double totalAmt =
            double.tryParse(order['amount']?.toString() ?? '0') ?? 0;

        itemRows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(itemName,
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(rate.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(qty.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(taxableAmt.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color.fromARGB(255, 226, 225, 225),
                      ),
                    ),
                    child: Center(
                      child: Text(totalAmt.toString(),
                          textAlign: TextAlign.center, style: textStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        totalAmount += totalAmt;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Details', style: HeadingStyle),
              Spacer(),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.numbers,
                                      size: 16, color: Colors.black),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Count : ',
                                      style: textStyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                orderDetails.length.toString(),
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Row(
                                children: [
                                  Icon(Icons.receipt,
                                      size: 16, color: Colors.black),
                                  Text.rich(
                                    TextSpan(
                                      text: 'BillNo : ',
                                      style: textStyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '${rowData['billno']}',
                                          style: commonLabelTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Row(
                                children: [
                                  Icon(Icons.date_range,
                                      size: 16, color: Colors.black),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Date : ',
                                      style: textStyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '${rowData['dt']}',
                                            style: commonLabelTextStyle),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ItemName',
                                      textAlign: TextAlign.center,
                                      style: commonWhiteStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Rate",
                                      textAlign: TextAlign.center,
                                      style: commonWhiteStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Qty",
                                      textAlign: TextAlign.center,
                                      style: commonWhiteStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Taxable",
                                      textAlign: TextAlign.center,
                                      style: commonWhiteStyle,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  width: 150.0,
                                  height:
                                      Responsive.isDesktop(context) ? 25 : 30,
                                  decoration: BoxDecoration(
                                    color: subcolor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "TotalAmt",
                                      textAlign: TextAlign.center,
                                      style: commonWhiteStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: itemRows,
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.attach_money,
                                size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' TaxableAmt: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: totalAmount.toString(),
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.money_off,
                                size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' Dis ₹: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: discount.toString(),
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.monetization_on,
                                size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' Total: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: totalAmount.toString(),
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.money, size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' CGST: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: cgst.toString(),
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.money, size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' SGST: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: sgst.toString(),
                                      style: commonLabelTextStyle),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(Icons.payment, size: 16, color: Colors.black),
                            Text.rich(
                              TextSpan(
                                text: ' PayableAmt: ',
                                style: textStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: totalAmount.toString(),
                                    style: commonLabelTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments, size: 16, color: Colors.black),
                          Text.rich(
                            TextSpan(
                              text: 'Paid Amt : ',
                              style: textStyle,
                              children: <TextSpan>[
                                TextSpan(
                                    text: cgst.toString(),
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 5),
                      Row(
                        children: [
                          Icon(Icons.monetization_on,
                              size: 16, color: Colors.black),
                          Text.rich(
                            TextSpan(
                              text: 'Balance Amt : ',
                              style: textStyle,
                              children: <TextSpan>[
                                TextSpan(
                                    text: sgst.toString(),
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            backgroundColor: subcolor,
                            minimumSize: Size(45.0, 31.0),
                          ),
                          child: Text('Print', style: commonWhiteStyle),
                        ),
                        SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            backgroundColor: subcolor,
                            minimumSize: Size(45.0, 31.0),
                          ),
                          child: Text('Preview', style: commonWhiteStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> createExcel(
    List<String> columnNames, List<List<dynamic>> data) async {
  try {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
      final Range range = sheet.getRangeByIndex(1, colIndex + 1);
      range.setText(columnNames[colIndex]);
      range.cellStyle.backColor = '#550A35';
      range.cellStyle.fontColor = '#F5F5F5';
    }

    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final List<dynamic> rowData = data[rowIndex];
      for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
        final Range range = sheet.getRangeByIndex(rowIndex + 2, colIndex + 1);
        range.setText(rowData[colIndex].toString());
      }
    }

    final List<int> bytes = workbook.saveAsStream();

    try {
      workbook.dispose();
    } catch (e) {
      print('Error during workbook disposal: $e');
    }

    final now = DateTime.now();
    final formattedDate =
        '${now.day}-${now.month}-${now.year} Time ${now.hour}-${now.minute}-${now.second}';

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'OrderSales_Report ($formattedDate).xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Excel OrderSales_Report ($formattedDate).xlsx'
          : '$path/Excel OrderSales_Report ($formattedDate).xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  } catch (e) {
    print('Error in createExcel: $e');
  }
}
