import 'dart:async';

import 'dart:convert';
import 'package:ProductRestaurant/Settings/PrinterDetails.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Sales/NewSales.dart';

import 'package:flutter/foundation.dart';

class lastbillview extends StatefulWidget {
  const lastbillview({Key? key}) : super(key: key);

  @override
  State<lastbillview> createState() => _lastbillviewState();
}

TextEditingController FinallyyyAmounttts = TextEditingController();

class _lastbillviewState extends State<lastbillview> {
  @override
  void initState() {
    super.initState();
    fetchData();

    FinallyyyAmounttts.addListener(updateAmount);
  }

  List<Map<String, dynamic>> Purchasedetailstabledata = [];
  Future<void> fetchsalesdetails(Map<String, dynamic> data) async {
    String id = data["id"].toString(); // Convert Id to String
    final url = '$IpAddress/SalesRoundDetailsalldatas/$id';
    print("url : $url");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('SalesDetails')) {
          try {
            String purchaseDetailsString = responseData['SalesDetails'];
            List<String> purchaseDetailsRecords = purchaseDetailsString
                .split('}{'); // Split by '}{' to separate records
            for (var record in purchaseDetailsRecords) {
              // Clean up the record by removing '{' and '}'
              record = record.replaceAll('{', '').replaceAll('}', '');
              List<String> keyValuePairs = record.split(',');
              Map<String, dynamic> purchaseDetail = {};
              for (var pair in keyValuePairs) {
                List<String> parts = pair.split(':');
                String key = parts[0].trim();
                String value = parts[1].trim();
                // Remove surrounding quotes if any
                if (value.startsWith("'") && value.endsWith("'")) {
                  value = value.substring(1, value.length - 1);
                }
                purchaseDetail[key] = value;
              }
              Purchasedetailstabledata.add({
                'Itemname': purchaseDetail['Itemname'],
                'rate': purchaseDetail['rate'],
                'qty': purchaseDetail['qty'],
                'amount': purchaseDetail['amount'],
                'retail': purchaseDetail['retail'],
              });
            }
            // Print Paymentdetailsamounts after setting state
            // print('purchase Payment Details: $Purchasedetailstabledata');
            Purchasedetails(data);
          } catch (e) {
            throw FormatException('Invalid purchasepaymentdetails format');
          }
        } else {
          throw Exception(
              'Invalid response format: purchasepaymentdetails not found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void Purchasedetails(Map<String, dynamic> data) {
    String timeString =
        data['time'] ?? ''; // Assuming time is present in the data

    // Parse the time string into a DateTime object
    DateTime time = DateTime.parse(timeString);

    // Format the DateTime object to display time in "02:57 PM" format
    String formattedTime = DateFormat('hh:mm a').format(time);

    Future<void> _printResult() async {
      try {
        // Parse 'dt' and 'time' strings into DateTime objects
        DateTime salesdate = DateTime.parse(data['dt']);
        DateTime salestime = DateTime.parse(data['time']);

// Format the DateTime objects as required
        String formattedDate = DateFormat('dd.MM.yyyy').format(salesdate);
        String formattedDateTime = DateFormat('hh:mm a').format(salestime);

        double totalQuantity =
            0.0; // Define total quantity variable outside the loop

        for (var data in Purchasedetailstabledata) {
          // Inside the loop, add each quantity to the totalQuantity variable
          totalQuantity += double.parse(data['qty'].toString());
        }
        String totalQuantityString = totalQuantity.toString();
        String billno = data['billno'];
        String date = formattedDate;
        String paytype = data['paytype'];
        String time = formattedDateTime;
        // String Customername = data['cusname'];
        // String CustomerContact = data['contact'];
        String Tableno = data['tableno'];
        // String tableservent = data['servent'];
        String count = data['count'];
        String totalQty = totalQuantityString;
        String totalamt = data['amount'];
        String discount = data['discount'];
        String FinalAmt = data['finalamount'];
        String Customername;
        if (data['cusname'] == "null") {
          Customername = "";
        } else {
          Customername = data['cusname'];
        }
        String CustomerContact;
        if (data['contact'] == "null") {
          CustomerContact = "";
        } else {
          CustomerContact = data['contact'];
        }

        String tableservent;
        if (data['servent'] == "null") {
          tableservent = "";
        } else {
          tableservent = data['servent'];
        }

        String sgst25;
        if (data['cgst25'] == "0.0") {
          sgst25 = "";
        } else {
          sgst25 = data['cgst25'];
        }
        String sgst6;
        if (data['cgst6'] == "0.0") {
          sgst6 = "";
        } else {
          sgst6 = data['cgst6'];
        }
        String sgst9;
        if (data['cgst9'] == "0.0") {
          sgst9 = "";
        } else {
          sgst9 = data['cgst9'];
        }
        String sgst14;
        if (data['cgst14'] == "0.0") {
          sgst14 = "";
        } else {
          sgst14 = data['cgst14'];
        }

        List<String> productDetails = [];
        for (var data in Purchasedetailstabledata) {
          // Format each product detail as "{productName},{amount}"
          productDetails.add(
              "${data['Itemname'].toString()}-${data['rate'].toString()}-${data['qty'].toString()}");
        }

        String productDetailsString = productDetails.join(',');
        // print("product details : $productDetailsString   ");
        // print(
        //     "billno : $billno   , date : $date ,  paytype : $paytype ,    time :$time    ,customername : $Customername,  customercontact : $CustomerContact  ,    table No : $Tableno,   Tableservent : $tableservent,    total count :  $count,  total qty : $totalQty,    totalamt : $totalamt,    discount amt : $discount,    finalamount:  $FinalAmt");
        print(
            "url : $IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString");

        print(
            "sgst25 : $sgst25  ,  sgst6 :   $sgst6 , sgst 9 :   $sgst9  ,   sgst14:   $sgst14");

        final response = await http.get(Uri.parse(
            '$IpAddress/SalesPrint3Inch/$billno-$date-$paytype-$time/$Customername-$CustomerContact/$Tableno-$tableservent/$count-$totalQty-$totalamt-$discount-$FinalAmt-$sgst25-$sgst6-$sgst9-$sgst14/$productDetailsString'));

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

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Sales Details'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      Purchasedetailstabledata = [];
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Responsive.isDesktop(context)
                    ? Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BillNo',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 100
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 27,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['billno'] ?? ''),
                                    onChanged: (newValue) {
                                      // BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Name',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.25,
                                child: Container(
                                  height: 29,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['cusname'] ?? ''),
                                    onChanged: (newValue) {
                                      // BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 100
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: Container(
                                  height: 27,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: formattedTime ?? ''),
                                    onChanged: (newValue) {
                                      // BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table No',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: Responsive.isDesktop(context)
                                    ? 150
                                    : MediaQuery.of(context).size.width * 0.25,
                                child: Container(
                                  height: 29,
                                  width: 100,
                                  color: Colors.grey[200],
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: data['tableno'] ?? ''),
                                    onChanged: (newValue) {
                                      // BillnoController.text = newValue;
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 7.0,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BillNo',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 27,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['billno'] ?? ''),
                                        onChanged: (newValue) {
                                          // BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Name',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 29,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['cusname'] ?? ''),
                                        onChanged: (newValue) {
                                          // BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 100
                                        : MediaQuery.of(context).size.width *
                                            0.3,
                                    child: Container(
                                      height: 27,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: formattedTime ?? ''),
                                        onChanged: (newValue) {
                                          // BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Table No',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: Responsive.isDesktop(context)
                                        ? 150
                                        : MediaQuery.of(context).size.width *
                                            0.25,
                                    child: Container(
                                      height: 29,
                                      width: 100,
                                      color: Colors.grey[200],
                                      child: TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: data['tableno'] ?? ''),
                                        onChanged: (newValue) {
                                          // BillnoController.text = newValue;
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 7.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: SingleChildScrollView(
                    child: Container(
                      height: Responsive.isDesktop(context) ? 350 : 350,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Item Name",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Rate",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Quantity",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Total Retail",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Total Amount",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: maincolor,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Retail Rate",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (Purchasedetailstabledata.isNotEmpty)
                                ...Purchasedetailstabledata.asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> data = entry.value;
                                  var Itemname = data['Itemname'].toString();
                                  var rate = data['rate'].toString();

                                  var retailrate = data['retail'].toString();
                                  var qty = data['qty'].toString();
                                  var amount = data['amount'].toString();

                                  bool isEvenRow = index % 2 ==
                                      0; // Using index for row color
                                  Color? rowColor = isEvenRow
                                      ? Color.fromARGB(224, 255, 255, 255)
                                      : Color.fromARGB(224, 255, 255, 255);

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10,
                                      bottom: 5.0,
                                      top: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                Itemname,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                rate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                qty,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                retailrate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                amount,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
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
                                                rate,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _printResult();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text(
                        "Print",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subcolor,
                        padding: EdgeInsets.only(left: 7, right: 7),
                      ),
                      child: Text(
                        "Preview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   FinallyyyAmounttts.removeListener(updateAmount);
  //   FinallyyyAmounttts.dispose();
  //   super.dispose();
  // }

  void updateAmount() {
    setState(() {}); // Update the UI when FinallyyyAmounttts changes
  }

  Future<void> fetchData() async {
    String startdt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String enddt = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Parse start and end dates
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(startdt);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(enddt);

    // Add one day to the end date
    endDate = endDate.add(Duration(days: 1));

    String? cusid = await SharedPrefs.getCusId();
    // Format the dates to string
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("startdt = $formattedStartDate end date = $formattedEndDate");
    final response = await http.get(Uri.parse(
        '$IpAddress/DatewiseSalesReport/$cusid/$formattedStartDate/$formattedEndDate/'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        tableData = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
        width: Responsive.isDesktop(context)
            ? screenwidth
            : MediaQuery.of(context).size.width * 0.8,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (Responsive.isDesktop(context))
            //   Padding(
            //     padding: const EdgeInsets.only(left: 0, top: 3),
            //     child: Container(
            //       height: 35,
            //       width: Responsive.isDesktop(context)
            //           ? 260
            //           : MediaQuery.of(context).size.width * 0.75,
            //       color: Color.fromARGB(255, 225, 225, 225),
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: EdgeInsets.only(
            //                 left: Responsive.isDesktop(context) ? 0 : 0,
            //                 top: 0),
            //             child: Container(
            //               width: Responsive.isDesktop(context) ? 70 : 70,
            //               height: 35,
            //               child: ElevatedButton(
            //                 onPressed: () {
            //                   // Handle form submission
            //                 },
            //                 style: ElevatedButton.styleFrom(
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(2.0),
            //                   ),
            //                   backgroundColor: subcolor,
            //                   minimumSize:
            //                       Size(45.0, 31.0), // Set width and height
            //                 ),
            //                 child: Text(
            //                   'RS. ',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize: 18,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           Padding(
            //             padding: EdgeInsets.only(
            //                 left: Responsive.isDesktop(context) ? 20 : 20,
            //                 top: 11),
            //             child: Container(
            //               width: Responsive.isDesktop(context) ? 85 : 85,
            //               child: Container(
            //                 height: 24,
            //                 width: 100,
            //                 child: Text(
            //                   "${NumberFormat.currency(symbol: '', decimalDigits: 0).format(double.tryParse(FinallyyyAmounttts.text ?? '0') ?? 0)} /-",
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.w700,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: Text(
                    "Last Bill",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            tableView(),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context) ? 20 : 0,
                            top: 0),
                        child: Container(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewSalesEntry(
                                    Fianlamount: TextEditingController(),
                                    cusnameController: TextEditingController(),
                                    TableNoController: TextEditingController(),
                                    cusaddressController:
                                        TextEditingController(),
                                    cuscontactController:
                                        TextEditingController(),
                                    scodeController: TextEditingController(),
                                    snameController: TextEditingController(),
                                    TypeController: TextEditingController(),
                                    salestableData: [],
                                    isSaleOn: true,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              backgroundColor: subcolor,
                              minimumSize:
                                  Size(45.0, 31.0), // Set width and height
                            ),
                            child: Text(
                              'New Sales',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Container(
                  // color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: Responsive.isDesktop(context) ? 20 : 0,
                            top: 0),
                        child: Container(
                            child: ElevatedButton(
                          onPressed: () {
                            // Show the printer details page in a dialog
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  contentPadding: EdgeInsets.zero,
                                  content: Container(
                                    width: 1250,
                                    // height: 700,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: Responsive.isDesktop(context)
                                                ? 40
                                                : 6,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.cancel),
                                                color: Colors.red,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        )
// Customize the text style as needed
                                        ,
                                        Container(
                                            width: 1200,
                                            height: 600,
                                            child: printerdetails()),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            backgroundColor: subcolor,
                            minimumSize:
                                Size(45.0, 31.0), // Set width and height
                          ),
                          child: Text(
                            'Printer Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  Widget tableView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: Responsive.isDesktop(context) ? screenHeight * 0.65 : 320,
          // height: Responsive.isDesktop(context) ? 380 : 240,
          width: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.23
              : MediaQuery.of(context).size.width,

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
                  ? screenwidth * 0.23
                  : MediaQuery.of(context).size.width * 0.8,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Bill No",
                                    textAlign: TextAlign.center,
                                    style: commonLabelTextStyle),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 25,
                          decoration: TableHeaderColor,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money,
                                    size: 15, color: Colors.blue),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Amount",
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
                if (tableData.isNotEmpty)
                  ...tableData.asMap().entries.map((entry) {
                    int index = entry.key;

                    Map<String, dynamic> data = entry.value;
                    var id = data['id'].toString();

                    var billno = data['billno'].toString();
                    var amount = NumberFormat('###,###,##0.00')
                        .format(double.parse(data['amount'].toString()));
                    bool isEvenRow = tableData.indexOf(data) % 2 == 0;
                    Color? rowColor = isEvenRow
                        ? Color.fromARGB(224, 255, 255, 255)
                        : Color.fromARGB(255, 223, 225, 226);

                    return Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: GestureDetector(
                        onTap: () {
                          // purchasePaymentDetails(data);
                          fetchsalesdetails(data);
                        },
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
                                child: Center(
                                  child: Text(billno,
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
                                  child: Text(amount,
                                      textAlign: TextAlign.center,
                                      style: TableRowTextStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
