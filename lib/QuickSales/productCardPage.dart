import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // For base64 decoding

class Product {
  String name;
  String price;
  String imagePath;
  double? cgstPercentage;
  double? sgstPercentage;
  int quantity;
  double totalPrice;
  bool isFavorite;
  String category;
  String stock;
  double stockValue;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.cgstPercentage,
    required this.sgstPercentage,
    required this.quantity,
    required this.totalPrice,
    required this.isFavorite,
    required this.category,
    required this.stock,
    required this.stockValue,
  });
}

class ProductCardPage extends StatefulWidget {
  const ProductCardPage({super.key});

  @override
  State<ProductCardPage> createState() => _ProductCardPageState();
}

class _ProductCardPageState extends State<ProductCardPage> {
  // Sample data for demonstration purposes
  List<Product> products = [
    // Add more products as needed
  ];
  List<Product> filteredProducts = [];
  List<Product> allProducts = [];
  bool isLoading = false;
  String errorMessage = '';
  Product? selectedProduct;
  List<String> categories = ['All', 'Favorites'];
  String selectedCategory = 'All';
  List<Product> selectedProducts = [];
  List<dynamic> allCategories = [];
  List<dynamic> mainCategories = [];
  String selectedProductName = '';
  String selectedProductPrice = '';
  String formattedTotalAmount = '';
  double? selectedProductCGST;
  double? selectedProductSGST;
  int totalItems = 0;
  double totalAmount = 0.0;
  double discountAmount = 0.0;
  double cgstPercentage = 0.0;
  double sgstPercentage = 0.0;
  double finalTaxable = 0.0;
  double cgst = 0.0;
  double sgst = 0.0;
  double finAmt = 0.0;
  double finalAmount = 0.0;
  int quantity = 0; // Initialize the quantity
  double totalPrice = 0.0; // Initialize the totalPrice
  String selectedPaymentType = 'Cash';
  TextEditingController gstMethodController = TextEditingController();
  List<String> paymentTypes = [];
  String orderType = 'DineIn';
  List<String> servantNames = [];
  String selectedServantName = 'Choose';
  bool _isHovered = false;
  String? gstType; // Initialize as nullable
  late var _pageController = PageController();
  String? serialNo;
  String cusid = '';
  double stockValue = 0.0;
  String stock = '';
  late ScrollController _scrollController;
  bool _showFloatingButton = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(
            filteredProducts[index].name,
            filteredProducts[index].price,
            filteredProducts[index].imagePath,
            filteredProducts[index].cgstPercentage,
            filteredProducts[index].sgstPercentage,
            filteredProducts[index].quantity,
            filteredProducts[index].totalPrice.toDouble(),
            filteredProducts[index].isFavorite,
            filteredProducts[index].category,
          );
        },
      ),
    );
  }

  List<Product> favoriteProducts = []; // List to store selected products

  void updateProductDetails(Product product) {
    // Calculate the new total price
    product.totalPrice =
        double.parse(product.price.replaceAll('₹', '')) * product.quantity;

    print('Total Price: ₹${product.totalPrice.toStringAsFixed(2)}');

    setState(() {
      int index = selectedProducts.indexWhere((p) => p.name == product.name);
      if (index != -1) {
        // Product is already in the list, update its details
        selectedProducts[index] = product;
        print('Updated product in selectedProducts list');
      } else {
        // Product is not in the list, add it
        selectedProducts.add(product);
        print('Added product to selectedProducts list');
      }
    });
  }

  Widget buildProductDetails(Product product) {
    // Create a TextEditingController for the quantity field
    TextEditingController _quantityController =
        TextEditingController(text: product.quantity.toString());

    // Calculate the initial total price
    double totalPrice =
        double.parse(product.price.replaceAll('₹', '')) * product.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 32,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  iconSize: 15,
                  color: Colors.red,
                  onPressed: () {
                    int quantity = int.parse(_quantityController.text);
                    if (quantity > 1) {
                      quantity--;
                      _quantityController.text = quantity.toString();
                      product.quantity = quantity;
                      updateProductDetails(product);
                    }
                  },
                ),
                Text(
                  '${product.quantity}',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 15,
                  color: Colors.green,
                  onPressed: () {
                    int quantity = int.parse(_quantityController.text);
                    quantity++;
                    _quantityController.text = quantity.toString();
                    product.quantity = quantity;
                    updateProductDetails(product);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total: ₹${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    String imagePath,
    double? cgstPercentage,
    double? sgstPercentage,
    int quantity,
    double totalPrice,
    bool isFavorite,
    String category,
    // double makingCost,
  ) {
    final base64Data = imagePath.substring(imagePath.indexOf(',') + 1);
    final imageBytes = base64.decode(base64Data);
    bool isDesktop = MediaQuery.of(context).size.width > 768;

    int productIndex =
        selectedProducts.indexWhere((product) => product.name == name);
    bool productIsSelected = productIndex != -1;
    bool isProductFavorite =
        favoriteProducts.any((product) => product.name == name);

    Color textColor = productIsSelected ? Colors.black : Colors.black;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double itemWidth = (screenWidth - 2 * 30.0 - 3 * 16.0) / 4;

    Future<void> _saveFavoriteProducts() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> favoriteProductStrings = favoriteProducts.map((product) {
        return jsonEncode({
          'name': product.name,
          'price': product.price,
          'imagePath': product.imagePath,
          'quantity': product.quantity,
          'cgstPercentage': product.cgstPercentage,
          'sgstPercentage': product.sgstPercentage,
          'category': product.category,
        });
      }).toList();
      await prefs.setStringList('favoriteProducts', favoriteProductStrings);
    }

    void addOrUpdateFavoriteProduct(
      String name,
      String price,
      String imagePath,
      double? cgstPercentage,
      double? sgstPercentage,
    ) {
      int existingIndex =
          favoriteProducts.indexWhere((product) => product.name == name);
      if (existingIndex != -1) {
        // Product already exists, update its details
        favoriteProducts[existingIndex] = Product(
            name: name,
            price: price,
            imagePath: imagePath,
            cgstPercentage: cgstPercentage ?? 0,
            sgstPercentage: sgstPercentage ?? 0,
            isFavorite: true,
            category: '',
            stock: '',
            stockValue: stockValue ?? 0,
            quantity: quantity,
            totalPrice: totalPrice
            // makingCost: makingCost, // Set as favorite
            );
      } else {
        // Product is not in the list, add it
        favoriteProducts.add(Product(
            name: name,
            price: price,
            imagePath: imagePath,
            cgstPercentage: cgstPercentage ?? 0,
            sgstPercentage: sgstPercentage ?? 0,
            isFavorite: true,
            category: '',
            stock: '',
            stockValue: stockValue ?? 0,
            quantity: quantity,
            totalPrice: totalPrice
            // makingCost: makingCost, // Set as favorite
            ));
      }
      _saveFavoriteProducts(); // Save the updated favorite products
    }

    void showMessage(String message, bool added) {
      Color dialogColor = added ? Colors.green : Colors.green;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // Close the dialog after 2 seconds
          });

          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Material(
                // color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: dialogColor,
                    // borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void addToCart(Product product) {
      setState(() {
        int productIndex =
            filteredProducts.indexWhere((p) => p.name == product.name);
        if (productIndex != -1) {
          // Product already exists in cart
          if (filteredProducts[productIndex].stock == 'No') {
            // Unlimited quantity for products with 'Stock: No'
            filteredProducts[productIndex].quantity++;
            // showMessage('Product added to cart', true);
          } else if (filteredProducts[productIndex].stock == 'Yes') {
            // Limited quantity based on 'Stock Value' for products with 'Stock: Yes'
            if (filteredProducts[productIndex].quantity <
                filteredProducts[productIndex].stockValue) {
              filteredProducts[productIndex].quantity++;
              // showMessage('Product added to cart', true);
            } else {
              // Show alert or message that stock is limited
              showDialog(
                barrierDismissible:
                    false, // Prevents closing the dialog when tapping outside
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Stock Limit Reached"),
                    content: Text(
                        " ${filteredProducts[productIndex].name} available quantity is ${filteredProducts[productIndex].stockValue}..Kindly add stock to proceed"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          // Show another dialog with more information
                          Navigator.of(context)
                              .pop(); // Close the initial dialog
                          showDialog(
                            barrierDismissible:
                                false, // Prevents closing the dialog when tapping outside
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return AlertDialog(
                                    title: Text("Confirm Addition"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "You are about to add beyond the stock limit. Are you sure you want to continue?"),
                                        SizedBox(height: 10),
                                        Container(
                                          width: isDesktop ? 90 : 110,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                color: Colors.red,
                                                iconSize: 14,
                                                onPressed: () {
                                                  setState(() {
                                                    if (product.quantity > 1) {
                                                      product.quantity--;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text(
                                                product.quantity.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                color: Colors.green,
                                                iconSize: 14,
                                                onPressed: () {
                                                  setState(() {
                                                    product.quantity++;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Confirm"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the confirmation dialog
                                          updateProductDetails(
                                              product); // Update product details in the parent widget
                                          showMessage(
                                              'Product added to cart', true);
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the confirmation dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          setState(() {
                            // Check if stock value is available and update quantity
                            if (filteredProducts[productIndex].stockValue !=
                                null) {
                              // Convert double to int, assuming stockValue is a double
                              filteredProducts[productIndex].quantity =
                                  filteredProducts[productIndex]
                                      .stockValue
                                      .toInt();

                              // Update the TextField controller to reflect the new quantity
                              // Note: Use a TextEditingController instance for persistent changes
                              TextEditingController _controller =
                                  TextEditingController();
                              _controller.text = filteredProducts[productIndex]
                                  .quantity
                                  .toString();

                              print(
                                  "Product: ${filteredProducts[productIndex].name}, Quantity set to: ${filteredProducts[productIndex].quantity}");
                            } else {}
                          });
                          updateProductDetails(product);
                          Navigator.of(context).pop();
                          showMessage(
                              "Current stock available: ${filteredProducts[productIndex].stockValue}",
                              false);
                          Timer(Duration(seconds: 2), () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        } else {
          // Product does not exist in cart, add it with quantity 1
          filteredProducts.add(Product(
              name: product.name,
              price: product.price,
              imagePath: product.imagePath,
              cgstPercentage: product.cgstPercentage,
              sgstPercentage: product.sgstPercentage,
              category: product.category,
              stock: product.stock,
              stockValue: product.stockValue,
              quantity: 1,
              totalPrice: product.totalPrice,
              isFavorite: true));
          showMessage('Product added to cart', true);
        }
      });
    }

    return GestureDetector(
      onTap: () {
        addToCart(Product(
            name: name,
            price: price,
            imagePath: imagePath,
            cgstPercentage: cgstPercentage!,
            sgstPercentage: sgstPercentage!,
            category: category,
            stock: stock,
            stockValue: stockValue,
            quantity: quantity,
            totalPrice: totalPrice,
            isFavorite: true));
        setState(() {
          int productIndex = selectedProducts.indexWhere((p) => p.name == name);
          if (productIndex != -1) {
            // Product is already in the list, increase the quantity
            selectedProducts[productIndex].quantity++;
          } else {
            // Product is not in the list, add it with initial quantity 1
            selectedProducts.add(Product(
                name: name,
                price: price,
                imagePath: imagePath,
                cgstPercentage: cgstPercentage,
                sgstPercentage: sgstPercentage,
                category: category,
                quantity: 1,
                stock: stock,
                stockValue: stockValue,
                totalPrice: totalPrice,
                isFavorite: true));
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(
            left: isDesktop ? 0 : 30.0,
            right: isDesktop ? 0 : 30.0,
            top: isDesktop ? 0 : 15.0),
        width: isDesktop
            ? itemWidth // Reduced width
            : MediaQuery.of(context).size.width * 0.8, // Reduced width
        height: isDesktop
            ? MediaQuery.of(context).size.height > 430
                ? 430
                : MediaQuery.of(context)
                    .size
                    .height // 30% of the screen height for desktop
            : MediaQuery.of(context).size.height * 0.8, // Adjusted height
        decoration: BoxDecoration(
          color: productIsSelected
              ? Color.fromARGB(255, 202, 199, 202)
              // ? Color.fromARGB(248, 184, 183, 185)
              // ? Color.fromARGB(244, 209, 207, 207)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: isDesktop
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isProductFavorite = !isProductFavorite;
                            if (isProductFavorite) {
                              addOrUpdateFavoriteProduct(
                                name,
                                price,
                                imagePath,
                                cgstPercentage,
                                sgstPercentage,
                              );
                              showMessage('Product added to favorites!', true);
                            } else {
                              favoriteProducts.removeWhere(
                                  (product) => product.name == name);
                              showMessage(
                                  'Product removed from favorites!', false);
                              _saveFavoriteProducts(); // Save the updated favorite products
                            }
                          });
                        },
                        icon: Icon(
                          isProductFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isProductFavorite ? Colors.red : Colors.black,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        45.0), // Half of the width/height to make it a circle
                    child: Image.memory(
                      imageBytes, // Ensure the correct path to your image
                      height: MediaQuery.of(context).size.height > 90
                          ? 90
                          : MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.height > 90
                          ? 90
                          : MediaQuery.of(context).size.height,
                      fit: BoxFit
                          .cover, // This ensures the image fits within the container
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Price: $price',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(45.0),
                          child: Image.memory(
                            imageBytes,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      width: 150,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Price: $price',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            if (!productIsSelected)
                              ElevatedButton(
                                onPressed: () {
                                  // Your onPressed logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            if (productIsSelected)
                              buildProductDetails(
                                  selectedProducts[productIndex])
                          ]),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isProductFavorite = !isProductFavorite;
                                if (isProductFavorite) {
                                  addOrUpdateFavoriteProduct(
                                    name,
                                    price,
                                    imagePath,
                                    cgstPercentage,
                                    sgstPercentage,
                                  );
                                  showMessage(
                                      'Product added to favorites!', true);
                                } else {
                                  favoriteProducts.removeWhere(
                                      (product) => product.name == name);
                                  showMessage(
                                      'Product removed from favorites!', false);
                                  _saveFavoriteProducts();
                                }
                              });
                            },
                            icon: Icon(
                              isProductFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isProductFavorite ? Colors.red : Colors.black,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      if (productIsSelected)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  for (var product in selectedProducts) {
                                    if (product.name == name) {
                                      selectedProducts.remove(product);
                                      break;
                                    }
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }


}
