import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'home.dart';
import 'login.dart';

class AddPostScreen extends StatefulWidget {
  final String? postId;

  AddPostScreen({this.postId});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _pickedImage;
  String? _selectedTitle;
  String? _description;

  // Store the previous post data
  String? _previousTitle;
  String? _previousDescription;
  String? _previousImage;

  @override
  void initState() {
    super.initState();
    // If postId is not null, fetch existing post data
    if (widget.postId != null) {
      print('PostId: ${widget.postId}');
      _fetchPostData(widget.postId!);
    } else {
      // Set initial values for a new post
      _selectedTitle = 'يوجد لدي عامل/عاملة منزلية للتنازل';
      _description = '';
      _titleController.text = _selectedTitle ?? '';
      _descriptionController.text = _description ?? '';
    }
  }

  void _fetchPostData(String postId) async {
    try {
      print('Fetching post data for postId: $postId');

      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        // Set the values from the existing post
        setState(() {
          _selectedTitle = postSnapshot['title'];
          _description = postSnapshot['description'];
          _pickedImage = postSnapshot['image'];

          // Store the previous post data
          _previousTitle = _selectedTitle;
          _previousDescription = _description;
          _previousImage = _pickedImage;

          // Set the values for text controllers
          _titleController.text = _selectedTitle ?? '';
          _descriptionController.text = _description ?? '';
        });

        print('Post data fetched successfully.');
        print('Selected Title: $_selectedTitle');
        print('Description: $_description');
        print('Picked Image: $_pickedImage');
        print('Previous Title: $_previousTitle');
        print('Previous Description: $_previousDescription');
        print('Previous Image: $_previousImage');
      } else {
        print('Post does not exist for postId: $postId');
      }
    } catch (error, stackTrace) {
      print('Error fetching post data: $error');
      print('Stack trace: $stackTrace');
    }
  }

  void _pickImage() {
    final html.InputElement input =
        html.FileUploadInputElement() as html.InputElement;
    input.click();

    input.onChange.listen((html.Event e) {
      final html.File file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        final List<int> bytes = reader.result as List<int>;
        final String base64Image = base64Encode(Uint8List.fromList(bytes));
        setState(() {
          _pickedImage = base64Image;
        });
      });

      reader.readAsArrayBuffer(file);
    });
  }

  void _submitPost() async {
    try {
      print('Submitting post...');

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );

        user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          print('User is still null after sign-in');
          return;
        }
      }

      // Check if required fields are not null
      if (_selectedTitle == null ||
          _description == null ||
          _pickedImage == null) {
        print('Title, description, or image is null');
        return;
      }

      String postId = user.uid;

      // Check if the user already has a post with their UID
      DocumentSnapshot userPost = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (userPost.exists) {
        // Ask for confirmation to edit the existing post
        bool confirmEdit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Edit Existing Post?'),
            content: Text(
                'Do you want to edit your existing post or create a new one?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Edit'),
              ),
            ],
          ),
        );

        if (confirmEdit == true) {
          // Update the existing post
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .update({
            'title': _selectedTitle,
            'description': _description,
            'image': _pickedImage,
          });
        } else {
          // Create a new post
          await FirebaseFirestore.instance.collection('posts').doc(postId).set({
            'title': _selectedTitle,
            'description': _description,
            'image': _pickedImage,
            'user_id': user.uid,
          });
        }
      } else {
        // Create a new post
        await FirebaseFirestore.instance.collection('posts').doc(postId).set({
          'title': _selectedTitle,
          'description': _description,
          'image': _pickedImage,
          'user_id': user.uid,
        });
      }

      // After submitting the post, navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error, stackTrace) {
      print('Error submitting post: $error');
      print('Stack trace: $stackTrace');
    }
  }

  void _deletePost() async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Post?'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        // Delete the post
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String postId = user.uid;

          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .delete();

          // After deleting the post, navigate to the home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (error, stackTrace) {
      print('Error deleting post: $error');
      print('Stack trace: $stackTrace');
    }
  }

  Future<DocumentSnapshot> _getPostData(String postId) async {
    return await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(MdiIcons.arrowLeft),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مشاركة',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Container(
                width: 500.0,
                child: DropdownButton<String>(
                  items: _previousTitle != null
                      ? [
                          DropdownMenuItem<String>(
                            value: _previousTitle,
                            child: Text(_previousTitle!),
                          )
                        ]
                      : [
                          DropdownMenuItem<String>(
                            value: 'يوجد لدي عامل/عاملة منزلية للتنازل',
                            child: Text('يوجد لدي عامل/عاملة منزلية للتنازل'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'ابحث عن عامل/عاملة منزلية للتنازل',
                            child: Text('ابحث عن عامل/عاملة منزلية للتنازل'),
                          ),
                        ],
                  onChanged: (String? selectedValue) {
                    setState(() {
                      _selectedTitle = selectedValue;
                      _titleController.text = selectedValue ?? '';
                    });
                  },
                  value: _selectedTitle,
                  hint: Text('اضغط للاختيار'),
                  icon: Icon(MdiIcons.arrowDownBox),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 500.0,
                child: TextField(
                  maxLines: 5,
                  controller: _descriptionController,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Description',
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(
                  'اضف صورة',
                  textDirection: TextDirection.rtl,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display picked image
              _pickedImage != null
                  ? Image.memory(
                      Uint8List.fromList(base64Decode(_pickedImage!)),
                      height: 100,
                    )
                  : _previousImage != null
                      ? Image.memory(
                          Uint8List.fromList(base64Decode(_previousImage!)),
                          height: 100,
                        )
                      : SizedBox.shrink(),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _deletePost,
                    child: Text(
                      ' حذف البوست',
                      textDirection: TextDirection.rtl,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _submitPost,
                    child: Text(
                      ' تحديث البوست',
                      textDirection: TextDirection.rtl,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _submitPost,
                    child: Text(
                      'ادراج البوست',
                      textDirection: TextDirection.rtl,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
