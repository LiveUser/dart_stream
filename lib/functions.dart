import 'dart:async';
import 'dart:typed_data';
import 'package:dart_stream/variables.dart';
import 'package:dart_stream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:objective_db/objective_db.dart';
import 'dart:io';
import 'package:mimalo/mimalo.dart';

void showQuickMessage(BuildContext context, String message){
  showDialog(
    context: context,
    builder: (context)=> Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: lightBlue,
            padding: EdgeInsets.all(10),
            child: Text(
              message,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  color: lightBlue,
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Understood",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
void storePath({
  required String documentsPath,
  required String pathToStore,
}){
  Entry entry = Entry(
    dbPath: "$documentsPath/rawware/dart_stream",
  );
  entry.select().insert(
    key: "paths", 
    value: [
      {
        "path": pathToStore,
        "port": 80,
      },
    ],
  );
}
void removePath({
  required String documentsPath,
  required int index,
}){
  Entry entry = Entry(
    dbPath: "$documentsPath/rawware/dart_stream",
  );
  List<DbObject> objects = entry.select().selectMultiple(key: "paths");
  entry.select().delete(key: "paths", uuid: objects[index].view()["uuid"]);
}
List<Widget> getStoredPaths({
  required String documentsPath,
}){
  List<Widget> widgets = [];
  Entry entry = Entry(
    dbPath: "$documentsPath/rawware/dart_stream",
  );
  List<DbObject> storedPaths = entry.select().selectMultiple(key: "paths");
  for(int i = 0; i < storedPaths.length; i++){
    DbObject object = storedPaths[i];
    Map<String,dynamic> data = object.view();
    widgets.add(ServerMaster(
      index: i, 
      path: data["path"],
      port: data["port"],
      documentsPath: documentsPath,
    ));
  }
  return widgets;
}
void updatePortNumber({
  required String documentsPath,
  required int index,
  required  int port,
}){
  Entry entry = Entry(
    dbPath: "$documentsPath/rawware/dart_stream",
  );
  List<DbObject> storedPaths = entry.select().selectMultiple(key: "paths");
  storedPaths[index].insert(
    key: "port", 
    value: port,
  );
}
Future<StreamSubscription> runServer({
  required String path,
  required int port,
})async{
  //Create server
  HttpServer httpServer = await HttpServer.bind(
    InternetAddress.anyIPv4, 
    port,
  );
  //Handle requests and return stream
  return httpServer.listen(
    (request)async{
      if(request.method == "GET"){
        File requestedFile = File("$path${request.uri.path}");
        String? mimeType;
        if(request.uri.path == "/" || request.uri.path.isEmpty){
          if((await File("$path/index.html").exists())){
            requestedFile = File("$path/index.html");
            mimeType = "text/html";
          }else if((await File("$path/index.htm").exists())){
            requestedFile = File("$path/index.htm");
            mimeType = "text/html";
          }else{
            throw "No entry file (index.html or index.htm)";
          }
        }else{
          mimeType = mimalo(filePathOrExtension: request.uri.path.toLowerCase());
        }
        if((await requestedFile.exists())){
          if(mimeType != null){
            Uint8List bytes = await requestedFile.readAsBytes();
            request.response.headers.contentType = ContentType.parse(mimeType);
            request.response.add(bytes);
          }else{
            request.response.headers.contentType = ContentType.text;
            request.response.write("${request.uri.path} invalid file type.");
          }
        }else{
          request.response.headers.contentType = ContentType.text;
          request.response.statusCode = 404;
          request.response.write("${request.uri.path} not found.");
        }
      }else{
        //TODO: Add support for more methods in the future. Like for example form submission through POST request.
        request.response.headers.contentType = ContentType.text;
        request.response.write("${request.method} is currently an unsupported method.");
      }
      await request.response.close();
    },
  );
}