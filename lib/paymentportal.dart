import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

late Razorpay _razorpay;

int softwareamount = 299;

void initRazorpay() {
  _razorpay = Razorpay();
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
}

void disposeRazorpay() {
  _razorpay.clear();
}

void _handlePaymentSuccess(PaymentSuccessResponse response) {
  print("Payment Success: $response");
}

void _handlePaymentError(PaymentFailureResponse response) {
  print("Payment Error: $response");
}

void _handleExternalWallet(ExternalWalletResponse response) {
  print("External Wallet: $response");
}

void createOrder() async {
  String username = 'rzp_live_SyQY8IpVKCA2S5'; // razorpay pay key
  String password = "YgQuEml5GSeOFy9reD7lKOqV"; // razorpay secret key
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Map<String, dynamic> body = {
    "amount": softwareamount * 100,
    "currency": "INR",
    "receipt": "rcptid_11",
    "payment_capture": 1,
  };

  var res = await http.post(
    Uri.https("api.razorpay.com", "v1/orders"),
    headers: <String, String>{
      "Content-Type": "application/json",
      'authorization': basicAuth,
    },
    body: jsonEncode(body),
  );

  if (res.statusCode == 200) {
    String orderId = jsonDecode(res.body)['id'];
    openCheckout(orderId, softwareamount * 100);
    print("Order ID: $orderId");
  } else {
    print("Failed to create order: ${res.body}");
  }
}

void openCheckout(String orderId, int amount) async {
  print("openCheckout order ID: $orderId");
  print("openCheckout amount: $amount");

  var options = {
    'key': 'rzp_live_SyQY8IpVKCA2S5',
    'amount': amount, // Amount in paise
    'name': 'Buyp Textile',
    'description': 'Payment for software renewal',
    'email': 'thilo@gmail.com',
    'capture': '1', // Capture the payment immediately
    'order_id': orderId, // Pass orderId to openCheckout
    "theme": {"color": "#FFFF00"}
  };

  try {
    if (kIsWeb) {
      // Handle web platform specific code here
      print("Web platform not supported yet");
    } else {
      _razorpay.open(options);
    }
  } catch (e) {
    print("Error: $e");
  }
}

void main() {
  initRazorpay();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Razorpay Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: createOrder,
            child: Text('Create Order'),
          ),
        ),
      ),
    );
  }
}



// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:product_restaurantapp/Modules/Responsive.dart';
// // import 'package:provider/provider.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';

// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/foundation.dart';

// // String complaint_management_link = "payment.mybodottoday.com";

// // class product_payment_page extends StatefulWidget {
// //   const product_payment_page({Key? key}) : super(key: key);

// //   @override
// //   State<product_payment_page> createState() => _product_payment_pageState();
// // }

// // class _product_payment_pageState extends State<product_payment_page> {
// //   bool showSilverPayment = false;
// //   bool showGoldPayment = false;
// //   bool showDiamondPayment = false;

// //   void toggleSilverPayment() {
// //     setState(() {
// //       showSilverPayment = !showSilverPayment;
// //       showGoldPayment = false;
// //       showDiamondPayment = false;
// //     });
// //   }

// //   void toggleDiamendPayment() {
// //     setState(() {
// //       showDiamondPayment = !showDiamondPayment;
// //       showGoldPayment = false;
// //       showSilverPayment = false;
// //     });
// //   }

// //   void toggleGoldPayment() {
// //     setState(() {
// //       showGoldPayment = !showGoldPayment;
// //       showSilverPayment = false;
// //       showDiamondPayment = false;
// //     });
// //   }

// //   List<Map<String, dynamic>> plans = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchData();
// //   }

// //   Future<void> fetchData() async {
// //     final response = await http
// //         .get(Uri.parse('http://$complaint_management_link/Plan_details/'));

// //     if (response.statusCode == 200) {
// //       List<dynamic> data = json.decode(response.body);

// //       final activePlans =
// //           data.where((plan) => plan['status'] == 'Active').toList();

// //       setState(() {
// //         plans = activePlans.cast<Map<String, dynamic>>();
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: Responsive.isMobile(context)
// //           ? AppBar(
// //               backgroundColor: Color.fromARGB(255, 249, 237, 129),
// //               leading: IconButton(
// //                 icon: Icon(
// //                   Icons.arrow_back,
// //                   color: Colors.black,
// //                 ),
// //                 onPressed: () {
// //                   // Navigate back to the dashboard when the back button is pressed
// //                   // Navigator.of(context).pushReplacement(
// //                   //   MaterialPageRoute(
// //                   //     builder: (_) => MultiProvider(
// //                   //       providers: [
// //                   //         ChangeNotifierProvider(
// //                   //           create: (context) => MenuAppController(),
// //                   //         ),
// //                   //       ],
// //                   //       child: software_info(),
// //                   //     ),
// //                   //   ),
// //                   // );
// //                 },
// //               ),
// //               title: Text(
// //                 "Payments",
// //                 style: Theme.of(context).textTheme.titleLarge!.copyWith(
// //                       color: Colors.black,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //               ),
// //             )
// //           : null, // Null if not on mobile

// //       body: WillPopScope(
// //         onWillPop: () async {
// //           // Navigate back to the dashboard when the back button is pressed
// //           // Navigator.of(context).pushReplacement(
// //           //   MaterialPageRoute(
// //           //     builder: (_) => MultiProvider(
// //           //       providers: [
// //           //         ChangeNotifierProvider(
// //           //           create: (context) => MenuAppController(),
// //           //         ),
// //           //       ],
// //           //       child: software_info(),
// //           //     ),
// //           //   ),
// //           // );

// //           return false; // Prevent the default back behavior
// //         },
// //         child: Row(
// //           children: [
// //             Expanded(
// //               flex: 10,
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     SizedBox(
// //                       height: 20,
// //                     ),
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       children: [
// //                         Padding(
// //                           padding: const EdgeInsets.only(bottom: 3, right: 5),
// //                           child: Icon(
// //                             Icons.square_outlined,
// //                             size: 12,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(right: 40),
// //                           child: Text(
// //                             "Top the card for payments",
// //                             style: TextStyle(
// //                                 fontSize: 12, fontWeight: FontWeight.bold),
// //                           ),
// //                         )
// //                       ],
// //                     ),
// //                     SizedBox(
// //                       height: 10,
// //                     ),
// //                     if (plans.isNotEmpty) buildPaymentCards(),
// //                     SizedBox(height: 30),
// //                     if (showSilverPayment && isStatusActive('Silver'))
// //                       silver_payment(),
// //                     if (showGoldPayment && isStatusActive('Gold'))
// //                       gold_payment(),
// //                     if (showDiamondPayment && isStatusActive('Diamond'))
// //                       diamend_payments(),
// //                     SizedBox(
// //                       height: 10,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildPaymentCards() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         for (var plan in plans)
// //           PaymentCard(
// //             planname: plan['planname'],
// //             planamount: plan['planamount'],
// //             isSelected: getCardSelection(plan['planname']),
// //             onTap: () {
// //               togglePaymentSelection(plan['planname']);
// //             },
// //             isActive:
// //                 true, // Always set to true since we only have "Active" plans
// //           ),
// //       ],
// //     );
// //   }

// //   bool getCardSelection(String planname) {
// //     if (planname == 'Silver') {
// //       return showSilverPayment;
// //     } else if (planname == 'Gold') {
// //       return showGoldPayment;
// //     } else if (planname == 'Diamond') {
// //       return showDiamondPayment;
// //     }
// //     return false;
// //   }

// //   bool isStatusActive(String planType) {
// //     final plan = plans.firstWhere((plan) => plan['planname'] == planType,
// //         orElse: () => {});
// //     return plan != null && plan['status'] == 'Active';
// //   }

// //   void togglePaymentSelection(String planname) {
// //     setState(() {
// //       showSilverPayment = planname == 'Silver';
// //       showGoldPayment = planname == 'Gold';
// //       showDiamondPayment = planname == 'Diamond';
// //     });
// //   }
// // }

// // class PaymentCard extends StatelessWidget {
// //   final String planname;
// //   final String planamount;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //   final bool isActive;

// //   PaymentCard({
// //     required this.planname,
// //     required this.planamount,
// //     required this.isSelected,
// //     required this.onTap,
// //     required this.isActive,
// //   });
// //   final NumberFormat numberFormat = NumberFormat.currency(
// //     customPattern: '###,###,###,###',
// //     symbol: '₹',
// //     decimalDigits: 0,
// //   );
// //   @override
// //   Widget build(BuildContext context) {
// //     String formattedPlanAmount = numberFormat.format(double.parse(planamount));

// //     return CardWithBorder(
// //       color: Color.fromARGB(255, 212, 216, 194),
// //       elevation: 5,
// //       isSelected: isSelected,
// //       onTap: onTap,
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Text(
// //             planname == "Diamond"
// //                 ? "Save 16%"
// //                 : (planname == "Gold" ? "Save 4%" : "only"),
// //             style: TextStyle(
// //                 fontSize: Responsive.isMobile(context)
// //                     ? MediaQuery.of(context).size.width * 0.03
// //                     : 12,
// //                 fontWeight: FontWeight.bold),
// //           ),
// //           SizedBox(
// //             height: 12,
// //           ),
// //           Text(
// //             planname,
// //             style: TextStyle(
// //                 fontSize: Responsive.isMobile(context)
// //                     ? MediaQuery.of(context).size.width * 0.042
// //                     : 18,
// //                 fontWeight: FontWeight.bold),
// //           ),
// //           SizedBox(
// //             height: 7,
// //           ),
// //           Text(
// //             "₹$formattedPlanAmount /-",
// //             style: TextStyle(
// //                 fontSize: Responsive.isMobile(context)
// //                     ? MediaQuery.of(context).size.width * 0.042
// //                     : 18,
// //                 fontWeight: FontWeight.bold),
// //           ),
// //         ],
// //       ),
// //       isActive: isActive,
// //     );
// //   }
// // }

// // class CardWithBorder extends StatelessWidget {
// //   final Color color;
// //   final double elevation;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //   final Widget child;

// //   CardWithBorder(
// //       {required this.color,
// //       required this.elevation,
// //       required this.isSelected,
// //       required this.onTap,
// //       required this.child,
// //       required bool isActive});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 6, right: 6),
// //       child: Card(
// //         color: color,
// //         elevation: isSelected ? elevation + 5 : elevation,
// //         shadowColor: isSelected
// //             ? Color.fromARGB(255, 53, 53, 53)
// //             : Colors.transparent, // Set shadow color

// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16.0),
// //           side: BorderSide(
// //             color: isSelected ? Colors.black : Colors.transparent,
// //             width: isSelected ? 2.0 : 0.0,
// //           ),
// //         ),
// //         child: InkWell(
// //           onTap: onTap,
// //           child: Container(
// //             width: Responsive.isMobile(context)
// //                 ? MediaQuery.of(context).size.width * 0.27
// //                 : 300,
// //             height: Responsive.isMobile(context)
// //                 ? MediaQuery.of(context).size.height * 0.18
// //                 : 300,
// //             alignment: Alignment.center,
// //             child: child,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class silver_payment extends StatefulWidget {
// //   const silver_payment({Key? key}) : super(key: key);

// //   @override
// //   State<silver_payment> createState() => _silver_paymentState();
// // }

// // class _silver_paymentState extends State<silver_payment> {
// //   late Razorpay _razorpay;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchBusinessDetails();
// //     Fetch_plan_amount();
// //     fetchSerialNumber();
// //     _razorpay = Razorpay();

// //     // Initialize Razorpay with your key and secret
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }

// //   String? paymentId;
// //   String? orderId;
// //   String? razorpaySignature;
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //     paymentId = response.paymentId;
// //     orderId = response.orderId;
// //     razorpaySignature = response.signature;
// //     print("Payment Success: ${response.paymentId}");
// //     print("Order ID: ${response.orderId}");
// //     print("Razor Singnature: ${response.signature}");

// //     deletePaymentQueueData();
// //     Success_Payment_queue_history();
// //     // Update_software_amctbl();
// //     Update_traile_user();
// //     // Update_SoftwareTrail_user();
// //     Check_payment_user();
// //     showSuccessMessage(context);
// //   }

// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     print("Payment Error: ${response.code} - ${response.message}");
// //     Failure_Payment_queue_history();
// //     deletePaymentQueueData();
// //     showFailMessage(context);
// //   }

// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     print("External Wallet: ${response.walletName}");
// //     // Failure_Payment_queue_history();
// //     // deleteData_Payment_queue();
// //   }

// //   void createOrder() async {
// //     String username = 'rzp_live_SyQY8IpVKCA2S5'; // razorpay pay key
// //     String password = "YgQuEml5GSeOFy9reD7lKOqV"; // razoepay secret key
// //     String basicAuth =
// //         'Basic ${base64Encode(utf8.encode('$username:$password'))}';

// //     Map<String, dynamic> body = {
// //       "amount": softwareamount * 100,
// //       "currency": "INR",
// //       "receipt": "rcptid_11",
// //       "payment_capture": 1,
// //     };

// //     var res = await http.post(
// //       Uri.https("api.razorpay.com", "v1/orders"),
// //       headers: <String, String>{
// //         "Content-Type": "application/json",
// //         'authorization': basicAuth,
// //       },
// //       body: jsonEncode(body),
// //     );

// //     if (res.statusCode == 200) {
// //       String orderId = jsonDecode(res.body)['id'];
// //       openCheckout(orderId, 1 * 100);
// //       print("order idddd :   ${orderId}");
// //     }
// //     print(res.body);
// //   }

// //   void openCheckout(String orderId, int amount) async {
// //     var options = {
// //       'key': 'rzp_live_SyQY8IpVKCA2S5',
// //       'amount': amount, // Amount in paise
// //       'name': 'Buyp Textile',
// //       'description': 'Payment for software renewal',
// //       'email': 'thilo@gmail.com',
// //       'capture': '1', // Capture the payment immediately
// //       'order_id': orderId, // Pass orderId to openCheckout
// //       "theme": {"color": "#FFFF00"}
// //     };

// //     if (Platform.isAndroid || Platform.isIOS) {
// //       _razorpay.open(options);
// //     } else if (kIsWeb) {
// //       // Handle web platform specific code here
// //       print("Web platform not supported yet");
// //     } else {
// //       // Handle other platforms or show an error
// //       print("Unsupported platform");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _razorpay.clear();
// //   }

// //   Future<void> Success_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Silver",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Success",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Failure_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Silver",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Failure",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   int deleted_payment_queue_id = 0;
// //   Future<void> getDataBySerialNo() async {
// //     String baseUrl = "http://$complaint_management_link/PaymentQueue/";

// //     try {
// //       final response = await http.get(Uri.parse(baseUrl));
// //       if (response.statusCode == 200) {
// //         // Parse the response JSON
// //         final List<Map<String, dynamic>> data =
// //             List<Map<String, dynamic>>.from(json.decode(response.body));

// //         // Find the item with the matching serial number
// //         final item = data.firstWhere(
// //             (item) => item['cusid'] == bsiness_serialno.toString(),
// //             orElse: () => {'id': null});

// //         if (item['id'] != null) {
// //           // Extract the 'id' from the item
// //           deleted_payment_queue_id = item['id'];

// //           print('Found item with id: $deleted_payment_queue_id');
// //         } else {
// //           print('Item not found with serial number: $bsiness_serialno');
// //         }
// //       } else {
// //         print('Failed to retrieve data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   Future<void> deletePaymentQueueData() async {
// //     await getDataBySerialNo();
// //     int id = deleted_payment_queue_id;
// //     print(deleted_payment_queue_id);
// //     final url =
// //         Uri.parse('https://payment.mybodottoday.com/paymentqueues/$id/');

// //     try {
// //       var response = await http.delete(url);

// //       while (response.statusCode == 301 || response.statusCode == 302) {
// //         // Handle the redirect by fetching the new URL
// //         final newUrl = Uri.parse(response.headers['location']!);
// //         response = await http.delete(newUrl);
// //       }

// //       if (response.statusCode == 204) {
// //         print('Data deleted successfully');
// //       } else {
// //         print('Failed to delete data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   // Future<void> Update_software_amctbl() async {
// //   //   fetchSerialNumber();
// //   //   fetchBusinessDetails();
// //   //   DateTime now = DateTime.now();
// //   //   String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //   //   DateTime expiryDate = now.add(Duration(days: 30));
// //   //   String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //   //   final Map<String, String> dataToUpdate = {
// //   //     "dt": formattedDate,
// //   //     "expirydt": formattedExpiryDate,
// //   //     "status": "Payment",
// //   //     "serialno": serialNumber
// //   //   };

// //   //   // String? ipAddress = await SharedPrefs.getIpAddress();
// //   //   String baseUrl = "http://$ipAddress/software_expire/";
// //   //   final response1 = await http.get(Uri.parse(baseUrl));

// //   //   if (response1.statusCode == 200) {
// //   //     final data = json.decode(response1.body);

// //   //     for (var member in data) {
// //   //       if (member['macid'] == macid.toString()) {
// //   //         // Assuming you want to update the record with 'id' equal to 3
// //   //         final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //   //         final response = await http.patch(
// //   //           updateUrl,
// //   //           body: json.encode(dataToUpdate),
// //   //           headers: {'Content-Type': 'application/json'},
// //   //         );

// //   //         if (response.statusCode == 200) {
// //   //           print('Data updated successfully.');
// //   //         } else {
// //   //           print('Failed to update data.');
// //   //         }
// //   //       }
// //   //     }
// //   //   }
// //   // }

// //   // Future<void> Update_SoftwareTrail_user() async {
// //   //   DateTime now = DateTime.now();
// //   //   String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //   //   DateTime expiryDate = now.add(Duration(days: 30));
// //   //   String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //   //   final Map<String, String> dataToUpdate = {
// //   //     "trailstatus": "Payment",
// //   //     "tarilstartdate": formattedDate,
// //   //     "trailenddate": formattedExpiryDate,
// //   //   };

// //   //   String? ipAddress = await SharedPrefs.getIpAddress();
// //   //   String baseUrl = "http://$ipAddress/Trailuser_registration/";
// //   //   final response1 = await http.get(Uri.parse(baseUrl));

// //   //   if (response1.statusCode == 200) {
// //   //     final data = json.decode(response1.body);

// //   //     for (var member in data) {
// //   //       if (member['trailid'] == bsiness_serialno.toString()) {
// //   //         // Assuming you want to update the record with 'id' equal to 3
// //   //         final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //   //         final response = await http.patch(
// //   //           updateUrl,
// //   //           body: json.encode(dataToUpdate),
// //   //           headers: {'Content-Type': 'application/json'},
// //   //         );

// //   //         if (response.statusCode == 200) {
// //   //           print('Data updated successfully.');
// //   //         } else {
// //   //           print('Failed to update data.');
// //   //         }
// //   //       }
// //   //     }
// //   //   }
// //   // }

// //   Future<void> Update_traile_user() async {
// //     try {
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 30));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       final Map<String, String> dataToUpdate = {
// //         "tarilstartdate": formattedDate,
// //         "trailenddate": formattedExpiryDate,
// //         "trailstatus": "Payment",
// //         "closedate": formattedCloseDate
// //       };

// //       String baseUrl = "https://$complaint_management_link/TrailUsers/";
// //       final response1 = await http.get(Uri.parse(baseUrl));

// //       if (response1.statusCode == 200) {
// //         final data = json.decode(response1.body);

// //         for (var member in data) {
// //           if (member['trailid'] == bsiness_serialno.toString()) {
// //             final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //             print('Update URL: $updateUrl');
// //             print('Data to Update: $dataToUpdate');

// //             final response = await http.patch(
// //               updateUrl,
// //               body: json.encode(dataToUpdate),
// //               headers: {'Content-Type': 'application/json'},
// //             );

// //             if (response.statusCode == 200) {
// //               print('Data updated successfully.');
// //             } else {
// //               print(
// //                   'Failed to update data. Status code: ${response.statusCode}, Response: ${response.body}');
// //             }
// //           }
// //         }
// //       } else {
// //         print(
// //             'Failed to fetch initial data. Status code: ${response1.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }

// //   Future<void> Post_payment_user_regisrations() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 30));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       String baseUrl =
// //           "http://$complaint_management_link/PaymentUser_registration/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": serialNumber,
// //         "trailid": bsiness_serialno.toString(),
// //         "date": formattedDate,
// //         "fullname": name,
// //         "businessname": businessName,
// //         "phoneno": phoneno.toString(),
// //         "address": address,
// //         "state": state,
// //         "district": district,
// //         "city": city,
// //         "businessgstno": businessgstno,
// //         "planname": "Silver",
// //         "startdate": formattedDate,
// //         "enddate": formattedExpiryDate,
// //         "software": software,
// //         "status": status,
// //         "macid": macid,
// //         "amount": softwareamount.toString(),
// //         "noofusers": "0",
// //         "totalamount": "299",
// //         "installdate": installdate,
// //         "closedate": formattedCloseDate
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //         print("Data posted Successfully ");
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Update_payment_user_registrations() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 30));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //     String formattedCloseDate =
// //         DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "startdate": formattedDate,
// //       "enddate": formattedExpiryDate,
// //       "closedate": formattedCloseDate
// //     };

// //     String baseUrl =
// //         "http://$complaint_management_link/PaymentUser_registration/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['trailid'] == bsiness_serialno.toString()) {
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //           print('Update URL: $updateUrl');
// //           print('Data to Update: $dataToUpdate');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print(
// //                 'Failed to update data. Status code: ${response.statusCode} , Response: ${response.body}');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Check_payment_user() async {
// //     String url = "http://$complaint_management_link/PaymentUser_registration/";

// //     final response = await http.get(Uri.parse(url));

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);
// //       String businessSerialNoString = bsiness_serialno.toString();

// //       bool foundMatchingTrailId = false;

// //       for (var member in data) {
// //         if (member['trailid'] == businessSerialNoString) {
// //           foundMatchingTrailId = true;
// //           break; // Exit the loop once a matching trailid is found
// //         }
// //       }

// //       if (foundMatchingTrailId) {
// //         // Call the Update_payment_user_registrations if a matching trailid is found
// //         Update_payment_user_registrations();
// //         print("Payment user Registration is updated successfully");
// //       } else {
// //         // Call the Post_payment_user_registrations if no matching trailid is found
// //         Post_payment_user_regisrations();
// //         print("Payment user Registration is posted successfully");
// //       }
// //     } else {
// //       // Handle the case when the GET request fails (e.g., handle errors).
// //       print(
// //           "Failed to fetch data from the server. Status code: ${response.statusCode}");
// //     }
// //   }

// //   void showSuccessMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Your Payment ₹$softwareamount/- has been successfully processed!!!'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void showFailMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Unfortunately, we were unable to process your payment (₹$softwareamount/-). Kindly double-check your payment information and try again'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   List<Map<String, dynamic>> plans = [];
// //   Future<void> Fetch_plan_amount() async {
// //     final response = await http
// //         .get(Uri.parse('http://$complaint_management_link/Plan_details/'));

// //     if (response.statusCode == 200) {
// //       List<dynamic> data = json.decode(response.body);

// //       final activePlans =
// //           data.where((plan) => plan['status'] == 'Active').toList();

// //       setState(() {
// //         plans = activePlans.cast<Map<String, dynamic>>();
// //       });
// //     }
// //   }

// //   int softwareamount = 299;
// //   int bsiness_serialno = 0;
// //   String name = '';
// //   String businessName = '';
// //   String status = '';
// //   String address = '';
// //   String state = '';
// //   String district = '';
// //   String city = '';
// //   String tarilstartdate = '';
// //   String trailenddate = '';
// //   String software = '';
// //   String macid = '';
// //   String trailstatus = '';
// //   String installdate = '';
// //   int phoneno = 0;
// //   String businessgstno = '';
// //   Future<void> fetchBusinessDetails() async {
// //     try {
// //       int mobileno = 9865441415;
// //       int sno = 0002;

// //       bsiness_serialno = int.tryParse(sno.toString()) ?? 0;
// //       name = "Thilo";
// //       businessName = "Thilo Restaurant";
// //       city = "kadayanallur";
// //       state = "Tamil Nadu";
// //       district = 'Tenkasi';
// //       address = "null";
// //       status = "trial";
// //       tarilstartdate = "2024-06-07";
// //       trailenddate = "2024-07-07";
// //       macid = "43543kjh3k5j435";
// //       software = "Restaurant Software";
// //       trailstatus = "trila";
// //       installdate = "2024-06-07";
// //       businessgstno = "0000";
// //       phoneno = int.tryParse(mobileno.toString()) ?? 0;

// //       print("bsiness_serialno : $bsiness_serialno");
// //       print("Name : $name");
// //       print("Bsiness Name : $businessName");
// //       print("City : $city");
// //       print("address : $address");
// //       print("contact : $phoneno");
// //       print("Status : $status");
// //       print("district : $district");
// //       print("State : $state");
// //       print("tarilstartdate : $tarilstartdate");
// //       print("trailenddate : $trailenddate");
// //       print("macid : $macid");
// //       print("software : $software");
// //       print("trailstatus : $trailstatus");
// //       print("businessgstno : $businessgstno");
// //       print("installdate : $installdate");
// //     } catch (e) {
// //       print('Error occurred: $e');
// //     }
// //   }

// //   String serialNumber = '';
// //   int payment_queue_id = 0;
// //   int parsedSerialNumber = 0;
// //   Future<void> fetchSerialNumber() async {
// //     try {
// //       String baseUrl = 'http://$complaint_management_link/PaymentRegID/';
// //       var response = await http.get(Uri.parse(baseUrl));

// //       if (response.statusCode == 200) {
// //         // Parse the JSON response
// //         var jsonData = json.decode(response.body);

// //         if (jsonData.isNotEmpty) {
// //           var lastSerialNumber = jsonData.last["serialno"];

// //           if (lastSerialNumber is int) {
// //             // If it's already an integer, you can directly use it
// //             serialNumber = (lastSerialNumber + 1).toString();
// //           } else if (lastSerialNumber is String) {
// //             // If it's a string, try to parse it to an integer
// //             parsedSerialNumber = int.tryParse(lastSerialNumber)!;

// //             if (parsedSerialNumber != null) {
// //               serialNumber = (parsedSerialNumber + 1).toString();
// //             } else {
// //               // Handle the case where the "serialno" cannot be parsed to an integer
// //               print('Unable to parse serial number as an integer.');
// //             }
// //           }

// //           // Display the final serial number
// //           print("Final Serial Number === $serialNumber");
// //         } else {
// //           // Handle the case where the "Member_details" array is empty
// //           print('No data found in "Member_details".');
// //         }
// //       } else {
// //         // Handle the case where the request to fetch serial number was not successful
// //         print(
// //             'Failed to fetch serial number. Server returned ${response.statusCode}. Response: ${response.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while fetching serial number: $e');
// //     }
// //   }

// //   Future<void> postFinalSerialNumber() async {
// //     try {
// //       await fetchSerialNumber();

// //       String baseUrl = "http://$complaint_management_link/PaymentRegID/";

// //       // You can use finalSerialNumber in the request body
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "serialno": serialNumber,
// //           // Add other required parameters here
// //         },
// //       );

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Payment_queue() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueue/";
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "cusid": bsiness_serialno.toString(),
// //           "billno": serialNumber,
// //           "name": name,
// //           "businessname": businessName,
// //           "contact": phoneno.toString(),
// //           "address": address,
// //           "softplan": "Silver",
// //           "amount": "299",
// //           "status": status,
// //           "dt": formattedDate,
// //           "type": "Online"
// //         },
// //       );

// //       if (postResponse.statusCode == 210) {
// //         // Parse the response JSON
// //         // var responseJson = json.decode(postResponse.body);

// //         // // Extract the 'billno' and its ID from the response
// //         // String billno = responseJson['billno'];
// //         // payment_queue_id = responseJson['id'];

// //         // print("Posted data successfully!");
// //         // print("billno: $billno");
// //         // print("ID: $payment_queue_id");
// //       } else {
// //         var responseJson = json.decode(postResponse.body);

// //         // Extract the 'billno' and its ID from the response
// //         String billno = responseJson['billno'];
// //         int payment_queue_id = responseJson['id'];

// //         print("Posted data successfully!");
// //         print("billno: $billno");
// //         print("ID: $payment_queue_id");
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: Text('Error'),
// //             content: Text('An error occurred: $e,'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: Text('OK'),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //       print('An error occurred: $e,');
// //     }
// //   }

// // // Define a NumberFormat instance for Indian currency formatting
// //   final NumberFormat numberFormat = NumberFormat.currency(
// //     customPattern: '###,###,###,###',
// //     symbol: '₹',
// //     decimalDigits: 0,
// //   );

// //   String getSilverPlanAmount() {
// //     final silverPlan = plans.firstWhere(
// //       (plan) => plan['planname'] == 'Silver',
// //       orElse: () => {},
// //     );

// //     if (silverPlan != null) {
// //       final planAmountString =
// //           silverPlan['planamount'].toString(); // Convert to string
// //       final planAmount = double.tryParse(planAmountString); // Parse to double

// //       if (planAmount != null) {
// //         final currencyFormatter = NumberFormat.currency(
// //           customPattern: '###,##,##,###', // Customize the pattern as needed
// //           symbol: '₹', // Your currency symbol
// //           decimalDigits: 0, // Number of decimal digits
// //         );
// //         return currencyFormatter.format(planAmount);
// //       }
// //     }

// //     // Return a default value if the "Silver" plan is not found or if planAmount is not a valid number.
// //     return 'Not Available';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 300,
// //             height: 400,
// //             decoration: BoxDecoration(
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, 2), // Offset to create a shadow below the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(2,
// //                         0), // Offset to create a shadow to the right of the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, -2), // Offset to create a shadow above the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(-2,
// //                         0), // Offset to create a shadow to the left of the container
// //                   ),
// //                 ],
// //                 color: Color.fromARGB(237, 255, 255, 255),
// //                 borderRadius: BorderRadius.circular(10)),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   SizedBox(
// //                     height: 15,
// //                   ),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       SizedBox(),
// //                       Text('Silver Payment',
// //                           style: TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.black,
// //                           )),
// //                     ],
// //                   ),
// //                   SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     children: [
// //                       SizedBox(
// //                         width: 25,
// //                       ),
// //                       Column(
// //                         children: [
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Full Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding

// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: name), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Business Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(10),
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15, top: 7, bottom: 7),
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller:
// //                                       TextEditingController(text: businessName),
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'City',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 15),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: city), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// //                     Container(
// //                       height: 40, // Set your desired height
// //                       decoration: BoxDecoration(
// //                         color: Color.fromARGB(0, 217, 211, 217),
// //                       ),
// //                       padding: EdgeInsets.only(top: 7, bottom: 7, left: 0),
// //                       child: Text(
// //                         '₹ ${getSilverPlanAmount()}',
// //                         style: TextStyle(
// //                           fontSize: 17,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     )
// //                   ]),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.all(10),
// //                         child: TextButton(
// //                           onPressed: () async {
// //                             Payment_queue();
// //                             postFinalSerialNumber();
// //                             createOrder();
// //                           },
// //                           style: TextButton.styleFrom(
// //                             primary: Colors.black,
// //                             backgroundColor: Colors.yellow,
// //                           ),
// //                           child: Padding(
// //                             padding: const EdgeInsets.only(
// //                               top: 5,
// //                               bottom: 5,
// //                               left: 15,
// //                               right: 15,
// //                             ),
// //                             child: Text(
// //                               'Pay Now',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class gold_payment extends StatefulWidget {
// //   const gold_payment({Key? key}) : super(key: key);

// //   @override
// //   State<gold_payment> createState() => _gold_paymentState();
// // }

// // class _gold_paymentState extends State<gold_payment> {
// //   late Razorpay _razorpay;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchBusinessDetails();
// //     Fetch_plan_amount();
// //     fetchSerialNumber();
// //     _razorpay = Razorpay();

// //     // Initialize Razorpay with your key and secret
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }

// //   String? paymentId;
// //   String? orderId;
// //   String? razorpaySignature;
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //     paymentId = response.paymentId;
// //     orderId = response.orderId;
// //     razorpaySignature = response.signature;
// //     print("Payment Success: ${response.paymentId}");
// //     print("Order ID: ${response.orderId}");
// //     print("Razor Singnature: ${response.signature}");

// //     deletePaymentQueueData();
// //     Success_Payment_queue_history();
// //     Update_software_amctbl();
// //     Update_traile_user();
// //     Update_SoftwareTrail_user();
// //     Check_payment_user();
// //     showSuccessMessage(context);
// //   }

// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     print("Payment Error: ${response.code} - ${response.message}");
// //     Failure_Payment_queue_history();
// //     deletePaymentQueueData();
// //     showFailMessage(context);
// //   }

// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     print("External Wallet: ${response.walletName}");
// //     // Failure_Payment_queue_history();
// //     // deleteData_Payment_queue();
// //   }

// //   void createOrder() async {
// //     String username = 'rzp_live_SyQY8IpVKCA2S5'; // razorpay pay key
// //     String password = "YgQuEml5GSeOFy9reD7lKOqV"; // razoepay secret key
// //     String basicAuth =
// //         'Basic ${base64Encode(utf8.encode('$username:$password'))}';

// //     Map<String, dynamic> body = {
// //       "amount": softwareamount * 100,
// //       "currency": "INR",
// //       "receipt": "rcptid_11",
// //       "payment_capture": 1,
// //     };

// //     var res = await http.post(
// //       Uri.https("api.razorpay.com", "v1/orders"),
// //       headers: <String, String>{
// //         "Content-Type": "application/json",
// //         'authorization': basicAuth,
// //       },
// //       body: jsonEncode(body),
// //     );

// //     if (res.statusCode == 200) {
// //       String orderId = jsonDecode(res.body)['id'];
// //       openCheckout(orderId, 1 * 100);
// //       print("order idddd :   ${orderId}");
// //     }
// //     print(res.body);
// //   }

// //   void openCheckout(String orderId, int amount) async {
// //     var options = {
// //       'key': 'rzp_live_SyQY8IpVKCA2S5',
// //       'amount': amount, // Amount in paise
// //       'name': 'Buyp Textile',
// //       'description': 'Payment for software renewal',
// //       // 'email': 'thilo@gmail.com',
// //       'capture': '1', // Capture the payment immediately
// //       'order_id': orderId, // Pass orderId to openCheckout
// //       "theme": {"color": "#FFFF00"}
// //     };

// //     if (Platform.isAndroid || Platform.isIOS) {
// //       _razorpay.open(options);
// //     } else if (kIsWeb) {
// //       // Handle web platform specific code here
// //       print("Web platform not supported yet");
// //     } else {
// //       // Handle other platforms or show an error
// //       print("Unsupported platform");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _razorpay.clear();
// //   }

// //   Future<void> Success_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Gold",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Success",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Failure_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Gold",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Failure",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   int deleted_payment_queue_id = 0;
// //   Future<void> getDataBySerialNo() async {
// //     String baseUrl = "http://$complaint_management_link/PaymentQueue/";

// //     try {
// //       final response = await http.get(Uri.parse(baseUrl));
// //       if (response.statusCode == 200) {
// //         // Parse the response JSON
// //         final List<Map<String, dynamic>> data =
// //             List<Map<String, dynamic>>.from(json.decode(response.body));

// //         // Find the item with the matching serial number
// //         final item = data.firstWhere(
// //             (item) => item['cusid'] == bsiness_serialno.toString(),
// //             orElse: () => {'id': null});

// //         if (item['id'] != null) {
// //           // Extract the 'id' from the item
// //           deleted_payment_queue_id = item['id'];

// //           print('Found item with id: $deleted_payment_queue_id');
// //         } else {
// //           print('Item not found with serial number: $bsiness_serialno');
// //         }
// //       } else {
// //         print('Failed to retrieve data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   Future<void> deletePaymentQueueData() async {
// //     await getDataBySerialNo();
// //     int id = deleted_payment_queue_id;
// //     print(deleted_payment_queue_id);
// //     final url =
// //         Uri.parse('https://payment.mybodottoday.com/paymentqueues/$id/');

// //     try {
// //       var response = await http.delete(url);

// //       while (response.statusCode == 301 || response.statusCode == 302) {
// //         // Handle the redirect by fetching the new URL
// //         final newUrl = Uri.parse(response.headers['location']!);
// //         response = await http.delete(newUrl);
// //       }

// //       if (response.statusCode == 204) {
// //         print('Data deleted successfully');
// //       } else {
// //         print('Failed to delete data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   Future<void> Update_software_amctbl() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 180));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "dt": formattedDate,
// //       "expirydt": formattedExpiryDate,
// //       "status": "Payment",
// //     };
// //     String ipAddress = '';
// //     String baseUrl = "http://$ipAddress/software_expire/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['serialno'] == bsiness_serialno.toString()) {
// //           // Assuming you want to update the record with 'id' equal to 3
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print('Failed to update data.');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Update_SoftwareTrail_user() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 180));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "trailstatus": "Payment",
// //       "tarilstartdate": formattedDate,
// //       "trailenddate": formattedExpiryDate,
// //     };

// //     String ipAddress = '';
// //     String baseUrl = "http://$ipAddress/Trailuser_registration/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['trailid'] == bsiness_serialno.toString()) {
// //           // Assuming you want to update the record with 'id' equal to 3
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print('Failed to update data.');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Update_traile_user() async {
// //     try {
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 180));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       final Map<String, String> dataToUpdate = {
// //         "tarilstartdate": formattedDate,
// //         "trailenddate": formattedExpiryDate,
// //         "trailstatus": "Payment",
// //         "closedate": formattedCloseDate
// //       };

// //       String baseUrl = "https://$complaint_management_link/TrailUsers/";
// //       final response1 = await http.get(Uri.parse(baseUrl));

// //       if (response1.statusCode == 200) {
// //         final data = json.decode(response1.body);

// //         for (var member in data) {
// //           if (member['trailid'] == bsiness_serialno.toString()) {
// //             final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //             print('Update URL: $updateUrl');
// //             print('Data to Update: $dataToUpdate');

// //             final response = await http.patch(
// //               updateUrl,
// //               body: json.encode(dataToUpdate),
// //               headers: {'Content-Type': 'application/json'},
// //             );

// //             if (response.statusCode == 200) {
// //               print('Data updated successfully.');
// //             } else {
// //               print(
// //                   'Failed to update data. Status code: ${response.statusCode}, Response: ${response.body}');
// //             }
// //           }
// //         }
// //       } else {
// //         print(
// //             'Failed to fetch initial data. Status code: ${response1.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }

// //   Future<void> Post_payment_user_regisrations() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 180));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       String baseUrl =
// //           "http://$complaint_management_link/PaymentUser_registration/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": serialNumber,
// //         "trailid": bsiness_serialno.toString(),
// //         "date": formattedDate,
// //         "fullname": name,
// //         "businessname": businessName,
// //         "phoneno": phoneno.toString(),
// //         "address": address,
// //         "state": state,
// //         "district": district,
// //         "city": city,
// //         "businessgstno": businessgstno,
// //         "planname": "Gold",
// //         "startdate": formattedDate,
// //         "enddate": formattedExpiryDate,
// //         "software": software,
// //         "status": status,
// //         "macid": macid,
// //         "amount": softwareamount.toString(),
// //         "noofusers": "0",
// //         "totalamount": "1730",
// //         "installdate": installdate,
// //         "closedate": formattedCloseDate
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //         print("Data posted Successfully ");
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Update_payment_user_registrations() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 180));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //     String formattedCloseDate =
// //         DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "startdate": formattedDate,
// //       "enddate": formattedExpiryDate,
// //       "closedate": formattedCloseDate,
// //       "planname": "Gold",
// //     };

// //     String baseUrl =
// //         "http://$complaint_management_link/PaymentUser_registration/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['trailid'] == bsiness_serialno.toString()) {
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //           print('Update URL: $updateUrl');
// //           print('Data to Update: $dataToUpdate');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print(
// //                 'Failed to update data. Status code: ${response.statusCode} , Response: ${response.body}');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Check_payment_user() async {
// //     String url = "http://$complaint_management_link/PaymentUser_registration/";

// //     final response = await http.get(Uri.parse(url));

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);
// //       String businessSerialNoString = bsiness_serialno.toString();

// //       bool foundMatchingTrailId = false;

// //       for (var member in data) {
// //         if (member['trailid'] == businessSerialNoString) {
// //           foundMatchingTrailId = true;
// //           break; // Exit the loop once a matching trailid is found
// //         }
// //       }

// //       if (foundMatchingTrailId) {
// //         // Call the Update_payment_user_registrations if a matching trailid is found
// //         Update_payment_user_registrations();
// //         print("Payment user Registration is updated successfully");
// //       } else {
// //         // Call the Post_payment_user_registrations if no matching trailid is found
// //         Post_payment_user_regisrations();
// //         print("Payment user Registration is posted successfully");
// //       }
// //     } else {
// //       // Handle the case when the GET request fails (e.g., handle errors).
// //       print(
// //           "Failed to fetch data from the server. Status code: ${response.statusCode}");
// //     }
// //   }

// //   void showSuccessMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Your Payment ₹$softwareamount/- has been successfully processed!!!'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void showFailMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Unfortunately, we were unable to process your payment (₹$softwareamount/-). Kindly double-check your payment information and try again'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   List<Map<String, dynamic>> plans = [];
// //   Future<void> Fetch_plan_amount() async {
// //     final response = await http
// //         .get(Uri.parse('http://$complaint_management_link/Plan_details/'));

// //     if (response.statusCode == 200) {
// //       List<dynamic> data = json.decode(response.body);

// //       final activePlans =
// //           data.where((plan) => plan['status'] == 'Active').toList();

// //       setState(() {
// //         plans = activePlans.cast<Map<String, dynamic>>();
// //       });
// //     }
// //   }

// //   int softwareamount = 1730;
// //   int bsiness_serialno = 0;
// //   String name = '';
// //   String businessName = '';
// //   String status = '';
// //   String address = '';
// //   String state = '';
// //   String district = '';
// //   String city = '';
// //   String tarilstartdate = '';
// //   String trailenddate = '';
// //   String software = '';
// //   String macid = '';
// //   String trailstatus = '';
// //   String installdate = '';
// //   int phoneno = 0;
// //   String businessgstno = '';
// //   Future<void> fetchBusinessDetails() async {
// //     try {
// //       String ipAddress = '';
// //       final apiUrl = 'http://$ipAddress/Trailuser_registration/';
// //       final response = await http.get(Uri.parse(apiUrl));

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);

// //         if (data is List && data.isNotEmpty) {
// //           final item = data[0] as Map<String, dynamic>;
// //           bsiness_serialno = int.tryParse(item["trailid"].toString()) ?? 0;
// //           name = item["fullname"].toString();
// //           businessName = item["businessname"].toString();
// //           city = item["city"].toString();
// //           state = item["state"].toString();
// //           district = item["district"]
// //               .toString(); // Handle the address separately to display "null" for empty, null, or whitespace-only values
// //           final addressValue = item["address"];
// //           if (addressValue == null || addressValue.trim().isEmpty) {
// //             address = "null";
// //           } else {
// //             address = addressValue.toString();
// //           }
// //           status = item["status"].toString();
// //           tarilstartdate = item["tarilstartdate"].toString();
// //           trailenddate = item["trailenddate"].toString();
// //           macid = item["macid"].toString();
// //           software = item["software"].toString();
// //           trailstatus = item["trailstatus"].toString();
// //           installdate = item["installdate"].toString();
// //           businessgstno = item["businessgstno"].toString();
// //           phoneno = int.tryParse(item["phoneno"].toString()) ?? 0;

// //           print("bsiness_serialno : $bsiness_serialno");
// //           print("Name : $name");
// //           print("Bsiness Name : $businessName");
// //           print("City : $city");
// //           print("address : $address");
// //           print("contact : $phoneno");
// //           print("Status : $status");
// //           print("district : $district");
// //           print("State : $state");
// //           print("tarilstartdate : $tarilstartdate");
// //           print("trailenddate : $trailenddate");
// //           print("macid : $macid");
// //           print("software : $software");
// //           print("trailstatus : $trailstatus");
// //           print("businessgstno : $businessgstno");
// //           print("installdate : $installdate");
// //         } else {
// //           print('No data in the response');
// //         }
// //       } else {
// //         print('Request failed with status: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error occurred: $e');
// //     }
// //   }

// //   String serialNumber = '';
// //   int payment_queue_id = 0;
// //   int parsedSerialNumber = 0;
// //   Future<void> fetchSerialNumber() async {
// //     try {
// //       String baseUrl = 'http://$complaint_management_link/PaymentRegID/';
// //       var response = await http.get(Uri.parse(baseUrl));

// //       if (response.statusCode == 200) {
// //         // Parse the JSON response
// //         var jsonData = json.decode(response.body);

// //         if (jsonData.isNotEmpty) {
// //           var lastSerialNumber = jsonData.last["serialno"];

// //           if (lastSerialNumber is int) {
// //             // If it's already an integer, you can directly use it
// //             serialNumber = (lastSerialNumber + 1).toString();
// //           } else if (lastSerialNumber is String) {
// //             // If it's a string, try to parse it to an integer
// //             parsedSerialNumber = int.tryParse(lastSerialNumber)!;

// //             if (parsedSerialNumber != null) {
// //               serialNumber = (parsedSerialNumber + 1).toString();
// //             } else {
// //               // Handle the case where the "serialno" cannot be parsed to an integer
// //               print('Unable to parse serial number as an integer.');
// //             }
// //           }

// //           // Display the final serial number
// //           print("Final Serial Number === $serialNumber");
// //         } else {
// //           // Handle the case where the "Member_details" array is empty
// //           print('No data found in "Member_details".');
// //         }
// //       } else {
// //         // Handle the case where the request to fetch serial number was not successful
// //         print(
// //             'Failed to fetch serial number. Server returned ${response.statusCode}. Response: ${response.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while fetching serial number: $e');
// //     }
// //   }

// //   Future<void> postFinalSerialNumber() async {
// //     try {
// //       await fetchSerialNumber();

// //       String baseUrl = "http://$complaint_management_link/PaymentRegID/";

// //       // You can use finalSerialNumber in the request body
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "serialno": serialNumber,
// //           // Add other required parameters here
// //         },
// //       );

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Payment_queue() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueue/";
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "cusid": bsiness_serialno.toString(),
// //           "billno": serialNumber,
// //           "name": name,
// //           "businessname": businessName,
// //           "contact": phoneno.toString(),
// //           "address": address,
// //           "softplan": "Gold",
// //           "amount": "1730",
// //           "status": status,
// //           "dt": formattedDate,
// //           "type": "Online"
// //         },
// //       );

// //       if (postResponse.statusCode == 210) {
// //         // Parse the response JSON
// //         // var responseJson = json.decode(postResponse.body);

// //         // // Extract the 'billno' and its ID from the response
// //         // String billno = responseJson['billno'];
// //         // payment_queue_id = responseJson['id'];

// //         // print("Posted data successfully!");
// //         // print("billno: $billno");
// //         // print("ID: $payment_queue_id");
// //       } else {
// //         var responseJson = json.decode(postResponse.body);

// //         // Extract the 'billno' and its ID from the response
// //         String billno = responseJson['billno'];
// //         int payment_queue_id = responseJson['id'];

// //         print("Posted data successfully!");
// //         print("billno: $billno");
// //         print("ID: $payment_queue_id");
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: Text('Error'),
// //             content: Text('An error occurred: $e,'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: Text('OK'),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //       print('An error occurred: $e,');
// //     }
// //   }

// //   String getSilverPlanAmount() {
// //     final silverPlan = plans.firstWhere(
// //       (plan) => plan['planname'] == 'Gold',
// //       orElse: () => {},
// //     );

// //     if (silverPlan != null) {
// //       final planAmountString =
// //           silverPlan['planamount'].toString(); // Convert to string
// //       final planAmount = double.tryParse(planAmountString); // Parse to double

// //       if (planAmount != null) {
// //         final currencyFormatter = NumberFormat.currency(
// //           customPattern: '###,##,##,###', // Customize the pattern as needed
// //           symbol: '₹', // Your currency symbol
// //           decimalDigits: 0, // Number of decimal digits
// //         );
// //         return currencyFormatter.format(planAmount);
// //       }
// //     }

// //     // Return a default value if the "Silver" plan is not found or if planAmount is not a valid number.
// //     return 'Not Available';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 300,
// //             height: 400,
// //             decoration: BoxDecoration(
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, 2), // Offset to create a shadow below the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(2,
// //                         0), // Offset to create a shadow to the right of the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, -2), // Offset to create a shadow above the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(-2,
// //                         0), // Offset to create a shadow to the left of the container
// //                   ),
// //                 ],
// //                 color: Color.fromARGB(237, 255, 255, 255),
// //                 borderRadius: BorderRadius.circular(10)),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   SizedBox(
// //                     height: 15,
// //                   ),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       SizedBox(),
// //                       Text('Gold Payment',
// //                           style: TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.black,
// //                           )),
// //                     ],
// //                   ),
// //                   SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     children: [
// //                       SizedBox(
// //                         width: 25,
// //                       ),
// //                       Column(
// //                         children: [
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Full Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding

// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: name), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Business Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(10),
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15, top: 7, bottom: 7),
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller:
// //                                       TextEditingController(text: businessName),
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'City',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 15),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 217, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: city), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// //                     Container(
// //                       height: 40, // Set your desired height
// //                       decoration: BoxDecoration(
// //                         color: Color.fromARGB(0, 217, 211, 217),
// //                       ),
// //                       padding: EdgeInsets.only(top: 7, bottom: 7, left: 0),
// //                       child: Text(
// //                         '₹ ${getSilverPlanAmount()}',
// //                         style: TextStyle(
// //                           fontSize: 17,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     )
// //                   ]),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.all(10),
// //                         child: TextButton(
// //                           onPressed: () async {
// //                             Payment_queue();
// //                             postFinalSerialNumber();
// //                             createOrder();
// //                           },
// //                           style: TextButton.styleFrom(
// //                             primary: Colors.black,
// //                             backgroundColor: Colors.yellow,
// //                           ),
// //                           child: Padding(
// //                             padding: const EdgeInsets.only(
// //                               top: 5,
// //                               bottom: 5,
// //                               left: 15,
// //                               right: 15,
// //                             ),
// //                             child: Text(
// //                               'Pay Now',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class diamend_payments extends StatefulWidget {
// //   const diamend_payments({Key? key}) : super(key: key);

// //   @override
// //   State<diamend_payments> createState() => _diamend_paymentsState();
// // }

// // class _diamend_paymentsState extends State<diamend_payments> {
// //   late Razorpay _razorpay;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchBusinessDetails();
// //     Fetch_plan_amount();
// //     fetchSerialNumber();
// //     _razorpay = Razorpay();

// //     // Initialize Razorpay with your key and secret
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //   }

// //   String? paymentId;
// //   String? orderId;
// //   String? razorpaySignature;
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) {
// //     paymentId = response.paymentId;
// //     orderId = response.orderId;
// //     razorpaySignature = response.signature;
// //     print("Payment Success: ${response.paymentId}");
// //     print("Order ID: ${response.orderId}");
// //     print("Razor Singnature: ${response.signature}");

// //     deletePaymentQueueData();
// //     Success_Payment_queue_history();
// //     Update_software_amctbl();
// //     Update_traile_user();
// //     Update_SoftwareTrail_user();
// //     Check_payment_user();
// //     showSuccessMessage(context);
// //   }

// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     print("Payment Error: ${response.code} - ${response.message}");
// //     Failure_Payment_queue_history();
// //     deletePaymentQueueData();
// //     showFailMessage(context);
// //   }

// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     print("External Wallet: ${response.walletName}");
// //     // Failure_Payment_queue_history();
// //     // deleteData_Payment_queue();
// //   }

// //   void createOrder() async {
// //     String username = 'rzp_live_SyQY8IpVKCA2S5'; // razorpay pay key
// //     String password = "YgQuEml5GSeOFy9reD7lKOqV"; // razoepay secret key
// //     String basicAuth =
// //         'Basic ${base64Encode(utf8.encode('$username:$password'))}';

// //     Map<String, dynamic> body = {
// //       "amount": softwareamount * 100,
// //       "currency": "INR",
// //       "receipt": "rcptid_11",
// //       "payment_capture": 1,
// //     };

// //     var res = await http.post(
// //       Uri.https("api.razorpay.com", "v1/orders"),
// //       headers: <String, String>{
// //         "Content-Type": "application/json",
// //         'authorization': basicAuth,
// //       },
// //       body: jsonEncode(body),
// //     );

// //     if (res.statusCode == 200) {
// //       String orderId = jsonDecode(res.body)['id'];
// //       openCheckout(orderId, 1 * 100);
// //       print("order idddd :   ${orderId}");
// //     }
// //     print(res.body);
// //   }

// //   void openCheckout(String orderId, int amount) async {
// //     var options = {
// //       'key': 'rzp_live_SyQY8IpVKCA2S5',
// //       'amount': amount, // Amount in paise
// //       'name': 'Buyp Textile',
// //       'description': 'Payment for software renewal',
// //       // 'email': 'thilo@gmail.com',
// //       'capture': '1', // Capture the payment immediately
// //       'order_id': orderId, // Pass orderId to openCheckout
// //       "theme": {"color": "#FFFF00"}
// //     };

// //     if (Platform.isAndroid || Platform.isIOS) {
// //       _razorpay.open(options);
// //     } else if (kIsWeb) {
// //       // Handle web platform specific code here
// //       print("Web platform not supported yet");
// //     } else {
// //       // Handle other platforms or show an error
// //       print("Unsupported platform");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _razorpay.clear();
// //   }

// //   Future<void> Success_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Diamand",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Success",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Failure_Payment_queue_history() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();

// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueueHistory/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": bsiness_serialno.toString(),
// //         "billno": parsedSerialNumber.toString(),
// //         "name": name,
// //         "businessname": businessName,
// //         "contact": phoneno.toString(),
// //         "address": address,
// //         "softplan": "Diamand",
// //         "amount": softwareamount.toString(),
// //         "status": status,
// //         "dt": formattedDate,
// //         "RazorPaymentId": paymentId ?? "null",
// //         "RazorOrderId": orderId ?? "null",
// //         "RazorSignature": truncatedRazorSignature, // Use the truncated value
// //         "PaymentStatus": "Failure",
// //         "type": "Online"
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   int deleted_payment_queue_id = 0;
// //   Future<void> getDataBySerialNo() async {
// //     String baseUrl = "http://$complaint_management_link/PaymentQueue/";

// //     try {
// //       final response = await http.get(Uri.parse(baseUrl));
// //       if (response.statusCode == 200) {
// //         // Parse the response JSON
// //         final List<Map<String, dynamic>> data =
// //             List<Map<String, dynamic>>.from(json.decode(response.body));

// //         // Find the item with the matching serial number
// //         final item = data.firstWhere(
// //             (item) => item['cusid'] == bsiness_serialno.toString(),
// //             orElse: () => {'id': null});

// //         if (item['id'] != null) {
// //           // Extract the 'id' from the item
// //           deleted_payment_queue_id = item['id'];

// //           print('Found item with id: $deleted_payment_queue_id');
// //         } else {
// //           print('Item not found with serial number: $bsiness_serialno');
// //         }
// //       } else {
// //         print('Failed to retrieve data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   Future<void> deletePaymentQueueData() async {
// //     await getDataBySerialNo();
// //     int id = deleted_payment_queue_id;
// //     print(deleted_payment_queue_id);
// //     final url =
// //         Uri.parse('https://payment.mybodottoday.com/paymentqueues/$id/');

// //     try {
// //       var response = await http.delete(url);

// //       while (response.statusCode == 301 || response.statusCode == 302) {
// //         // Handle the redirect by fetching the new URL
// //         final newUrl = Uri.parse(response.headers['location']!);
// //         response = await http.delete(newUrl);
// //       }

// //       if (response.statusCode == 204) {
// //         print('Data deleted successfully');
// //       } else {
// //         print('Failed to delete data. Status code: ${response.statusCode}');
// //         print('Response body: ${response.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred: $e');
// //     }
// //   }

// //   Future<void> Update_software_amctbl() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 365));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "dt": formattedDate,
// //       "expirydt": formattedExpiryDate,
// //       "status": "Payment",
// //     };

// //     String ipAddress = '';
// //     String baseUrl = "http://$ipAddress/software_expire/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['serialno'] == bsiness_serialno.toString()) {
// //           // Assuming you want to update the record with 'id' equal to 3
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print('Failed to update data.');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Update_SoftwareTrail_user() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 365));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "trailstatus": "Payment",
// //       "tarilstartdate": formattedDate,
// //       "trailenddate": formattedExpiryDate,
// //     };

// //     String ipAddress = '';
// //     String baseUrl = "http://$ipAddress/Trailuser_registration/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['trailid'] == bsiness_serialno.toString()) {
// //           // Assuming you want to update the record with 'id' equal to 3
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print('Failed to update data.');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Update_traile_user() async {
// //     try {
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 365));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);

// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       final Map<String, String> dataToUpdate = {
// //         "tarilstartdate": formattedDate,
// //         "trailenddate": formattedExpiryDate,
// //         "trailstatus": "Payment",
// //         "closedate": formattedCloseDate
// //       };

// //       String baseUrl = "https://$complaint_management_link/TrailUsers/";
// //       final response1 = await http.get(Uri.parse(baseUrl));

// //       if (response1.statusCode == 200) {
// //         final data = json.decode(response1.body);

// //         for (var member in data) {
// //           if (member['trailid'] == bsiness_serialno.toString()) {
// //             final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //             print('Update URL: $updateUrl');
// //             print('Data to Update: $dataToUpdate');

// //             final response = await http.patch(
// //               updateUrl,
// //               body: json.encode(dataToUpdate),
// //               headers: {'Content-Type': 'application/json'},
// //             );

// //             if (response.statusCode == 200) {
// //               print('Data updated successfully.');
// //             } else {
// //               print(
// //                   'Failed to update data. Status code: ${response.statusCode}, Response: ${response.body}');
// //             }
// //           }
// //         }
// //       } else {
// //         print(
// //             'Failed to fetch initial data. Status code: ${response1.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }

// //   Future<void> Post_payment_user_regisrations() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       DateTime now = DateTime.now();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //       DateTime expiryDate = now.add(Duration(days: 365));
// //       String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //       String formattedCloseDate =
// //           DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //       String baseUrl =
// //           "http://$complaint_management_link/PaymentUser_registration/";

// //       // Truncate or shorten the RazorSignature to 30 characters
// //       String truncatedRazorSignature = razorpaySignature ?? "null";
// //       if (truncatedRazorSignature.length > 30) {
// //         truncatedRazorSignature = truncatedRazorSignature.substring(0, 30);
// //       }

// //       var postResponse = await http.post(Uri.parse(baseUrl), headers: {
// //         "Accept": "application/json",
// //         "Access-Control-Allow-Origin": "*",
// //       }, body: {
// //         "cusid": serialNumber,
// //         "trailid": bsiness_serialno.toString(),
// //         "date": formattedDate,
// //         "fullname": name,
// //         "businessname": businessName,
// //         "phoneno": phoneno.toString(),
// //         "address": address,
// //         "state": state,
// //         "district": district,
// //         "city": city,
// //         "businessgstno": businessgstno,
// //         "planname": "Diamand",
// //         "startdate": formattedDate,
// //         "enddate": formattedExpiryDate,
// //         "software": software,
// //         "status": status,
// //         "macid": macid,
// //         "amount": softwareamount.toString(),
// //         "noofusers": "0",
// //         "totalamount": "3000",
// //         "installdate": installdate,
// //         "closedate": formattedCloseDate
// //       });

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //         print("Data posted Successfully ");
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Update_payment_user_registrations() async {
// //     DateTime now = DateTime.now();
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(now);

// //     DateTime expiryDate = now.add(Duration(days: 365));
// //     String formattedExpiryDate = DateFormat('yyyy-MM-dd').format(expiryDate);
// //     String formattedCloseDate =
// //         DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

// //     final Map<String, String> dataToUpdate = {
// //       "startdate": formattedDate,
// //       "enddate": formattedExpiryDate,
// //       "closedate": formattedCloseDate,
// //       "planname": "Diamand",
// //     };

// //     String baseUrl =
// //         "http://$complaint_management_link/PaymentUser_registration/";
// //     final response1 = await http.get(Uri.parse(baseUrl));

// //     if (response1.statusCode == 200) {
// //       final data = json.decode(response1.body);

// //       for (var member in data) {
// //         if (member['trailid'] == bsiness_serialno.toString()) {
// //           final Uri updateUrl = Uri.parse('$baseUrl${member['id']}/');
// //           print('Update URL: $updateUrl');
// //           print('Data to Update: $dataToUpdate');

// //           final response = await http.patch(
// //             updateUrl,
// //             body: json.encode(dataToUpdate),
// //             headers: {'Content-Type': 'application/json'},
// //           );

// //           if (response.statusCode == 200) {
// //             print('Data updated successfully.');
// //           } else {
// //             print(
// //                 'Failed to update data. Status code: ${response.statusCode} , Response: ${response.body}');
// //           }
// //         }
// //       }
// //     }
// //   }

// //   Future<void> Check_payment_user() async {
// //     String url = "http://$complaint_management_link/PaymentUser_registration/";

// //     final response = await http.get(Uri.parse(url));

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);
// //       String businessSerialNoString = bsiness_serialno.toString();

// //       bool foundMatchingTrailId = false;

// //       for (var member in data) {
// //         if (member['trailid'] == businessSerialNoString) {
// //           foundMatchingTrailId = true;
// //           break; // Exit the loop once a matching trailid is found
// //         }
// //       }

// //       if (foundMatchingTrailId) {
// //         // Call the Update_payment_user_registrations if a matching trailid is found
// //         Update_payment_user_registrations();
// //         print("Payment user Registration is updated successfully");
// //       } else {
// //         // Call the Post_payment_user_registrations if no matching trailid is found
// //         Post_payment_user_regisrations();
// //         print("Payment user Registration is posted successfully");
// //       }
// //     } else {
// //       // Handle the case when the GET request fails (e.g., handle errors).
// //       print(
// //           "Failed to fetch data from the server. Status code: ${response.statusCode}");
// //     }
// //   }

// //   void showSuccessMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Your Payment ₹$softwareamount/- has been successfully processed!!!'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void showFailMessage(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.0),
// //           ),
// //           elevation: 0.0,
// //           backgroundColor: Color.fromARGB(255, 255, 255, 231),
// //           child: Container(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   'InFo',
// //                   style: TextStyle(
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16.0),
// //                 Text(
// //                     'Unfortunately, we were unable to process your payment (₹$softwareamount/-). Kindly double-check your payment information and try again'),
// //                 SizedBox(height: 16.0),
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                   },
// //                   child: Text('OK'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   List<Map<String, dynamic>> plans = [];
// //   Future<void> Fetch_plan_amount() async {
// //     final response = await http
// //         .get(Uri.parse('http://$complaint_management_link/Plan_details/'));

// //     if (response.statusCode == 200) {
// //       List<dynamic> data = json.decode(response.body);

// //       final activePlans =
// //           data.where((plan) => plan['status'] == 'Active').toList();

// //       setState(() {
// //         plans = activePlans.cast<Map<String, dynamic>>();
// //       });
// //     }
// //   }

// //   int softwareamount = 3000;
// //   int bsiness_serialno = 0;
// //   String name = '';
// //   String businessName = '';
// //   String status = '';
// //   String address = '';
// //   String state = '';
// //   String district = '';
// //   String city = '';
// //   String tarilstartdate = '';
// //   String trailenddate = '';
// //   String software = '';
// //   String macid = '';
// //   String trailstatus = '';
// //   String installdate = '';
// //   int phoneno = 0;
// //   String businessgstno = '';
// //   Future<void> fetchBusinessDetails() async {
// //     try {
// //       String ipAddress = '';
// //       final apiUrl = 'http://$ipAddress/Trailuser_registration/';
// //       final response = await http.get(Uri.parse(apiUrl));

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);

// //         if (data is List && data.isNotEmpty) {
// //           final item = data[0] as Map<String, dynamic>;
// //           bsiness_serialno = int.tryParse(item["trailid"].toString()) ?? 0;
// //           name = item["fullname"].toString();
// //           businessName = item["businessname"].toString();
// //           city = item["city"].toString();
// //           state = item["state"].toString();
// //           district = item["district"]
// //               .toString(); // Handle the address separately to display "null" for empty, null, or whitespace-only values
// //           final addressValue = item["address"];
// //           if (addressValue == null || addressValue.trim().isEmpty) {
// //             address = "null";
// //           } else {
// //             address = addressValue.toString();
// //           }
// //           status = item["status"].toString();
// //           tarilstartdate = item["tarilstartdate"].toString();
// //           trailenddate = item["trailenddate"].toString();
// //           macid = item["macid"].toString();
// //           software = item["software"].toString();
// //           trailstatus = item["trailstatus"].toString();
// //           installdate = item["installdate"].toString();
// //           businessgstno = item["businessgstno"].toString();
// //           phoneno = int.tryParse(item["phoneno"].toString()) ?? 0;

// //           print("bsiness_serialno : $bsiness_serialno");
// //           print("Name : $name");
// //           print("Bsiness Name : $businessName");
// //           print("City : $city");
// //           print("address : $address");
// //           print("contact : $phoneno");
// //           print("Status : $status");
// //           print("district : $district");
// //           print("State : $state");
// //           print("tarilstartdate : $tarilstartdate");
// //           print("trailenddate : $trailenddate");
// //           print("macid : $macid");
// //           print("software : $software");
// //           print("trailstatus : $trailstatus");
// //           print("businessgstno : $businessgstno");
// //           print("installdate : $installdate");
// //         } else {
// //           print('No data in the response');
// //         }
// //       } else {
// //         print('Request failed with status: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error occurred: $e');
// //     }
// //   }

// //   String serialNumber = '';
// //   int payment_queue_id = 0;
// //   int parsedSerialNumber = 0;
// //   Future<void> fetchSerialNumber() async {
// //     try {
// //       String baseUrl = 'http://$complaint_management_link/PaymentRegID/';
// //       var response = await http.get(Uri.parse(baseUrl));

// //       if (response.statusCode == 200) {
// //         // Parse the JSON response
// //         var jsonData = json.decode(response.body);

// //         if (jsonData.isNotEmpty) {
// //           var lastSerialNumber = jsonData.last["serialno"];

// //           if (lastSerialNumber is int) {
// //             // If it's already an integer, you can directly use it
// //             serialNumber = (lastSerialNumber + 1).toString();
// //           } else if (lastSerialNumber is String) {
// //             // If it's a string, try to parse it to an integer
// //             parsedSerialNumber = int.tryParse(lastSerialNumber)!;

// //             if (parsedSerialNumber != null) {
// //               serialNumber = (parsedSerialNumber + 1).toString();
// //             } else {
// //               // Handle the case where the "serialno" cannot be parsed to an integer
// //               print('Unable to parse serial number as an integer.');
// //             }
// //           }

// //           // Display the final serial number
// //           print("Final Serial Number === $serialNumber");
// //         } else {
// //           // Handle the case where the "Member_details" array is empty
// //           print('No data found in "Member_details".');
// //         }
// //       } else {
// //         // Handle the case where the request to fetch serial number was not successful
// //         print(
// //             'Failed to fetch serial number. Server returned ${response.statusCode}. Response: ${response.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while fetching serial number: $e');
// //     }
// //   }

// //   Future<void> postFinalSerialNumber() async {
// //     try {
// //       await fetchSerialNumber();

// //       String baseUrl = "http://$complaint_management_link/PaymentRegID/";

// //       // You can use finalSerialNumber in the request body
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "serialno": serialNumber,
// //           // Add other required parameters here
// //         },
// //       );

// //       if (postResponse.statusCode == 200) {
// //         print('Final Serial Number posted successfully: $serialNumber');
// //       } else {
// //         print(
// //             'Failed to post final serial number. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       print('An error occurred while posting final serial number: $e');
// //     }
// //   }

// //   Future<void> Payment_queue() async {
// //     try {
// //       await fetchSerialNumber();
// //       await fetchBusinessDetails();
// //       String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //       String baseUrl = "http://$complaint_management_link/PaymentQueue/";
// //       var postResponse = await http.post(
// //         Uri.parse(baseUrl),
// //         headers: {
// //           "Accept": "application/json",
// //           "Access-Control-Allow-Origin": "*",
// //         },
// //         body: {
// //           "cusid": bsiness_serialno.toString(),
// //           "billno": serialNumber,
// //           "name": name,
// //           "businessname": businessName,
// //           "contact": phoneno.toString(),
// //           "address": address,
// //           "softplan": "Diamand",
// //           "amount": "3000",
// //           "status": status,
// //           "dt": formattedDate,
// //           "type": "Online"
// //         },
// //       );

// //       if (postResponse.statusCode == 210) {
// //         // Parse the response JSON
// //         // var responseJson = json.decode(postResponse.body);

// //         // // Extract the 'billno' and its ID from the response
// //         // String billno = responseJson['billno'];
// //         // payment_queue_id = responseJson['id'];

// //         // print("Posted data successfully!");
// //         // print("billno: $billno");
// //         // print("ID: $payment_queue_id");
// //       } else {
// //         var responseJson = json.decode(postResponse.body);

// //         // Extract the 'billno' and its ID from the response
// //         String billno = responseJson['billno'];
// //         int payment_queue_id = responseJson['id'];

// //         print("Posted data successfully!");
// //         print("billno: $billno");
// //         print("ID: $payment_queue_id");
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //         print(
// //             'Failed to insert data. Server returned ${postResponse.statusCode}. Response: ${postResponse.body}');
// //       }
// //     } catch (e) {
// //       // Handle any other errors that may occur
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: Text('Error'),
// //             content: Text('An error occurred: $e,'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: Text('OK'),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //       print('An error occurred: $e,');
// //     }
// //   }

// //   String getSilverPlanAmount() {
// //     final silverPlan = plans.firstWhere(
// //       (plan) => plan['planname'] == 'Diamond',
// //       orElse: () => {},
// //     );

// //     if (silverPlan != null) {
// //       final planAmountString =
// //           silverPlan['planamount'].toString(); // Convert to string
// //       final planAmount = double.tryParse(planAmountString); // Parse to double

// //       if (planAmount != null) {
// //         final currencyFormatter = NumberFormat.currency(
// //           customPattern: '###,##,##,###', // Customize the pattern as needed
// //           symbol: '₹', // Your currency symbol
// //           decimalDigits: 0, // Number of decimal digits
// //         );
// //         return currencyFormatter.format(planAmount);
// //       }
// //     }

// //     // Return a default value if the "Silver" plan is not found or if planAmount is not a valid number.
// //     return 'Not Available';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 300,
// //             height: 400,
// //             decoration: BoxDecoration(
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, 2), // Offset to create a shadow below the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(2,
// //                         0), // Offset to create a shadow to the right of the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(
// //                         0, -2), // Offset to create a shadow above the container
// //                   ),
// //                   BoxShadow(
// //                     color: Color.fromARGB(255, 70, 70, 70).withOpacity(0.5),
// //                     spreadRadius: 2,
// //                     blurRadius: 4,
// //                     offset: Offset(-2,
// //                         0), // Offset to create a shadow to the left of the container
// //                   ),
// //                 ],
// //                 color: Color.fromARGB(237, 255, 255, 255),
// //                 borderRadius: BorderRadius.circular(10)),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   SizedBox(
// //                     height: 15,
// //                   ),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       SizedBox(),
// //                       Text('Diamand Payment',
// //                           style: TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.black,
// //                           )),
// //                     ],
// //                   ),
// //                   SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     children: [
// //                       SizedBox(
// //                         width: 25,
// //                       ),
// //                       Column(
// //                         children: [
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Full Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding

// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: name), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'Business Name',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 216, 217, 211),
// //                                   borderRadius: BorderRadius.circular(10),
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15, top: 7, bottom: 7),
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller:
// //                                       TextEditingController(text: businessName),
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 5),
// //                             child: Container(
// //                               width: Responsive.isMobile(context)
// //                                   ? MediaQuery.of(context).size.width * 0.5
// //                                   : 250,
// //                               padding: EdgeInsets.all(5),
// //                               child: Text(
// //                                 'City',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w500,
// //                                   color: Colors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 15),
// //                             child: Container(
// //                                 width: Responsive.isMobile(context)
// //                                     ? MediaQuery.of(context).size.width * 0.5
// //                                     : 250,
// //                                 height: 35,
// //                                 decoration: BoxDecoration(
// //                                   color: Color.fromARGB(255, 217, 217, 211),
// //                                   borderRadius: BorderRadius.circular(
// //                                       10), // Adjust the radius as needed
// //                                 ),
// //                                 padding: EdgeInsets.only(
// //                                     left: 15,
// //                                     top: 7,
// //                                     bottom:
// //                                         7), // Adjust the top and bottom padding
// //                                 child: TextField(
// //                                   readOnly: true, // Make it read-only
// //                                   controller: TextEditingController(
// //                                       text: city), // Set the initial value
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     color: Colors.black,
// //                                   ),
// //                                   decoration: InputDecoration(
// //                                     border: InputBorder.none,
// //                                     focusedBorder: InputBorder.none,
// //                                     enabledBorder: InputBorder.none,
// //                                   ),
// //                                 )),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// //                     Container(
// //                       height: 40, // Set your desired height
// //                       decoration: BoxDecoration(
// //                         color: Color.fromARGB(0, 217, 211, 217),
// //                       ),
// //                       padding: EdgeInsets.only(top: 7, bottom: 7, left: 0),
// //                       child: Text(
// //                         '₹ ${getSilverPlanAmount()}',
// //                         style: TextStyle(
// //                           fontSize: 17,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     )
// //                   ]),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.all(10),
// //                         child: TextButton(
// //                           onPressed: () async {
// //                             Payment_queue();
// //                             postFinalSerialNumber();
// //                             createOrder();
// //                           },
// //                           style: TextButton.styleFrom(
// //                             primary: Colors.black,
// //                             backgroundColor: Colors.yellow,
// //                           ),
// //                           child: Padding(
// //                             padding: const EdgeInsets.only(
// //                               top: 5,
// //                               bottom: 5,
// //                               left: 15,
// //                               right: 15,
// //                             ),
// //                             child: Text(
// //                               'Pay Now',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
