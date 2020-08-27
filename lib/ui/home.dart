import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:thedefinition/ui/secret.dart';
import 'package:thedefinition/util/common_colors.dart';
import 'package:thedefinition/util/custom_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mykey = key;
  String _url = "https://owlbot.info/api/v4/dictionary/";

  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;
  Timer _timer;

  //RegExp _numeric = RegExp(r'^-?[0-9]+$');//to check error type

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response = await get(_url + _controller.text.trim(),
        headers: {"Authorization": "Token " + _mykey});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Defination finder",
          size: 22,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(5)),
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_timer?.isActive ?? false) _timer.cancel();
                      _timer = Timer(const Duration(microseconds: 1000), () {
                        _search();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search word",
                      focusColor: green,
                      fillColor: green,
                      hintStyle: TextStyle(color: blue, fontSize: 20),
                      contentPadding: const EdgeInsets.only(left: 25),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: white,
                ),
                onPressed: () {
                  _search();
                },
              ),
            ],
          ),
        ),
        //Text("Defination finder"),
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              // || _numeric.hasMatch(snapshot.data)==true
              return Center(
                child: CustomText(
                  text: "Enter word to search",
                  size: 26,
                  weight: FontWeight.bold,
                ),
              );
            } else if (snapshot.data == "waiting") {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data["definitions"].length,
                itemBuilder: (_, index) {
                  return ListBody(
                    children: [
                      Container(
                        color: red[200],
                        child: ListTile(
                          leading: snapshot.data["definitions"][index]
                                      ["image_url"] ==
                                  null
                              ? null
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot
                                      .data["definitions"][index]["image_url"]),
                                ),
                          title: CustomText(
                            text: _controller.text.trim() +
                                "(" +
                                snapshot.data["definitions"][index]["type"] +
                                ")",
                            color: black,
                            size: 22,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(
                          text: snapshot.data["definitions"][index]
                              ["definition"],
                          color: black,
                          size: 18,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
      //bottomNavigationBar: BottomNavigationBar(items: null),
    );
  }
}
