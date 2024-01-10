import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madsports/functions.dart';
import 'dart:io';

import 'package:madsports/temp_classes.dart';

class EditChatRoomScreen extends StatefulWidget {
  final dynamic ChatRoom;
  final Function() onUpdate;
  EditChatRoomScreen({super.key, required this.ChatRoom, required this.onUpdate});

  @override
  State<EditChatRoomScreen> createState() => _EditChatRoomScreenState();
}



class _EditChatRoomScreenState extends State<EditChatRoomScreen> {
  final _picker = ImagePicker();
  late File? _imageFile;
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _linkController;
  late TextEditingController _authController;
  late TextEditingController _capacity;
  late TextEditingController _timeController;
  late dynamic list_res;
  late String storeid;
  late String name;
  late String number;
  late String category;
  bool showList = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ChatRoom['chat_name']);
    _linkController = TextEditingController(text: widget.ChatRoom['chat_link']);
    _authController = TextEditingController(text: widget.ChatRoom['partici_auth']);
    _timeController = TextEditingController(text: widget.ChatRoom['reserve_time']);
    _capacity = TextEditingController(text: widget.ChatRoom['capacity']);
    list_res = listofRestaurant(widget.ChatRoom['region']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가게 상세 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 검색 필드
            // 검색 결과 리스트
            showList? ListView.builder(
              shrinkWrap: true,
              itemCount: list_res.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(list_res[index]['place_name']),
                  subtitle: containedDB(list_res[index]['id']!) == false?
                  Text("address: ${list_res[index]['address']}, category: ${list_res[index]['category']}"):
                  Text("address: ${list_res[index]['address']}, category: ${list_res[index]['category']}, "),
                  onTap: () async {
                    // 선택된 가게 정보로 필드를 채움
                    storeid = list_res[index]['id']!;
                    name = list_res[index]['place_name'];
                    number = list_res[index]['number'];
                    category = list_res[index]['category'];
                    if(containedDB(storeid) == false){
                      addStore(storeid, name, number, list_res[index]['address'], null, "No Info", "No Info", -1, "No Info");
                    }
                    setState(() {
                      showList = false;
                    });
                  },
                );
              },
            ): Container(),
            if (_imageFile != null) Image.file(_imageFile!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('채팅방 사진 변경'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '채팅방 제목'),
            ),
            TextField(
              controller: _authController,
              decoration: InputDecoration(labelText: '참여 조건'),
            ),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(labelText: '채팅방 url'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: '예약 시간'),
            ),
            TextField(
              controller: _capacity,
              decoration: InputDecoration(labelText: '채팅방 인원'),
            ),
            // 수용 인원 설정 UI는 추가 구현 필요
            ElevatedButton(
              onPressed: () async {
                if(_imageFile == null){
                  Fluttertoast.showToast(
                      msg: "Please upload image!",
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      fontSize: 20,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_SHORT
                  );
                  return;
                }
                if(int.tryParse(_capacity.text) == null){
                  Fluttertoast.showToast(
                      msg: "Wrong format!",
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      fontSize: 20,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_SHORT
                  );
                  return;
                }
                await makeReservation(widget.ChatRoom['id'], storeid, _timeController.text);
                await updateChat(widget.ChatRoom['id'], _nameController.text, _imageFile?.path, widget.ChatRoom['region'], int.tryParse(_capacity.text)!, _authController.text, _linkController.text);
                // Store 객체를 업데이트합니다.

                // Callback 함수를 호출하여 상태를 업데이트합니다.
                widget.onUpdate();

                // 초기 화면으로 돌아갑니다.
                Navigator.pop(context);
              },
              child: Text('정보 저장'),
            ),
          ],
        ),
      ),
    );
  }
}