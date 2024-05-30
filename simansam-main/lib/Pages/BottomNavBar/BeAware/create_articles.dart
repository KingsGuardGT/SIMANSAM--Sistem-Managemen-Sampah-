import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateArticle extends StatefulWidget {
  @override
  _CreateArticleState createState() => _CreateArticleState();
}

class _CreateArticleState extends State<CreateArticle> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  File _image;

  Future getImageFromGallery() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image, height: 200),
              ElevatedButton(
                onPressed: getImageFromGallery,
                child: Text('Select from gallery'),
              ),
              ElevatedButton(
                onPressed: getImageFromCamera,
                child: Text('Take a picture'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(labelText: 'Article Link'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter an article link';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an image')),
                      );
                      return;
                    }

                    String imageUrl = await uploadImageToFirebase(_image);

                    await FirebaseFirestore.instance
                        .collection('Articles')
                        .add({
                      'articleTitle': _titleController.text,
                      'articleDescription': _descriptionController.text,
                      'articleImage': imageUrl,
                      'articleLink': _linkController.text,
                      'articlePostedDate': DateTime.now(),
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> uploadImageToFirebase(File image) async {
    Reference reference = FirebaseStorage.instance.ref().child('articles/${DateTime.now()}.jpg');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}