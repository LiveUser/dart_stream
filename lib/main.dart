import 'dart:io';
import 'package:dart_stream/functions.dart';
import 'package:dart_stream/variables.dart';
import 'package:flutter/material.dart';
import 'widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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
  String path = "";

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
                  GestureDetector(
                    onTap: ()async{
                      String? filePickerResult = await FilePicker.platform.getDirectoryPath();
                      if(filePickerResult != null){
                        path = filePickerResult;
                      }
                      //Store path
                      if(path.isEmpty){
                        //Do nothing
                      }else{
                        storePath(
                          documentsPath: (snapshot.data as Directory).path, 
                          pathToStore: path,
                        );
                        //Clear field
                        path = "";
                        setState(() {
                          
                        });
                      }
                    },
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                            ),
                            child: Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              "Store Location",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
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