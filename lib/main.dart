import 'dart:io';
import 'package:dart_stream/functions.dart';
import 'package:dart_stream/variables.dart';
import 'package:flutter/material.dart';
import 'widgets.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Stream',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController path = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: lightBlue,
      body: FutureBuilder(
        future: getApplicationDocumentsDirectory(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  //Add folder path
                  Row(
                    children: [
                      //Clear field text
                      GestureDetector(
                        onTap: (){
                          path.clear();
                          setState(() {

                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      //Input Field
                      Expanded(
                        child: InputField(
                          controller: path,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          //Store path
                          if(path.text.isEmpty){
                            showQuickMessage(context, "Path field must not be empty.");
                          }else{
                            storePath(
                              documentsPath: (snapshot.data as Directory).path, 
                              pathToStore: path.text,
                            );
                            //Clear field
                            path.clear();
                            setState(() {
                              
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                          ),
                          child: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      "Stored Paths",
                    ),
                  ),
                  //Display folders and options
                  SingleChildScrollView(
                    child: Column(
                      children: getStoredPaths(
                        documentsPath: (snapshot.data as Directory).path,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }else{
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            );
          }
        },
      ),
    );
  }
}