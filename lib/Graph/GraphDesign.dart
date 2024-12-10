import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesWeekChart extends StatefulWidget {
  const SalesWeekChart({Key? key}) : super(key: key);

  @override
  State<SalesWeekChart> createState() => _SalesWeekChartState();
}

class _SalesWeekChartState extends State<SalesWeekChart> {
  List<BarChartModel> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          data = jsonData['Last7DaysDetails'].map<BarChartModel>((entry) {
            final dt = entry['dt'].toString();
            final amount = double.parse(entry['amount_sum'].toString());
            return BarChartModel(
              dt: dt,
              amount: amount,
            );
          }).toList();
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Column(
        children: [
          Container(
            width: isMobile
                ? MediaQuery.of(context).size.width *
                    0.9 // 90% width for mobile
                : MediaQuery.of(context).size.width * 0.38,
            height: isMobile
                ? MediaQuery.of(context).size.height *
                    0.6 // Smaller height on mobile
                : MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blueGrey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text('Last 7 Days', style: HeadingStyle),
                  ),
                ),
                Expanded(
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      labelStyle: textStyle,
                      labelRotation: isMobile ? 35 : 45,
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: textStyle,
                      labelFormat: '₹{value}',
                    ),
                    series: <ChartSeries>[
                      BarSeries<BarChartModel, String>(
                        dataSource: data,
                        xValueMapper: (BarChartModel sales, _) => sales.dt,
                        yValueMapper: (BarChartModel sales, _) => sales.amount,
                        borderRadius: BorderRadius.circular(6),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.top,
                          textStyle: textStyle,
                        ),
                        gradient: LinearGradient(
                          colors: [Colors.lightBlueAccent, Colors.blue],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        color: Colors.blueAccent,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      textStyle: textStyle,
                      color: Colors.blueGrey[800],
                      borderColor: Colors.blueGrey[400],
                      borderWidth: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartModel {
  final String dt;
  final double amount;

  BarChartModel({
    required this.dt,
    required this.amount,
  });
}

class SalesMonthChart extends StatefulWidget {
  const SalesMonthChart({Key? key}) : super(key: key);

  @override
  State<SalesMonthChart> createState() => _SalesMonthChartState();
}

class _SalesMonthChartState extends State<SalesMonthChart> {
  List<Map<String, dynamic>> lastWeekPurchaseData = [];

  @override
  void initState() {
    super.initState();
    Salespiechart();
  }

  Future<void> Salespiechart() async {
    String? cusid = await SharedPrefs.getCusId();
    String apiUrl = '$IpAddress/SalesGraphCharts/$cusid';
    http.Response response = await http.get(Uri.parse(apiUrl));
    var jsonData = json.decode(response.body);

    if (jsonData['LastMonthDetails'] != null) {
      lastWeekPurchaseData =
          List<Map<String, dynamic>>.from(jsonData['LastMonthDetails']);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartData> lineChartDataList = lastWeekPurchaseData
        .where((data) => data['dt'] != null && data['amount_sum'] != null)
        .map((data) {
      final date = data['dt'] as String?;
      final amount = double.parse(data['amount_sum'] as String);
      return ChartData(date!, amount);
    }).toList();

    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.38,
        height: isMobile
            ? MediaQuery.of(context).size.height * 0.6
            : MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: maincolor,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text('Last Month Sales', style: HeadingStyle),
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                palette: <Color>[subcolor],
                primaryXAxis: CategoryAxis(
                  labelIntersectAction: isMobile
                      ? AxisLabelIntersectAction.none
                      : AxisLabelIntersectAction.rotate45,
                  labelPlacement: LabelPlacement.onTicks,
                  majorTickLines: MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '₹{value}',
                ),
                series: <ChartSeries>[
                  AreaSeries<ChartData, String>(
                    dataSource: lineChartDataList,
                    xValueMapper: (ChartData data, _) =>
                        data.date.substring(data.date.length - 2),
                    yValueMapper: (ChartData data, _) => data.amount,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    borderColor: Colors.blueAccent,
                    borderWidth: 2,
                    gradient: LinearGradient(
                      colors: <Color>[
                        subcolor.withOpacity(0.8),
                        subcolor.withOpacity(0.2)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: '₹point.y',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final double amount;

  ChartData(this.date, this.amount);
}

class SalesYearChart extends StatefulWidget {
  const SalesYearChart({Key? key}) : super(key: key);

  @override
  State<SalesYearChart> createState() => _SalesYearChartState();
}

class _SalesYearChartState extends State<SalesYearChart> {
  List<BarChartModel> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? cusid = await SharedPrefs.getCusId();
    final response =
        await http.get(Uri.parse('$IpAddress/SalesGraphCharts/$cusid'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (mounted) {
        setState(() {
          data = jsonData['PreviousYearMonthWiseDetails']
              .map<BarChartModel>((entry) {
            final dt = entry['dt'].toString();
            final amount = double.parse(entry['amount_sum'].toString());
            return BarChartModel(
              dt: dt,
              amount: amount,
            );
          }).toList();
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.43,
        height: isMobile
            ? MediaQuery.of(context).size.height * 0.6
            : MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: maincolor,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text('Last Year', style: HeadingStyle),
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: isMobile ? 0 : 45,
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '₹{value}',
                ),
                series: <ChartSeries>[
                  SplineSeries<BarChartModel, String>(
                    dataSource: data,
                    xValueMapper: (BarChartModel sales, _) => sales.dt,
                    yValueMapper: (BarChartModel sales, _) => sales.amount,
                    color: Colors.orange,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: Colors.orange[800],
                    ),
                    width: 3,
                    enableTooltip: true,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
