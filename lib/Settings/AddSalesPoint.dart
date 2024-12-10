import 'dart:convert';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:ProductRestaurant/Sidebar/SidebarMainPage.dart';

class AddSalesPointSetting extends StatefulWidget {
  const AddSalesPointSetting({Key? key}) : super(key: key);

  @override
  State<AddSalesPointSetting> createState() => _AddSalesPointSettingState();
}

class _AddSalesPointSettingState extends State<AddSalesPointSetting> {
  List<Map<String, dynamic>> tableData = [];
  final TextEditingController _pointController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  FocusNode pointFocus = FocusNode();
  FocusNode amountFocus = FocusNode();

  String id = '';

  void initState() {
    super.initState();
    fetchData();
    fetchsidebarmenulist();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/PointSetting/$cusid/';

    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<Map<String, dynamic>> paylist = [];

      for (var item in data) {
        String? point = item['point'];
        String? amount = item['amount'];
        id = item['id'].toString();

        paylist.add({
          'point': point,
          'amount': amount,
        });
      }

      setState(() {
        tableData = paylist;
        if (tableData.isNotEmpty) {
          double? amount = double.tryParse(tableData.first['amount'] ?? '');
          _amountController.text =
              amount?.toStringAsFixed(amount % 1 == 0 ? 0 : 2) ?? '';

          double? point = double.tryParse(tableData.first['point'] ?? '');
          _pointController.text =
              point?.toStringAsFixed(point % 1 == 0 ? 0 : 2) ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Point Setting',
                        style: HeadingStyle,
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: adminUpdate(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget adminUpdate() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildInputSection(),
      ],
    ));
  }

  Widget buildInputSection() {
    return Container(
      width: Responsive.isDesktop(context) ? 500 : 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/imgs/point.png',
              height: Responsive.isDesktop(context) ? 250 : 180,
              width: Responsive.isDesktop(context) ? 250 : 200,
            ),
          ),
          SizedBox(height: 15),
          buildInputField(
              'Point', _pointController, pointFocus, Icons.control_point),
          SizedBox(height: 15),
          buildInputField(
              'Amount', _amountController, amountFocus, Icons.currency_rupee),
          SizedBox(height: 25),
          Center(
            child: ElevatedButton(
              onPressed: updateData,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                backgroundColor: subcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Update',
                style: commonWhiteStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller,
      FocusNode focusNode, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: commonLabelTextStyle.copyWith(fontSize: 16),
        ),
        SizedBox(height: 10),
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          style: TextStyle(
            fontSize: 30,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          ),
        ),
      ],
    );
  }

  void WarninngMessage() {
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
                    'Failed to update..!!',
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

  Future<void> updateData() async {
    try {
      final String point = _pointController.text;
      final String amount = _amountController.text;

      if (point.isNotEmpty && amount.isNotEmpty) {
        final Uri apiUrl = Uri.parse('$IpAddress/PointSettingalldatas/$id/');

        String? cusid = await SharedPrefs.getCusId();
        final Map<String, dynamic> data = {
          "cusid": "$cusid",
          "point": point,
          "amount": amount,
        };

        final response = await http.patch(
          apiUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic>? pointDetails = json.decode(response.body);

          if (pointDetails != null) {
            setState(() {
              _pointController.text = pointDetails['point'] ?? '';
              _amountController.text = pointDetails['amount'] ?? '';
            });
            await logreports(
                "Sales Point Setting: Point-${point}_Amount-${amount}_Updated");
            successfullyUpdateMessage(context);
          } else {
            WarninngMessage();
          }
        } else {
          WarninngMessage();
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.yellow,
              content: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.error, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(
                    'Kindly fill in both Point and Amount',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
      WarninngMessage();
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
