import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Results>> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter REST API Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter REST API Example'),
        ),
        body: new ListView.builder(
          itemCount: 100,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              margin: EdgeInsets.only(left: 8,top: 8,bottom: 8,right: 8),
              child: Padding(
                padding: EdgeInsets.only(left: 16,top: 16,bottom: 16,right: 16),
                child: Center(
                  child:  FutureBuilder<List<Results>>(
                    future: post,
                    builder: (context, dataList) {
                      if (dataList.hasData) {
                        return Text("Light :- " + dataList.data[index].value
                            .toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),); //Text(abc.data);
                      } else if (dataList.hasError) {
                        return Text("${dataList.error}");
                      }
                      // By default, it show a loading spinner.
                      return CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<List<Results>> fetchPost() async {
  final response = await http.get(
      'http://things.ubidots.com/api/v1.6/variables/5fa0dc170ff4c35632d891eb/values?token=paster-your-token-here');

  if (response.statusCode == 200) {
    // If the call to the server was successful (returns OK), parse the JSON.
    var res = json.decode(response.body);
    var notes = List<Results>();

    for (var resjson in res["results"]) {
      notes.add(Results.fromJson(resjson));
    }
    return notes;
  } else {
    // If that call was not successful (response was unexpected), it throw an error.
    throw Exception('Failed to load post');
  }
}

class Data {
  bool count;
  String next;
  Null previous;
  List<Results> results;

  Data({this.count, this.next, this.previous, this.results});

  Data.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  double timestamp;
  double value;
  Context context;
  double createdAt;

  Results({this.timestamp, this.value, this.context, this.createdAt});

  Results.fromJson(Map<String, dynamic> json) {
    //timestamp = json['timestamp'];
    value = json['value'];
    //context = json['context'];
    //createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['value'] = this.value;
    if (this.context != null) {
      data['context'] = this.context;
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Context {}

// class Context {
//
//
//   Context({});
//
// Context.fromJson(Map<String, dynamic> json) {
// }
//
// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   return data;
// }
// }
