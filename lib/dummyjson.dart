import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';

import 'dart:convert';

class DummyJson extends StatefulWidget {
  const DummyJson({super.key});

  @override
  State<DummyJson> createState() => _DummyJsonState();
}

class _DummyJsonState extends State<DummyJson> {
  List<Products> products = [];
  bool isLoading = false;
  bool isError = false;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  Future<void> refresh(String? result,
      [String msg = "Successfully done"]) async {
    if (result != null) {
      Utils.fireSnackBar(msg, context);
    }
    await read();
    setState(() {});
  }

  Future<void> read() async {
    setState(() {
      isLoading = true;
    });
    String? result =
        await DioService.getData(context, ApiConstantsproduct.apiProducts);
    if (result != null) {
      products = listProductsFromJson(result);
    }
    setState(() {});
  }

  Future<void> create() async {
    String title = titleController.text.trim().toString();
    String price = costController.text.trim().toString();
    String category = categoryController.text.trim().toString();
    Products newProduct = Products(
      title: title,
      category: category,
      price: int.parse(price),
      description: "nothing",
      discountPercentage: 1,
      rating: 1,
      stock: 1,
      brand: "brand",
      thumbnail: "thumbnail",
      images: [],
    );

    String? result = await DioService.postData(
        context, ApiConstantsproduct.apiProducts, newProduct.toJson());
    await refresh(result, "Successfully created");
  }

  Future<void> update(Products product) async {
    String? result = await DioService.updateData(context,
        ApiConstantsproduct.apiProducts, product.id!, product.toJson());
    await refresh(result, "Successfully updated");
  }

  Future<void> delete(Products product) async {
    String? result = await DioService.deleteData(context,
        ApiConstantsproduct.apiProducts, product.id!, product.toJson());
    await refresh(result, "Deleted");
  }

  void clear() {
    titleController.clear();
    costController.clear();
    categoryController.clear();
  }

  Future<void> request() async {
    setState(() {
      isLoading = true;
    });
    String? result = await DioService.request(
        context, ApiConstantsproduct.apiProducts, RequestMethod.get);
    if (result != null) {
      products = listProductsFromJson(result);
    }
    setState(() {});
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
      ),
      body: isError
          ? Column(
              children: [
                const SizedBox(height: 100),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Lottie.asset("assets/lotties/error.json"),
                ),
                const Spacer(),
                MaterialButton(
                  color: Colors.red,
                  shape: const StadiumBorder(),
                  minWidth: 250,
                  height: 55,
                  onPressed: () async {
                    setState(() {
                      isError = false;
                    });
                    await request();
                  },
                  child: const Text("Retry"),
                ),
                const SizedBox(height: 100),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextField(
                    onChanged: (text) async {
                      setState(
                          () {}); // Har bitta harf kiritilganda setstate chaqirilsin
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: "Search",
                      prefixIcon: SizedBox(
                          width: 80,
                          height: 80,
                          child: Lottie.asset("assets/lotties/search.json")),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (_, index) {
                            Products product = products[index];
                            bool shouldShow = product.title!
                                .toLowerCase()
                                .contains(
                                    textEditingController.text.toLowerCase());
                            return shouldShow
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Slidable(
                                      endActionPane: ActionPane(
                                        extentRatio: 0.7,
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) {},
                                            autoClose: true,
                                            backgroundColor: Colors.yellow,
                                            foregroundColor: Colors.white,
                                            icon: Icons.visibility,
                                            label: 'view',
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          SlidableAction(
                                            onPressed: (_) {
                                              _editProduct(_, product);
                                            },
                                            autoClose: true,
                                            backgroundColor:
                                                const Color(0xFF21B7CA),
                                            foregroundColor: Colors.white,
                                            icon: Icons.edit,
                                            label: 'Edit',
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          SlidableAction(
                                            onPressed: (_) {
                                              _deleteProduct(_, product);
                                            },
                                            backgroundColor:
                                                const Color(0xFFFE4A49),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            autoClose: true,
                                            label: 'Delete',
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        color: Colors.blueGrey.withOpacity(0.3),
                                        elevation: 0,
                                        child: ListTile(
                                          leading: product.images != null
                                              ? Image.network(product
                                                      .images!.isNotEmpty
                                                  ? product.images!.first
                                                  : "https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg")
                                              : Image.network(
                                                  "https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg"),
                                          title:
                                              Text(product.title ?? "No title"),
                                          subtitle:
                                              Text("Price: ${product.price}\$"),
                                          trailing:
                                              Text(product.category ?? ""),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: "TITLE",
                      ),
                    ),
                    TextField(
                      controller: costController,
                      keyboardType:
                          TextInputType.number, // Faqat sonlarni qabul qiladi
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly // Faqat raqamlarni qabul qiladi
                      ],
                      decoration: const InputDecoration(
                        hintText: "COST",
                      ),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        hintText: "CATEGORY",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await create();
                      Navigator.pop(context);
                    },
                    child: const Text("Create"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
          clear();
        },
        child: const Text("+"),
      ),
    );
  }

  void _editProduct(BuildContext context, Products product) {
    titleController.text = product.title!;
    costController.text = product.price!.toString();
    categoryController.text = product.category!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "TITLE",
                ),
              ),
              TextField(
                controller: costController,
                keyboardType:
                    TextInputType.number, // Faqat sonlarni qabul qiladi
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly // Faqat raqamlarni qabul qiladi
                ],
                decoration: const InputDecoration(
                  hintText: "COST",
                ),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  hintText: "CATEGORY",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                product.title = titleController.text;
                product.price = int.parse(costController.text);
                product.category = categoryController.text;
                log(product.title.toString());
                log(product.price.toString());
                log(product.category.toString());
                await update(product);
                Navigator.pop(context);
              },
              child: const Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
    // clear();
  }

  void _deleteProduct(BuildContext context, Products product) async {
    await delete(product);
    await refresh("deleted");
  }
}

AllProductModel allProductModelFromJson(String str) =>
    AllProductModel.fromJson(json.decode(str));
String allProductModelToJson(AllProductModel data) =>
    json.encode(data.toJson());

class AllProductModel {
  AllProductModel({
    this.products,
    this.total,
    this.skip,
    this.limit,
  });

  AllProductModel.fromJson(dynamic json) {
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products?.add(Products.fromJson(v));
      });
    }
    total = json['total'];
    skip = json['skip'];
    limit = json['limit'];
  }
  List<Products>? products;
  int? total;
  int? skip;
  int? limit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (products != null) {
      map['products'] = products?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    map['skip'] = skip;
    map['limit'] = limit;
    return map;
  }
}

Products productsFromJson(String str) => Products.fromJson(json.decode(str));
List<Products> listProductsFromJson(String result) =>
    List<Products>.from(jsonDecode(result).map((e) => Products.fromJson(e)));
String productsToJson(Products data) => json.encode(data.toJson());

class Products {
  Products({
    this.id,
    this.title,
    this.description,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.brand,
    this.category,
    this.thumbnail,
    this.images,
  });

  Products.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    price = json['price'];
    discountPercentage = json['discountPercentage'];
    rating = json['rating'];
    stock = json['stock'];
    brand = json['brand'];
    category = json['category'];
    thumbnail = json['thumbnail'];
    images = json['images'] != null ? json['images'].cast<String>() : [];
  }
  String? id;
  String? title;
  String? description;
  int? price;
  num? discountPercentage;
  num? rating;
  int? stock;
  String? brand;
  String? category;
  String? thumbnail;
  List<String>? images;

  Map<String, dynamic> toJson() {
    final map = <String, Object?>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['price'] = price;
    map['discountPercentage'] = discountPercentage;
    map['rating'] = rating;
    map['stock'] = stock;
    map['brand'] = brand;
    map['category'] = category;
    map['thumbnail'] = thumbnail;
    map['images'] = images;
    return map;
  }
}

@immutable
sealed class ApiConstantsproduct {
  /// Properties
  static bool isTester = true;
  static const duration = Duration(seconds: 30);
  static const apiProducts = "/products";
  static const contentType = "application/json";
  static bool validate(int? statusCode) => statusCode! <= 205;
  static const serverDevelopment =
      "https://65d3570a522627d50108ac00.mockapi.io";
  static const serverDeployment = "https://65d3570a522627d50108ac00.mockapi.io";
  static String getServer() {
    if (isTester) return serverDevelopment;
    return serverDeployment;
  }
}

class Utils {
  // FireSnackBar
  static void fireSnackBar(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey.shade400.withOpacity(0.975),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 2500),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
    );
  }
}

enum ApiResult {
  success,
  error,
}

enum RequestMethod {
  get,
  post,
  put,
  delete,
}

@immutable
sealed class DioService {
  /// Options
  static BaseOptions _options = BaseOptions();

  static Dio _dio = Dio();

  static Dio init() {
    _options = BaseOptions(
      connectTimeout: ApiConstantsproduct.duration,
      receiveTimeout: ApiConstantsproduct.duration,
      sendTimeout: ApiConstantsproduct.duration,
      baseUrl: ApiConstantsproduct.getServer(),
      contentType: ApiConstantsproduct.contentType,
      validateStatus: ApiConstantsproduct.validate,
    );
    _dio = Dio(_options);
    return _dio;
  }

  /// method
  static Future<String?> getData(BuildContext context, String api,
      [Map<String, dynamic>? param]) async {
    try {
      Response response = await init().get(api, queryParameters: param);
      return jsonEncode(response.data);
    } on DioException catch (e) {
      log("DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}");
      Future.delayed(Duration.zero).then((value) {
        Utils.fireSnackBar(
            "DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}",
            context);
      });
      return null;
    }
  }

  static Future<String?> postData(
      BuildContext context, String api, Map<String, Object?> data,
      [Map<String, dynamic>? param]) async {
    try {
      Response response = await init().post(api, data: jsonEncode(data));
      return jsonEncode(response.data);
    } on DioException catch (e) {
      log("DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}");
      Future.delayed(Duration.zero).then((value) {
        Utils.fireSnackBar(
            "DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}",
            context);
      });
      return null;
    }
  }

  static Future<String?> updateData(
      BuildContext context, String api, String id, Map<String, Object?> data,
      [Map<String, dynamic>? param]) async {
    try {
      Response response = await init()
          .put("$api/$id", data: jsonEncode(data), queryParameters: param);
      return jsonEncode(response.data);
    } on DioException catch (e) {
      log("DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}");
      Future.delayed(Duration.zero).then((value) {
        Utils.fireSnackBar(
            "DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}",
            context);
      });
      return null;
    }
  }

  static Future<String?> deleteData(
      BuildContext context, String api, String id, Map<String, Object?> data,
      [Map<String, dynamic>? param]) async {
    try {
      Response response = await init().delete("$api/$id", data: data);
      return jsonEncode(response.data);
    } on DioException catch (e) {
      log("DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}");
      Future.delayed(Duration.zero).then((value) {
        Utils.fireSnackBar(
            "DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}",
            context);
      });
      return null;
    }
  }

  static Future<String?> request(
      BuildContext context, String api, RequestMethod method,
      [Map<String, dynamic>? param,
      Map<String, Object?> data = const {},
      String? id]) async {
    try {
      Response response = await init().request(id == null ? api : "$api/$id",
          data: jsonEncode(data),
          options: Options(
            method: method.name,
          ));
      return jsonEncode(response.data);
    } on DioException catch (e) {
      log("DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}");
      Future.delayed(Duration.zero).then((value) {
        Utils.fireSnackBar(
            "DioException: Error at ${e.requestOptions.uri}. Because of ${e.type.name}",
            context);
      });
      return null;
    }
  }
}
