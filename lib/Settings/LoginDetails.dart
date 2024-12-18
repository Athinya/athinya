import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ProductRestaurant/Database/IpAddress.dart';
import 'package:ProductRestaurant/Modules/Responsive.dart';
import 'package:ProductRestaurant/Modules/Style.dart';
import 'package:ProductRestaurant/Modules/constaints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginDetailsPage extends StatefulWidget {
  const LoginDetailsPage({Key? key}) : super(key: key);

  @override
  State<LoginDetailsPage> createState() => _LoginDetailsPageState();
}

class RoleDetails {
  final int id;
  final String cusid;
  final String role;

  RoleDetails({
    required this.id,
    required this.cusid,
    required this.role,
  });

  factory RoleDetails.fromJson(Map<String, dynamic> json) {
    return RoleDetails(
      id: json['id'] ?? 0,
      cusid: json['cusid'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class _LoginDetailsPageState extends State<LoginDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _isUserNewPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isOldPasswordVisible = false;
  String trialStartDate = '';
  String trialEndDate = '';
  String installDate = '';
  String closeDate = '';

  String? selectedRole;

  String? selectedValue;
  // List<Map<String, dynamic>> tableData = [];
  double totalAmount = 0.0;

  String message = '';

  late Future<List<Map<String, dynamic>>> futureRoleDetails;

  List<Map<String, dynamic>> PasswordtableData = [];
  double PasswordtotalAmount = 0.0;
  List<String> UpdateNewUserRoleList = [];

  Future<void> PasswordfetchData() async {
    try {
      // Retrieve the user ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');

      // Make an HTTP GET request to fetch password data
      final response =
          await http.get(Uri.parse('$IpAddress/Settings_Password/$cusid/'));

      if (response.statusCode == 200) {
        // Decode the response body
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() async {
            // Convert the fetched data to a list of maps
            PasswordtableData =
                List<Map<String, dynamic>>.from(data['results']);

            // Debugging: Print the fetched data
            print('Fetched Password Data: $PasswordtableData');

            // Retrieve the selected role from the TextEditingController
            String selectedRole = AddNewUserRoleController.text.trim();
            print('Selected Role from Controller: "$selectedRole"');

            if (selectedRole.isNotEmpty) {
              // Filter emails and IDs based on the selected role
              List<Map<String, dynamic>> filteredData = PasswordtableData.where(
                  (item) =>
                      item['role'] != null &&
                      item['role'].toString().trim() == selectedRole).toList();

              // Print the filtered data
              print('Filtered Data: $filteredData');

              // Extract emails and IDs from the filtered data
              UpdateNewUserRoleList =
                  filteredData.map((item) => item['email'].toString()).toList();

              List<int> filteredIds =
                  filteredData.map((item) => item['id'] as int).toList();

              // Debugging: Print the filtered emails and IDs
              print('Filtered Emails: $UpdateNewUserRoleList');
              print('Filtered IDs: $filteredIds');

              // Call the updateNewUserData function for each filtered ID
              for (int id in filteredIds) {
                await updateNewUserData(id);
              }
            } else {
              // Handle case when no role is selected
              UpdateNewUserRoleList = [];
              print('Selected role is empty');
            }
          });
        } else {
          setState(() {
            UpdateNewUserRoleList = [];
          });
          print('No data available');
        }
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      print('Failed to fetch passwords: $e');
    }
  }

  // //crt code
  // Future<void> PasswordfetchData() async {
  //   try {
  //     // Retrieve the user ID from SharedPreferences
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? cusid = prefs.getString('cusid');

  //     // Make an HTTP GET request to fetch password data
  //     final response = await http
  //         .get(Uri.parse('http://192.168.10.123:82/Settings_Password/$cusid/'));

  //     if (response.statusCode == 200) {
  //       // Decode the response body
  //       final data = json.decode(response.body);

  //       if (data['results'] != null && data['results'].isNotEmpty) {
  //         setState(() {
  //           // Convert the fetched data to a list of maps
  //           PasswordtableData =
  //               List<Map<String, dynamic>>.from(data['results']);

  //           // Debugging: Print the fetched data
  //           print('Fetched Password Data: $PasswordtableData');

  //           // Retrieve the selected role from the TextEditingController
  //           String selectedRole = AddNewUserRoleController.text.trim();
  //           print('Selected Role from Controller: "$selectedRole"');

  //           if (selectedRole.isNotEmpty) {
  //             // Filter emails based on the selected role
  //             UpdateNewUserRoleList = PasswordtableData.where((item) =>
  //                     item['role'] != null &&
  //                     item['role'].toString().trim() == selectedRole)
  //                 .map((item) => item['email'].toString())
  //                 .toList();

  //             // Debugging: Print the filtered emails
  //             print('Filtered Emails: $UpdateNewUserRoleList');
  //           } else {
  //             // Handle case when no role is selected
  //             UpdateNewUserRoleList = [];
  //             print('Selected role is empty');
  //           }
  //         });
  //       } else {
  //         setState(() {
  //           UpdateNewUserRoleList = [];
  //         });
  //         print('No data available');
  //       }
  //     } else {
  //       throw Exception('Failed to load details');
  //     }
  //   } catch (e) {
  //     print('Failed to fetch passwords: $e');
  //   }
  // }

  String searchText = '';

  // Future<List<Map<String, dynamic>>> getFilteredData() async {
  //   if (searchText.isEmpty) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? cusid = prefs.getString('cusid');
  //     return tableData.where((data) => data['cusid'] == cusid).toList();
  //   }

  //   // Filter the data based on the search text
  //   List<Map<String, dynamic>> filteredData = tableData
  //       .where((data) => (data['prodname'] ?? '')
  //           .toLowerCase()
  //           .contains(searchText.toLowerCase()))
  //       .toList();

  //   return filteredData;
  // }

  String PasswordsearchText = '';

  List<Map<String, dynamic>> PasswordetFilteredData() {
    if (PasswordsearchText.isEmpty) {
      // If the search text is empty, return the original data
      return PasswordtableData;
    }

    // Filter the data based on the search text
    List<Map<String, dynamic>> filteredData = PasswordtableData.where((data) =>
        (data['prodname'] ?? '')
            .toLowerCase()
            .contains(searchText.toLowerCase())).toList();

    return filteredData;
  }

  @override
  void initState() {
    super.initState();
    PasswordfetchData();
    fetchCusIdAndUserData();
    futureRoleDetails = fetchDetails();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> fetchCusIdAndUserData() async {
    try {
      // Fetch cusid from Shared Preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');

      // Print the fetched cusid for verification
      print('Fetched cusid: $cusid');

      if (cusid != null && cusid.isNotEmpty) {
        // Fetch user data using the cusid
        await fetchUserDetails(cusid);
        print('Fetchedddddddddddddddddddddddddddddd cusid: $cusid');
      } else {
        print('cusid is null or empty');
      }
    } catch (e) {
      print('Error fetching cusid: $e');
    }
  }

// Define the userId variable
  late int userId;
  Future<void> fetchUserDetails(String cusid) async {
    String baseUrl = '$IpAddress/TrialUserRegistration/?cusid=$cusid';
    List<dynamic> allResults = [];

    Future<void> fetchPage(String url) async {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          // Add the results of the current page
          allResults.addAll(results);

          // Check if there's a next page and fetch it
          if (data['next'] != null) {
            await fetchPage(data['next']);
          } else {
            // Once all pages are fetched, process the results
            processResults(cusid, allResults);
          }
        } else {
          print('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    // Start fetching from the base URL
    await fetchPage(baseUrl);
  }

  void processResults(String cusid, List<dynamic> results) {
    // Filter the results based on cusid
    final filteredResults =
        results.where((user) => user['cusid'] == cusid).toList();

    if (filteredResults.isEmpty) {
      print('User with cusid $cusid not found.');
    } else {
      final user =
          filteredResults[0]; // Assuming you want the first matched user
      setState(() {
        emailController.text = user['email'];
        newpasswordController.text = user['password'];
        userId = user['id']; // Adjust based on the actual key for ID
        print('User ID: $userId'); // Print or use the ID as needed
      });

      // Store the ID for future use if necessary
    }
  }

//test
  Future<List<Map<String, dynamic>>> fetchDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');

      if (cusid == null) {
        throw Exception('Customer ID not found in shared preferences.');
      }

      final response =
          await http.get(Uri.parse('$IpAddress/Settings_Role/$cusid/'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data['results'] is List) {
          final results = List<Map<String, dynamic>>.from(data['results']);
          results.removeWhere(
              (item) => item['role']?.toString().toLowerCase() == 'admin');

          setState(() {
            AddNewUserRoleList = List<String>.from(
                results.map((item) => item['role'].toString()));
          });

          return results;
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception(
            'Failed to load details, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching details: $e');
      throw e;
    }
  }

// mine
  // Future<List<Map<String, dynamic>>> fetchDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? cusid = prefs.getString('cusid');
  //   final response =
  //       await http.get(Uri.parse('$IpAddress/Settings_Role/$cusid/'));
  //   print('res: ${response.body}');

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data['results'] != null && data['results'].isNotEmpty) {
  //       final results = List<Map<String, dynamic>>.from(data['results']);
  //       results.removeWhere(
  //           (item) => item['role'].toString().toLowerCase() == 'admin');

  //       setState(() {
  //         AddNewUserRoleList =
  //             List<String>.from(results.map((item) => item['role'].toString()));
  //       });
  //       return results;
  //     } else {
  //       throw Exception('No data available');
  //     }
  //   } else {
  //     throw Exception('Failed to load details');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = MediaQuery.of(context).size.width > 1200;
    double screenWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Container(
                  color: subcolor,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                    ), // Adjust the value as needed
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 4.0,
                          color:
                              Colors.yellow, // Set the custom indicator color
                        ),
                      ),
                      tabs: <Widget>[
                        Tab(
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_outlined,
                                color: Colors.white,
                                size: isDesktop ? 20 : 17,
                              ),
                              SizedBox(
                                  height:
                                      4), // Adjust space between icon and text
                              Text(
                                "Admin Update",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 15 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.beach_access_sharp,
                                color: Colors.white,
                                size: isDesktop ? 20 : 17,
                              ),
                              SizedBox(
                                  height:
                                      4), // Adjust space between icon and text
                              Text(
                                "Add New Role",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 15 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.brightness_5_sharp,
                                color: Colors.white,
                                size: isDesktop ? 20 : 17,
                              ),
                              SizedBox(
                                  height:
                                      4), // Adjust space between icon and text
                              Text(
                                "Add New User",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 15 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.brightness_5_sharp,
                                color: Colors.white,
                                size: isDesktop ? 20 : 17,
                              ),
                              SizedBox(
                                  height:
                                      4), // Adjust space between icon and text
                              Text(
                                "User Update",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 15 : 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      adminupdate(),
                      Center(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Divider(
                                  color: Colors.grey[300],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _buildAddButton(),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  color: Colors.white,
                                  height: Responsive.isDesktop(context)
                                      ? screenHeight * 0.7
                                      : 400,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Roles',
                                            style: commonLabelTextStyle,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  ' * Click to delete the Role',
                                                  style: textStyle),
                                            ),
                                          ],
                                        ),
                                        FutureBuilder<
                                            List<Map<String, dynamic>>>(
                                          future: futureRoleDetails,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final roleData = snapshot.data!;
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        Responsive.isDesktop(
                                                                context)
                                                            ? 8
                                                            : 3,
                                                    childAspectRatio: 1.0,
                                                    crossAxisSpacing:
                                                        6.0, // Reduced spacing
                                                    mainAxisSpacing:
                                                        6.0, // Reduced spacing
                                                  ),
                                                  itemCount: roleData.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final data =
                                                        roleData[index];
                                                    var role =
                                                        data['role'].toString();

                                                    return GestureDetector(
                                                      onTap: () {
                                                        _showDeleteConfirmationDialog(
                                                            data, role);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.grey[
                                                              100], // Lighter background for elegance
                                                          border: Border.all(
                                                              color: Colors
                                                                      .grey[
                                                                  300]!), // Subtle border
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 30,
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      'assets/imgs/teamwork.png'),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              role,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  commonLabelTextStyle, // Smaller font size
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              return Center(
                                                  child: Text(
                                                      'No data available'));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Divider(
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 10),
                              if (!Responsive.isDesktop(context))
                                _newUsertopMobileDesign(),
                              if (Responsive.isDesktop(context))
                                _newUsertopWebDesign(),
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 35 : 25.0),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: PasswordtableData.length,
                                        itemBuilder: (context, index) {
                                          var data = PasswordtableData[index];
                                          var role = data['role'].toString();
                                          var username =
                                              data['email'].toString();
                                          var login =
                                              data['datetime'].toString();
                                          var Productid = data['id'].toString();

                                          return Card(
                                            elevation: 2,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.blueGrey,
                                                    child: Text(
                                                      role[0].toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          username,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Role: $role',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          'Last Login: $login',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      _showDeleteNewUserConfirmationDialog(
                                                        data,
                                                        role,
                                                        username,
                                                        data['password']
                                                            .toString(),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      userupdate()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> AddNewUserRoleList = [];

  TextEditingController AddNewUserRoleController = TextEditingController();

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  FocusNode AddNewUserFocus = FocusNode();
  final FocusNode _addNewUserFocus = FocusNode();

  int? _selectedIndex;
  bool _filterEnabled = true;
  int? _hoveredIndex;

  Widget AddNewUserRoleDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                AddNewUserRoleList.indexOf(AddNewUserRoleController.text);
            if (currentIndex < AddNewUserRoleList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                AddNewUserRoleController.text =
                    AddNewUserRoleList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                AddNewUserRoleList.indexOf(AddNewUserRoleController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                AddNewUserRoleController.text =
                    AddNewUserRoleList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: AddNewUserFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              AddNewUserRoleController.text = suggestion!;
              _filterEnabled = false;
              _fieldFocusChange(context, AddNewUserFocus, usernameFocusNode);
            });
          },
          controller: AddNewUserRoleController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'Role',
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black,
            ),
            labelStyle: commonLabelTextStyle.copyWith(
              color:
                  const Color.fromARGB(255, 116, 116, 116), // Color for label
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
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return AddNewUserRoleList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return AddNewUserRoleList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = AddNewUserRoleList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          AddNewUserRoleList.indexOf(
                                  AddNewUserRoleController.text) ==
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
            AddNewUserRoleController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(usernameFocusNode);

            // Debugging: Check the controller text
            print('Controller Updated: ${AddNewUserRoleController.text}');

            // Fetch data with the updated role
            PasswordfetchData();
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

  FocusNode UpdateNewFocus = FocusNode();
  final FocusNode _updateNewUserFocus = FocusNode();

//perfect code for dropdown
//do only filtered
  Widget UpdateNewUserRoleDropdownCode() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex = UpdateNewUserRoleList.indexOf(
                UpdateDropdownNewUserNameController.text);
            if (currentIndex < AddNewUserRoleList.length - 1) {
              setState(() {
                _selectedIndex = currentIndex + 1;
                UpdateDropdownNewUserNameController.text =
                    UpdateNewUserRoleList[currentIndex + 1];
                _filterEnabled = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex = UpdateNewUserRoleList.indexOf(
                UpdateDropdownNewUserNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndex = currentIndex - 1;
                UpdateDropdownNewUserNameController.text =
                    UpdateNewUserRoleList[currentIndex - 1];
                _filterEnabled = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: UpdateNewFocus,
          onSubmitted: (String? suggestion) async {
            setState(() {
              selectedValue = suggestion;
              UpdateDropdownNewUserNameController.text = suggestion!;
              _filterEnabled = false;
              _fieldFocusChange(context, UpdateNewFocus, _updateNewUserFocus);
              PasswordfetchData();
            });
          },
          controller: UpdateDropdownNewUserNameController,
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black,
            ),
            prefixIcon: Icon(
              Icons.mail,
              size: 18,
              color: Colors.black,
            ),
            labelText: 'Email',
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
              _filterEnabled = true;
              selectedValue = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabled && pattern.isNotEmpty) {
            return UpdateNewUserRoleList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return UpdateNewUserRoleList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = UpdateNewUserRoleList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndex = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndex = null;
            }),
            child: Container(
              color: _selectedIndex == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndex == null &&
                          UpdateNewUserRoleList.indexOf(
                                  UpdateDropdownNewUserNameController.text) ==
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
            UpdateDropdownNewUserNameController.text = suggestion;
            selectedValue = suggestion;
            _filterEnabled = false;
            FocusScope.of(context).requestFocus(_updateNewUserFocus);
            PasswordfetchData();
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

  TextEditingController NewUserPasswordUpdateController =
      TextEditingController();

  List<String> NewUserUpdateRoleList = [];
  String? UserNameselectedValue;
  TextEditingController UpdateDropdownNewUserNameController =
      TextEditingController();
  Widget userupdate() {
    return Center(
      child: Responsive.isDesktop(context)
          ? Container(
              padding: EdgeInsets.all(30),
              child: _buildUserForm(),
            )
          : SingleChildScrollView(
              child: _buildUserForm(),
            ),
    );
  }

  Widget _buildUserForm() {
    return Container(
      width: Responsive.isDesktop(context) ? 400 : 300,
      height: Responsive.isDesktop(context) ? 450 : 450,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image integrated into the form
          Center(
            child: Image.asset(
              'assets/imgs/newuser.png',
              height: 80,
              width: 80,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Update User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),

          // Role Selection
          _buildDropdownField(AddNewUserRoleDropdown()),
          SizedBox(height: 30),

          // Email Field
          _buildDropdownField(UpdateNewUserRoleDropdownCode()),
          SizedBox(height: 30),

          // Password Field

          _buildPasswordField(NewUserPasswordUpdateController),
          SizedBox(height: 25),

          // Update Button
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: subcolor,
                minimumSize: Size(120, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                PasswordfetchData();
              },
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper function to create dropdown fields with heading
  Widget _buildDropdownField(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

// Helper function for password field
  Widget _buildPasswordField(TextEditingController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !_isUserNewPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.password,
            size: 18,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isUserNewPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isUserNewPasswordVisible = !_isUserNewPasswordVisible;
              });
            },
          ),
          labelText: 'Password',
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
      ),
    );
  }

  Future<void> updateNewUserData(int id) async {
    String selectedRole = AddNewUserRoleController.text;

    String selectedemail = UpdateDropdownNewUserNameController.text;

    String newpassword = NewUserPasswordUpdateController.text;

    try {
      // Define the URL for the PUT request
      final url = '$IpAddress/Settings_Passwordalldatas/$id/';

      // Define the data to be updated (example data, replace with actual data)
      final data = {
        'password': newpassword,
      };

      // Make an HTTP PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully for ID: $id');
        await logreports(
            "Login Details: User Update_Role-${selectedRole}_Email-${selectedemail}_Password-${newpassword}_Updated");
        successChangePassword();
        AddNewUserRoleController.clear();
        UpdateDropdownNewUserNameController.clear();
        NewUserPasswordUpdateController.clear();
      } else {
        print('Failed to update data for ID: $id');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating data for ID: $id');
      print('Error: $e');
    }
  }

  TextEditingController userNameController = TextEditingController();
  TextEditingController UserNewPaswordController = TextEditingController();
  FocusNode usernameFocusNode = FocusNode();
  FocusNode newpwdFocusNode = FocusNode();
  FocusNode savenewuserFocusNode = FocusNode();

  Widget _newUsertopWebDesign() {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: Responsive.isDesktop(context)
                        ? 200
                        : MediaQuery.of(context).size.width * 0.25,
                    child: Container(
                      height: 40,
                      width: 180,
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
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(child: AddNewUserRoleDropdown()),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _tabController?.animateTo(1);
                    },
                    child: Container(
                      width: 20,
                      height: 40,
                      color: subcolor,
                      child: Center(
                        child: Text(
                          "+",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Responsive.isDesktop(context)
                    ? 200
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  height: 40,
                  width: 180,
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
                    controller: userNameController,
                    focusNode: usernameFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        size: 18,
                        color: Colors.black,
                      ),
                      labelText: 'Email',
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
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(newpwdFocusNode);
                    },
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
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Responsive.isDesktop(context)
                    ? 200
                    : MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  height: 40,
                  width: 180,
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
                    controller: UserNewPaswordController,
                    focusNode: newpwdFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.password,
                        size: 18,
                        color: Colors.black,
                      ),
                      labelText: 'Password',
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
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(savenewuserFocusNode);
                    },
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
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            focusNode: savenewuserFocusNode,
            onPressed: () {
              savedNewUser();
              PasswordfetchData();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              backgroundColor: subcolor,
              minimumSize: Size(45.0, 31.0), // Set width and height
            ),
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void savedNewUser() async {
    bool emailAlreadyExists = false;
    String emailInput = userNameController.text.toLowerCase();

    for (var row in PasswordtableData) {
      String emailInTable = row['email'].toLowerCase();
      if (emailInTable == emailInput) {
        emailAlreadyExists = true;
        break;
      }
    }
    if (AddNewUserRoleController.text.isEmpty) {
      WarninngMessage(context);
      print('Please fill in all fields');
    }
    if (emailAlreadyExists) {
      AlreadyExistWarninngMessage();
      print('Email already exists');
    } else {
      String email = userNameController.text;
      String password = UserNewPaswordController.text;
      String formattedDate =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');
      Map<String, dynamic> postData = {
        "cusid": cusid,
        "role": selectedValue,
        "email": email,
        "password": password,
        "datetime": formattedDate,
      };

      String jsonData = jsonEncode(postData);

      String apiUrl = '$IpAddress/Settings_Passwordalldatas/';
      try {
        http.Response response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Data posted successfully');
          await logreports(
              "Login Details: Add New User_Role-${selectedValue}_Email-${email}_Password-${password}_Inserted");
          userNameController.clear();
          UserNewPaswordController.clear();
          selectedValue = "";
          AddNewUserRoleController.clear();

          successRoleAdded();
          await PasswordfetchData();
        } else {
          print(
              'Failed to post data: ${response.statusCode}, ${response.body}');
        }
      } catch (e) {
        print('Failed to post data: $e');
      }
    }
  }

  Widget _newUsertopMobileDesign() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: Responsive.isDesktop(context)
                            ? 180
                            : MediaQuery.of(context).size.width * 0.40,
                        child: Container(
                          height: 40,
                          width: 180,
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
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(child: AddNewUserRoleDropdown()),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          _tabController
                              ?.animateTo(1); // Navigate to the AdminUpdate tab
                        },
                        child: Container(
                          width: 20,
                          height: 40,
                          color: subcolor,
                          child: Center(
                            child: Text(
                              "+",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Responsive.isDesktop(context)
                        ? 200
                        : MediaQuery.of(context).size.width * 0.45,
                    child: Container(
                      height: 40,
                      width: 180,
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
                          focusNode: usernameFocusNode,
                          controller: userNameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail,
                              size: 18,
                              color: Colors.black,
                            ),
                            labelText: 'Email',
                            labelStyle: commonLabelTextStyle.copyWith(
                              color: const Color.fromARGB(
                                  255, 116, 116, 116), // Color for label
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
                          onSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(newpwdFocusNode);
                          },
                          style: textStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Responsive.isDesktop(context)
                        ? 200
                        : MediaQuery.of(context).size.width * 0.45,
                    child: Container(
                      height: 40,
                      width: 180,
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
                          controller: UserNewPaswordController,
                          focusNode: newpwdFocusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.password,
                              size: 18,
                              color: Colors.black,
                            ),
                            labelText: 'New Password',
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
                          onSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(SaveButtonFocusNode);
                          },
                          style: textStyle),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: ElevatedButton(
                  onPressed: () {
                    savedNewUser();
                    PasswordfetchData();
                  },
                  focusNode: SaveButtonFocusNode,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: Size(45.0, 31.0), // Set width and height
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextEditingController oldpasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController newpasswordController = TextEditingController();
  TextEditingController idController = TextEditingController();

  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode oldPasswordFocusNode = FocusNode();
  FocusNode emailControllerFocusNode = FocusNode();
  FocusNode updateButtonFocusNode = FocusNode();

  void _updateFocus() {
    if (newPasswordFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(updateButtonFocusNode);
    } else if (emailControllerFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(newPasswordFocusNode);
    }
  }

  Future<void> updateData() async {
    if (userId == null) {
      print('User ID is not set. Cannot update data.');
      return;
    }

    String newpassword = newpasswordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cusid = prefs.getString('cusid');
    String? email = prefs.getString('email');

    // Prepare data to be sent in the body
    Map<String, dynamic> putData = {
      "cusid": cusid,
      "password": newpassword,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);
    print('Request data: $jsonData'); // Print the data being sent

    // Make PUT request to the API with dynamic ID
    String apiUrl =
        '$IpAddress/TrialUserRegistration/$userId/'; // Use the dynamic ID
    try {
      print('Sending PUT request to $apiUrl'); // Print the URL being hit
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      print(
          'Response status: ${response.statusCode}'); // Print response status code
      print('Response body: ${response.body}'); // Print response body

      if (response.statusCode == 200) {
        // Data updated successfully
        print('Data updated successfully');

        await logreports(
            "Login Details: Admin Update_Email-${email}_Password-${newpassword}_Updated");
        // Handle successful password update (you might want to show a message to the user)
        successChangePassword();
      } else {
        // Data updating failed
        print(
            'Failed to update data: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  Future<void> passwordUpdate() async {
    if (userId == null) {
      print('User ID is not set. Fetching user details from next page.');
      await fetchUserIdFromPagination();
      return;
    }

    String newpassword = newpasswordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cusid = prefs.getString('cusid');

    // Prepare data to be sent in the body
    Map<String, dynamic> putData = {
      "cusid": cusid,
      "password": newpassword,
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);
    print('Request data: $jsonData'); // Print the data being sent

    // Make PUT request to the API with dynamic ID
    String apiUrl =
        '$IpAddress/Settings_Passwordalldatas/$userId/'; // Use the dynamic ID
    try {
      print('Sending PUT request to $apiUrl'); // Print the URL being hit
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      print(
          'Response status: ${response.statusCode}'); // Print response status code
      print('Response body: ${response.body}'); // Print response body

      if (response.statusCode == 200) {
        // Data updated successfully
        print('Password updated successfully');
        successChangePassword();
      } else if (response.statusCode == 404) {
        print(
            'Resource not found. Attempting to fetch user ID from next page.');
        await fetchUserIdFromPagination();
      } else {
        print(
            'Failed to update password: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Failed to update password: $e');
    }
  }

  Future<void> fetchUserIdFromPagination() async {
    int pageNumber = 1; // Start with the first page
    bool morePages = true;

    while (morePages) {
      String pageUrl = '$IpAddress/Settings_Passwordalldatas/?page=$pageNumber';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cusid = prefs.getString('cusid');

      try {
        print(
            'Fetching user details from page $pageNumber: $pageUrl'); // Print the URL being hit
        http.Response response = await http.get(Uri.parse(pageUrl));

        // Check response status
        if (response.statusCode == 200) {
          print('Fetched user details successfully from page $pageNumber');
          var data = jsonDecode(response.body);

          // Example: Extracting the user ID from the fetched data
          List<dynamic> results = data['results'];
          if (results.isNotEmpty) {
            var user = results.firstWhere(
                (element) => element['cusid'] == cusid,
                orElse: () => null);
            print('Retrieved cus ID: $cusid');

            if (user != null) {
              userId = user['id']; // Set the user ID from the fetched data
              print('Retrieved user ID: $userId');

              // Optionally, save the userId to shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('userId', userId.toString());

              // Retry password update with the correct user ID
              await passwordUpdate();
              return; // Exit the function after successful update
            }
          } else {
            print('No data found on page $pageNumber.');
          }

          // Check if there's a next page
          if (data['next'] != null) {
            pageNumber++; // Move to the next page
          } else {
            morePages = false; // No more pages available
          }
        } else {
          print(
              'Failed to fetch user details from page $pageNumber: ${response.statusCode}, ${response.body}');
          morePages = false; // Stop if there's an error fetching data
        }
      } catch (e) {
        print('Failed to fetch user details from page $pageNumber: $e');
        morePages = false; // Stop if there's an exception
      }
    }

    print('User not found in any page.');
  }

  // Future<void> passwordUpdate() async {
  //   if (userId == null) {
  //     print('User ID is not set. Cannot update data.');
  //     return;
  //   }

  //   String newpassword = newpasswordController.text;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? cusid = prefs.getString('cusid');

  //   // Prepare data to be sent in the body
  //   Map<String, dynamic> putData = {
  //     "cusid": cusid,
  //     "password": newpassword,
  //   };

  //   // Convert data to JSON format
  //   String jsonData = jsonEncode(putData);
  //   print('Request data: $jsonData'); // Print the data being sent

  //   // Make PUT request to the API with dynamic ID
  //   String apiUrl =
  //       '$IpAddress/Settings_Passwordalldatas/$userId/'; // Use the dynamic ID
  //   try {
  //     print('Sending PUT request to $apiUrl'); // Print the URL being hit
  //     http.Response response = await http.put(
  //       Uri.parse(apiUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonData,
  //     );
  //     print('user id : $userId');
  //     // Check response status
  //     print(
  //         'Response status: ${response.statusCode}'); // Print response status code
  //     print('Response body: ${response.body}'); // Print response body

  //     if (response.statusCode == 200) {
  //       // Data updated successfully
  //       print('passowrd updated successfully');

  //       // Handle successful password update (you might want to show a message to the user)
  //       successChangePassword();
  //     } else {
  //       // Data updating failed
  //       print(
  //           'Failed to update passowrd: ${response.statusCode}, ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Failed to update passowrd: $e');
  //   }
  // }
  Widget adminupdate() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (Responsive.isDesktop(context))
            Row(
              children: [
                SizedBox(width: 50),
                _buildUpdateForm(), // Call the form builder directly
              ],
            ),
          if (Responsive.isMobile(context))
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUpdateForm(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpdateForm() {
    return Container(
      width: 350, // Set a suitable width for the form
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.all(20), // Added padding for a spacious feel
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image inside the form
          Image.asset(
            'assets/imgs/passwordnew.png',
            height: 150,
            width: 150,
          ),
          SizedBox(height: 20), // Space between image and title
          Text('Admin Update', style: commonLabelTextStyle),
          SizedBox(height: 20),
          _buildTextField('Email id', emailController, true),
          SizedBox(height: 15),
          _buildPassword('New Password', newpasswordController),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: subcolor,
              minimumSize: Size(120.0, 40.0), // Set a consistent button size
            ),
            onPressed: () {
              _showUpdateDialog(message);
            },
            child: Text('Update',
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool readOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: commonLabelTextStyle),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
          ),
          style: textStyle,
        ),
      ],
    );
  }

  Widget _buildPassword(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: commonLabelTextStyle),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: controller,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              ),
              style: textStyle,
            ),
            IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showUpdateDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.restart_alt, size: 18),
                  SizedBox(
                    width: 4,
                  ),
                  Text('Confirm Reset',
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
                'Are you sure you want to Reset you password?',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                updateData();
                passwordUpdate();
                Navigator.of(context).pop(true);
                successChangePassword();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                backgroundColor: subcolor,
                minimumSize: Size(30.0, 28.0), // Set width and height
              ),
              child: Text('Reset',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  int adminId = 0;

  Future<void> updateAdminUserData(int adminId) async {
    String newpassword = newpasswordController.text;
    int id = adminId;
    // Get the current date and time
    String formattedDate =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    // Prepare data to be posted
    Map<String, dynamic> putData = {
      "role": "ADMIN",
      "username": "ADMIN",
      "pwd": newpassword,
      "login": formattedDate,
      "status": "Custom"
    };

    // Convert data to JSON format
    String jsonData = jsonEncode(putData);

    // Make POST request to the API
    String apiUrl = '$IpAddress/Setting_LoginPassword/$id';
    try {
      http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check response status
      if (response.statusCode == 200) {
        // Data posted successfully
        print('Data posted successfully');

        successChangePassword();
        oldpasswordController.clear();
        newpasswordController.clear();
      } else {
        // Data posting failed
        print('Failed to post data: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Failed to post data: $e');
    }
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () {
          _showFormDialog(context);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          backgroundColor: subcolor,
          minimumSize: Size(45.0, 31.0), // Set width and height
        ),
        child: Text(
          'Add +',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  TextEditingController RoleController = TextEditingController();
  final FocusNode RoleFocusNode = FocusNode();
  final FocusNode SaveButtonFocusNode = FocusNode();

  void _showFormDialog(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1200;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 80,
            // height: 100,
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 17,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Container(
                  width: 240,
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black, // Customize label color
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 24,
                            width: 135,
                            child: TextField(
                              controller: RoleController,
                              focusNode: RoleFocusNode,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 7.0,
                                ),
                              ),
                              onSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(SaveButtonFocusNode);
                              },
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              savesaveRole();
                            },
                            focusNode: SaveButtonFocusNode,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              backgroundColor: subcolor,
                              minimumSize: Size(
                                  isDesktop ? 45.0 : 25.0,
                                  isDesktop
                                      ? 31.0
                                      : 20.0), // Set width and height
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> savesaveRole() async {
    String userInput = RoleController.text
        .trim()
        .toLowerCase(); // Convert user input to lowercase and trim

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cusid = prefs.getString('cusid');

    if (cusid == null) {
      print('Customer ID is not available');
      return; // Exit if no customer ID is found
    }

    // Retrieve existing roles from the API
    String apiUrl = '$IpAddress/Settings_Rolealldatas/';
    try {
      http.Response getResponse = await http.get(Uri.parse(apiUrl));
      if (getResponse.statusCode == 200) {
        // Parse the response body
        Map<String, dynamic> responseBody = jsonDecode(getResponse.body);

        // Assuming 'results' key contains the list of roles
        List<dynamic> existingRoles = responseBody['results'];

        bool roleAlreadyExists = existingRoles.any((role) {
          return role['role'].toLowerCase() == userInput &&
              role['cusid'] == cusid;
        });

        if (roleAlreadyExists) {
          RoleController.clear();
          AlertWarning(context); // Show warning message
          print('Role already exists for this customer');
        } else {
          // Prepare data to be posted
          Map<String, dynamic> postData = {
            "role": RoleController.text,
            "cusid": cusid, // Include the cus_id field
          };

          // Convert data to JSON format
          String jsonData = jsonEncode(postData);

          // Make POST request to the API
          try {
            http.Response postResponse = await http.post(
              Uri.parse(apiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonData,
            );

            // Check response status
            if (postResponse.statusCode == 200 ||
                postResponse.statusCode == 201) {
              // Data posted successfully
              print('Data posted successfully');
              await logreports(
                  "Login Details: Add New Role_Role-${RoleController.text}_Inserted");

              RoleController.clear();
              Navigator.of(context).pop();
              successRoleAdded(); // Show success message
              setState(() {
                futureRoleDetails = fetchDetails();
              });
            } else {
              // Data posting failed
              print(
                  'Failed to post data: ${postResponse.statusCode}, ${postResponse.body}');
            }
          } catch (e) {
            print('Failed to post data: $e');
          }
        }
      } else {
        print(
            'Failed to fetch existing roles: ${getResponse.statusCode}, ${getResponse.body}');
      }
    } catch (e) {
      print('Error fetching existing roles: $e');
    }
  }

  Future<bool?> _showDeleteNewUserConfirmationDialog(Map<String, dynamic> data,
      String role, String username, String passowrd) async {
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
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
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
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await logreports(
                    "Login Details: Add New User_Role-${role}_Email-${username}_Password-${passowrd}_Deleted");

                deleteNewUserdata(data['id']);

                Navigator.of(context).pop(true);
                successfullyDeleteMessage();
                PasswordfetchData();
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

  Future<bool?> _showDeleteConfirmationDialog(
      Map<String, dynamic> data, String role) async {
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
                  Text('Confirm Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await logreports(
                    "Login Details: Add New Role_Role-${role}_Deleted");
                deleteData(data['id']);
                Navigator.of(context).pop();
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

  void deleteNewUserdata(int id) async {
    String apiUrl = '$IpAddress/Settings_Passwordalldatas/$id';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check response status
    if (response.statusCode == 204) {
      // Data updated successfully
      print('Data updated successfully');

      await PasswordfetchData();
    } else {
      // Data updating failed
      print('Failed to update data: ${response.statusCode}, ${response.body}');
    }
  }

  void deleteData(int id) async {
    String apiUrl = '$IpAddress/Settings_Rolealldatas/$id';
    http.Response response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 204) {
      // 204 No Content indicates successful deletion
      print('Data deleted successfully');

      setState(() {
        futureRoleDetails = fetchDetails();
      });

      successfullyDeleteMessage();
    } else {
      // Data deleting failed
      print('Failed to delete data: ${response.statusCode}, ${response.body}');
      // Optionally, show an error message
    }
  }

  Widget buildCard({required String heading, required Widget child}) {
    return Container(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: Responsive.isDesktop(context) ? 14 : 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildNewUserRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? 150
                  : MediaQuery.of(context).size.width * 0.25,
              child: Container(
                height: 25,
                width: 100,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Container(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Option 1',
                          child: Text('Option 1'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Option 2',
                          child: Text('Option 2'),
                        ),
                        // Add more DropdownMenuItem as needed
                      ],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      underline: Container(
                        // Add an underline with white color
                        height: 1,
                        color: const Color.fromARGB(0, 255, 255, 255),
                      ),
                      isExpanded:
                          true, // Make the dropdown button fill the width of the container
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.black), // Add a down arrow icon
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: subcolor,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                child: Text(
                  "+",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewUserTextField(String label) {
    return Container(
      width: Responsive.isDesktop(context)
          ? 190
          : MediaQuery.of(context).size.width * 0.3,
      child: Container(
        height: 27,
        width: 100,
        color: Colors.grey[200],
        child: TextField(
          // controller: retailAmount,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0),
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
    );
  }

  Widget _buildNewPasswordTextField(String label) {
    return Container(
      width: Responsive.isDesktop(context)
          ? 190
          : MediaQuery.of(context).size.width * 0.3,
      child: Container(
        height: 27,
        width: 100,
        color: Colors.grey[200],
        child: TextField(
          // controller: retailAmount,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.0),
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
    );
  }

  void PasswordNotMatch() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Old Password Is Not Matches',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
  }

  void allfeildfilled() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'Kindly fill the all feild',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
  }

  void successRoleAdded() {
    showDialog(
      barrierDismissible: false,
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
                    'Successfully Added..!!',
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

  void successChangePassword() {
    showDialog(
      barrierDismissible: false,
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
                    'Successfully Changed Password..!!',
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

  void AlertWarning(BuildContext context) {
    // Close the current dialog before showing the warning dialog
    Navigator.of(context, rootNavigator: true).pop();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, size: 18),
                  SizedBox(
                    width: 6,
                  ),
                  Text('Alert Warning',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The role is already exists',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void AlreadyExistWarninngMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.yellow,
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.warning, color: maincolor),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              Text(
                'This User name is already exists',
                style: TextStyle(fontSize: 12, color: maincolor),
              ),
            ],
          ),
        );
      },
    );
  }

  void successfullyDeleteMessage() {
    showDialog(
      barrierDismissible: false,
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

    // Close the dialog automatically after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}
