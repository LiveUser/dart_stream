// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:dart_stream/functions.dart';
import 'package:dart_stream/variables.dart';
import 'package:flutter/material.dart';
import 'package:quickie/quickie.dart';

AppBar appBar(){
  return AppBar(
    title: Image.asset(
      "images/logo.jpeg",
      width: 200,
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
  );
}
class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
  });
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.black,
        isDense: true,
        filled: true,
        contentPadding: EdgeInsets.all(20),
      ),
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}
class ServerMaster extends StatefulWidget {
  const ServerMaster({
    super.key,
    required this.index,
    required this.path,
    required this.port,
    required this.documentsPath,
  });
  final String path;
  final int index;
  final int port;
  final String documentsPath;

  @override
  State<ServerMaster> createState() => _ServerMasterState();
}

class _ServerMasterState extends State<ServerMaster> {
  int port = 0;
  StreamSubscription? serverStream;
  bool deleted = false;
  TextEditingController portInputField = TextEditingController();

  @override
  void initState(){
    super.initState();
    port = widget.port;
    portInputField.text = port.toString();
    portInputField.addListener((){
      //TODO: Parse and update port number
      try{
        port = int.parse(portInputField.text);
        updatePortNumber(
          documentsPath: widget.documentsPath, 
          index: widget.index, 
          port: port,
        );
      }catch(error){
        //Do nothing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return deleted ? const SizedBox() : Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: ()async{
              //Remove path
              bool? shouldDelete = await quickConfirm(
                context: context,
                title: Text(
                  "Are you sure you want to delete the reference to the path?",
                ),
                content: Text(
                  widget.path,
                ),
                backgroundColor: lightBlue,
                overlayColor: Colors.black,
                confirmButton: Container(
                  color: lightBlue,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Delete",
                  ),
                ),
              );
              if(shouldDelete){
                //Remove path
                removePath(
                  documentsPath: widget.documentsPath, 
                  index: widget.index,
                );
                //Reload widget
                setState(() {
                  serverStream?.cancel();
                  deleted = true;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(10),
              child: Text(
                widget.path,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          //Port input field
          SizedBox(
            width: 160,
            child: InputField(
              controller: portInputField,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          //Start stop server
          GestureDetector(
            onTap: ()async{
              //Start/Stop server
              try{
                if(serverStream == null){
                  serverStream = await runServer(
                    path: widget.path, 
                    port: port,
                  );
                }else{
                  serverStream?.cancel();
                  serverStream = null;
                }
                setState(() {
                  
                });
              }catch(error){
                //Display error message
                quickAlert(
                  context: context,
                  alertMessage: Text(
                    error.toString(),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Icon(
                serverStream == null ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}