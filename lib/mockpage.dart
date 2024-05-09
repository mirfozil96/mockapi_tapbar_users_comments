import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';

class MockPage extends StatefulWidget {
  const MockPage({super.key});

  @override
  State<MockPage> createState() => _MockScreenState();
}

class _MockScreenState extends State<MockPage>
    with SingleTickerProviderStateMixin {
  static const List<_Nav> _navItems = [
    _Nav(label: 'Users', iconData: Icons.groups, view: UsersPage()),
    _Nav(label: 'Comments', iconData: Icons.comment, view: CommentsPage()),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navItems.length, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
      ),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _navItems
                  .map(
                    (e) => NavigationRailDestination(
                      label: Text(e.label),
                      icon: Icon(e.iconData),
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isLargeScreen)
                  TabBar(
                    controller: _tabController,
                    tabs: _navItems
                        .map((e) => Tab(
                              icon: Icon(e.iconData),
                              text: e.label,
                            ))
                        .toList(),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _navItems.map((e) => e.view).toList(),
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

class _Nav {
  const _Nav({
    required this.label,
    required this.iconData,
    required this.view,
  });

  final String label;
  final IconData iconData;
  final Widget view;
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  List<Users> users = [];
  bool isLoading = false;
  bool isError = false;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

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
        await DioService.getData(context, ApiConstantsUser.getServer());
    if (result != null) {
      users = listUsersFromJson(result);
    }
    setState(() {});
  }

  Future<void> create() async {
    String name = nameController.text.trim().toString();
    String phone = phoneController.text.trim().toString();
    String username = usernameController.text.trim().toString();
// Create an instance of Address
    Address address = Address(
      street: "",
      suite: "",
      city: "",
      zipcode: "",
      geo: Geo(lat: "", lng: ""),
    );

    Company company = Company(
      name: "",
      catchPhrase: "",
      bs: "",
    );

    Users newProduct = Users(
      name: name,
      username: username,
      phone: phone,
      email: "nothing",
      address: address,
      website: 'pdp.uz',
      company: company,
    );

    String? result = await DioService.postData(
        context, ApiConstantsUser.getServer(), newProduct.toJson());
    await refresh(result, "Successfully created");
  }

  Future<void> update(Users product) async {
    String? result = await DioService.updateData(
        context, ApiConstantsUser.getServer(), product.id!, product.toJson());
    await refresh(result, "Successfully updated");
  }

  Future<void> delete(Users product) async {
    String? result = await DioService.deleteData(
        context, ApiConstantsUser.getServer(), product.id!, product.toJson());
    await refresh(result, "Deleted");
  }

  void clear() {
    nameController.clear();
    phoneController.clear();
    usernameController.clear();
  }

  Future<void> request() async {
    setState(() {
      isLoading = true;
    });
    String? result = await DioService.request(
        context, ApiConstantsUser.getServer(), RequestMethod.get);
    if (result != null) {
      users = listUsersFromJson(result);
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
                          itemCount: users.length,
                          itemBuilder: (_, index) {
                            Users product = users[index];
                            bool shouldShow = product.name!
                                .toLowerCase()
                                .contains(
                                    textEditingController.text.toLowerCase());
                            return shouldShow
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Slidable(
                                      endActionPane: ActionPane(
                                        extentRatio: 0.8,
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
                                          leading: CircleAvatar(
                                            child: Lottie.asset(
                                                "assets/lotties/user.json"),
                                          ),
                                          title: Text("name: ${product.name}"),
                                          subtitle: Text(
                                              "username: ${product.username}"),
                                          trailing:
                                              Text('phone:  ${product.phone}'),
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "TITLE",
                      ),
                    ),
                    TextField(
                      controller: phoneController,
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
                      controller: usernameController,
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

  void _editProduct(BuildContext context, Users product) {
    nameController.text = product.name!;
    usernameController.text = product.username!;
    phoneController.text = product.phone!.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "TITLE",
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  hintText: "COST",
                ),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: "CATEGORY",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                product.name = nameController.text;
                product.username = usernameController.text;
                product.phone = phoneController.text;

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

  void _deleteProduct(BuildContext context, Users product) async {
    await delete(product);
    await refresh("deleted");
  }
}

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => CommentsPageState();
}

class CommentsPageState extends State<CommentsPage> {
  List<Comments> comments = [];
  bool isLoading = false;
  bool isError = false;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController emailController = TextEditingController();

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
        await DioService.getData(context, ApiConstantsComments.getServer());
    if (result != null) {
      comments = listCommentsFromJson(result);
    }
    setState(() {});
  }

  Future<void> create() async {
    String name = nameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String body = bodyController.text.trim().toString();
    Comments newComment = Comments(
      name: name,
      email: email,
      body: body,
    );

    String? result = await DioService.postData(
        context, ApiConstantsComments.getServer(), newComment.toJson());
    await refresh(result, "Successfully created");
  }

  Future<void> update(Comments comment) async {
    String? result = await DioService.updateData(
        context, ApiConstantsUser.getServer(), comment.id!, comment.toJson());
    await refresh(result, "Successfully updated");
  }

  Future<void> delete(Comments product) async {
    String? result = await DioService.deleteData(
        context, ApiConstantsUser.getServer(), product.id!, product.toJson());
    await refresh(result, "Deleted");
  }

  void clear() {
    nameController.clear();
    bodyController.clear();
    emailController.clear();
  }

  Future<void> request() async {
    setState(() {
      isLoading = true;
    });
    String? result = await DioService.request(
        context, ApiConstantsUser.getServer(), RequestMethod.get);
    if (result != null) {
      comments = listCommentsFromJson(result);
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
                          itemCount: comments.length,
                          itemBuilder: (_, index) {
                            Comments product = comments[index];
                            bool shouldShow = product.name!
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
                                          leading: CircleAvatar(
                                            child: Lottie.asset(
                                                "assets/lotties/comment.json"),
                                          ),
                                          title: Text("name: ${product.name}"),
                                          subtitle:
                                              Text("email: ${product.email}"),
                                          // trailing:
                                          //     Text('body:  ${product.body}'),
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "name",
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: "email",
                      ),
                    ),
                    TextField(
                      controller: bodyController,
                      decoration: const InputDecoration(
                        hintText: "body",
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

  void _editProduct(BuildContext context, Comments product) {
    nameController.text = product.name!;
    emailController.text = product.email!;
    bodyController.text = product.body!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "name",
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "email",
                ),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  hintText: "body",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                product.name = nameController.text;
                product.email = emailController.text;
                product.body = bodyController.text;
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

  void _deleteProduct(BuildContext context, Comments product) async {
    await delete(product);
    await refresh("deleted");
  }
}

List<Comments> commentsFromJson(String str) =>
    List<Comments>.from(json.decode(str).map((x) => Comments.fromJson(x)));

String commentsToJson(List<Comments> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Comments> listCommentsFromJson(String result) =>
    List<Comments>.from(jsonDecode(result).map((e) => Comments.fromJson(e)));

class Comments {
  String? id;
  String? name;
  String? email;
  String? body;

  Comments({
    this.id,
    this.name,
    this.email,
    this.body,
  });

  factory Comments.fromJson(Map<String, dynamic> json) => Comments(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "body": body,
      };
}

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Users> listUsersFromJson(String result) =>
    List<Users>.from(jsonDecode(result).map((e) => Users.fromJson(e)));

class Users {
  String? id;
  String? name;
  String? username;
  String? email;
  Address? address;
  String? phone;
  String? website;
  Company? company;

  Users({
    this.id,
    this.name,
    this.username,
    this.email,
    this.address,
    this.phone,
    this.website,
    this.company,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        address: Address.fromJson(json["address"]),
        phone: json["phone"],
        website: json["website"],
        company: Company.fromJson(json["company"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "email": email,
        "address": address!.toJson(),
        "phone": phone,
        "website": website,
        "company": company!.toJson(),
      };
}

class Address {
  String? street;
  String? suite;
  String? city;
  String? zipcode;
  Geo? geo;

  Address({
    this.street,
    this.suite,
    this.city,
    this.zipcode,
    this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        street: json["street"],
        suite: json["suite"],
        city: json["city"],
        zipcode: json["zipcode"],
        geo: Geo.fromJson(json["geo"]),
      );

  Map<String, dynamic> toJson() => {
        "street": street,
        "suite": suite,
        "city": city,
        "zipcode": zipcode,
        "geo": geo!.toJson(),
      };
}

class Geo {
  String? lat;
  String? lng;

  Geo({
    this.lat,
    this.lng,
  });

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Company {
  String? name;
  String? catchPhrase;
  String? bs;

  Company({
    this.name,
    this.catchPhrase,
    this.bs,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        name: json["name"],
        catchPhrase: json["catchPhrase"],
        bs: json["bs"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "catchPhrase": catchPhrase,
        "bs": bs,
      };
}

@immutable
sealed class ApiConstantsUser {
  /// Properties
  static bool isUsers = true;
  static const duration = Duration(seconds: 30);
  static const contentType = "application/json";
  static bool validate(int? statusCode) => statusCode! <= 205;
  static const users = "https://65cc6b75dd519126b83e6c45.mockapi.io/users";
  static const comments =
      "https://65cc6b75dd519126b83e6c45.mockapi.io/comments";
  static String getServer() {
    if (isUsers) return users;
    return comments;
  }
}

@immutable
sealed class ApiConstantsComments {
  /// Properties
  static bool isUsers = false;
  static const duration = Duration(seconds: 30);
  static const contentType = "application/json";
  static bool validate(int? statusCode) => statusCode! <= 205;
  static const users = "https://65cc6b75dd519126b83e6c45.mockapi.io/users";
  static const comments =
      "https://65cc6b75dd519126b83e6c45.mockapi.io/comments";
  static String getServer() {
    if (isUsers) return users;
    return comments;
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
      connectTimeout: ApiConstantsUser.duration,
      receiveTimeout: ApiConstantsUser.duration,
      sendTimeout: ApiConstantsUser.duration,
      baseUrl: ApiConstantsUser.getServer(),
      contentType: ApiConstantsUser.contentType,
      validateStatus: ApiConstantsUser.validate,
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
