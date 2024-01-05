import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/register.dart';
import 'package:web_ksa/screens/terms.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add _post.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFilter;
  late PageController _pageController;
  List<QueryDocumentSnapshot>? _filteredPosts;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    //fetchCommentsForPost();
    fetchCommentTextField();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
    );
  }

  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPostScreen()),
    );
  }

  void _applyFilter() {
    setState(() {
      // Refresh the UI to apply the filter
    });
  }

  void _navigateToPreviousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextPage() {
    if (_pageController.page != null &&
        _pageController.page! < _pageController.position.maxScrollExtent) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _launchDialer(String phoneNumber) async {
    if (await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      print('Could not dial $phoneNumber');
    }
  }

  void _sharePost(String title, String? url) async {
    if (url != null) {
      await FlutterShare.share(
        title: 'Check out this post: $title',
        text: 'Visit the website: $url',
        linkUrl: url,
      );
    } else {
      print('Post URL is null or not available');
    }
  }

  String? text;
  getComments() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc('')
        .collection('comments')
        .doc('')
        .get()
        .then((value) {});
  }

  Future<List<DocumentSnapshot>> getCommentsForPost(
      String postId, String userId) async {
    try {
      // Reference to the "posts" collection
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Reference to the specific post document
      DocumentReference postReference = postsCollection.doc(postId);

      // Reference to the "comments" subcollection within the post
      CollectionReference commentsCollection =
          postReference.collection('comments');

      // Query to filter comments based on the user_id field
      QuerySnapshot querySnapshot =
          await commentsCollection.where('user_id', isEqualTo: userId).get();

      // Return the list of comment documents
      return querySnapshot.docs;
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  String commentTextField = '';

  Future<void> fetchCommentTextField() async {
    print('USERRRRRRRRR${user!.uid}');
    try {
      // Reference to the "posts" collection
      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Query to filter posts based on the user_id field
      QuerySnapshot postQuerySnapshot =
          await postsCollection.where('user_id', isEqualTo: user!.uid).get();

      // Check if a matching post is found
      if (postQuerySnapshot.docs.isNotEmpty) {
        // Reference to the specific post document
        DocumentReference postReference =
            postQuerySnapshot.docs.first.reference;

        // Reference to the "comments" subcollection within the post
        CollectionReference commentsCollection =
            postReference.collection('comments');

        // Query to filter comments based on the user_id field

        QuerySnapshot commentQuerySnapshot = await commentsCollection
            .where('user_id', isEqualTo: user!.uid)
            .get();

        // Check if a matching comment is found
        if (commentQuerySnapshot.docs.isNotEmpty) {
          // Reference to the specific comment document
          DocumentReference commentReference =
              commentQuerySnapshot.docs.first.reference;

          // Get the comment document
          DocumentSnapshot commentSnapshot = await commentReference.get();

          // Check if the comment exists and belongs to the specified user
          if (commentSnapshot.exists) {
            // Set the text field of the comment
            setState(() {
              commentTextField = commentSnapshot['text'];
              print('Comment Text: ${commentTextField}');
            });
          } else {
            // Comment not found
            print('Comment not found.');
          }
        } else {
          // No matching comments found
          print('No matching comments found.');
        }
      } else {
        // No matching posts found
        print('No matching posts found.');
      }
    } catch (e) {
      print('Error fetching comment text field: $e');
    }
  }

  List<DocumentSnapshot>? comments;
  void fetchCommentsForPost() async {
    String postId = '0EXlIDMySySJfKYNruTu'; // Replace with the actual post ID
    String userId =
        'DrBR4v5mo2QZpj2UjdENzYvP4s82'; // Replace with the actual user ID

    comments = await getCommentsForPost(postId, userId);

    // Process the comments for the post
    for (DocumentSnapshot comment in comments!) {
      print('Comment ID: ${comment!.id}, Data: ${comment!.data()}');
      // Add your processing logic here
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  void _addComment(String postId, String text) async {
    if (user == null) {
      // Handle the case where the user is not authenticated
      // You might want to redirect them to the login screen
      print('User not authenticated. Please log in.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'user_id': user!.uid,
        'text': text,
      });

      // CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');
      // QuerySnapshot querySnapshot = await postsCollection.where('user_id', isEqualTo: user.uid).get();

      // Refresh the UI to show the updated comments
      setState(() {
        // Your existing code to refresh the UI
      });
    } catch (error) {
      print('Error adding comment: $error');
    }
  }

  // Widget _buildCommentsList(List<dynamic>? comments) {
  //   print('Comments list: $comments');
  //
  //   if (comments == null || comments.isEmpty) {
  //     return Center(
  //       child: Text('No comments yet.'),
  //     );
  //   }
  //   print('Individual comments:');
  //   for (var comment in comments) {
  //     print(comment);
  //   }
  //
  //   return ListView.builder(
  //     itemCount: comments.length,
  //     itemBuilder: (context, index) {
  //       // Adjust this line based on your Firestore structure
  //       Map<String, dynamic> commentData = comments[index];
  //       return _buildCommentCard(commentData);
  //     },
  //   );
  // }

  Widget _buildCommentCard(Map<String, dynamic> comment1) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(commentTextField), // Use 'text' for the comment text
        //subtitle: Text('User ID: ${comments!['user_id']}'),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    TextEditingController _commentController = TextEditingController();

    // Handle null comments by providing an empty list
    List<dynamic> comments = post['comments'] ?? [];

    return Card(
      margin: EdgeInsets.all(8.0.r),
      child: Padding(
        padding: EdgeInsets.all(8.0.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    post['title'] ?? '',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    post['description'] ?? '',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(MdiIcons.share),
                        onPressed: () {
                          // Add your share logic here
                        },
                      ),
                      IconButton(
                        icon: Icon(MdiIcons.comment),
                        onPressed: () {
                          // Add your comment logic here
                          print('Commenting on post ${post['title']}');
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: 840.w,
                    height: 280.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(commentTextField),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 840.w,
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write your comment...',
                        suffixIcon: IconButton(
                          icon: Icon(MdiIcons.send),
                          onPressed: () {
                            // Check if postId is not null before adding the comment
                            if (postId != null) {
                              _addComment(postId, _commentController.text);
                              _commentController.clear();
                            } else {
                              print('Post ID is null. Cannot add comment.');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (post['image'] != null)
              Image.memory(
                base64Decode(post['image']),
                width: 600.w,
                height: 700.h,
                fit: BoxFit.fill,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(List<QueryDocumentSnapshot> posts) {
    _filteredPosts = _selectedFilter == null
        ? posts
        : posts
            .where((QueryDocumentSnapshot post) =>
                (post.data() as Map<String, dynamic>).containsKey('title') &&
                post.get('title') == _selectedFilter)
            .toList();

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: _filteredPosts!.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts![index].data() as Map<String, dynamic>;
        final postId = _filteredPosts![index].id;

        print('Post ID: $postId');
        print('Comments: ${post['comments']}');

        return _buildPostCard(post, postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Website Title'),
        automaticallyImplyLeading: false,
        actions: [
          ElevatedButton(
            onPressed: _navigateToAddPost,
            child: Text(
              'اضف منشور',
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
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _navigateToTermsAndConditions,
            child: Text(
              'الشروط و الاحكام',
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
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _navigateToSignUp,
            child: Text('تسجيل', textDirection: TextDirection.rtl),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'يوجد عاملات منزليات نقل خدمات جميع الجنسيات',
              style: TextStyle(fontSize: 36.sp),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16.h),
            Text(
              'عقود نضامية - جهة مرخصة - وفق مساند السعودية',
              style: TextStyle(
                fontSize: 36.sp,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _launchDialer('tel:+9660557346096');
                  },
                  child: Text('رقم الهاتف', textDirection: TextDirection.rtl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  onPressed: () {
                    _launchURL('https://t.me/kadematt');
                  },
                  child: Text('تيليجرام', textDirection: TextDirection.rtl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  onPressed: () {
                    _launchURL(
                        'https://whatsapp.com/channel/0029Va8gHCE3WHTSeCMSU005');
                  },
                  child: Text('واتساب', textDirection: TextDirection.rtl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  'للتواصل:',
                  style:
                      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _applyFilter,
                    child: Text(
                      'بحث',
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
                  Container(
                    width: 1000.w,
                    child: DropdownButton<String>(
                      items: [
                        'يوجد لدي عامل/عاملة منزلية للتنازل',
                        'ابحث عن عامل/عاملة منزلية للتنازل'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        setState(() {
                          _selectedFilter = selectedValue;
                        });
                      },
                      value: _selectedFilter,
                      icon: Icon(
                        MdiIcons.arrowDownBox,
                      ),
                      hint: Text(
                        'اضغط للاختيار',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _selectedFilter == null
                    ? FirebaseFirestore.instance.collection('posts').snapshots()
                    : FirebaseFirestore.instance
                        .collection('posts')
                        .where('title', isEqualTo: _selectedFilter)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final posts = snapshot.data!.docs;
                  return _buildPostList(posts);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _navigateToPreviousPage,
                  child: Text('السابق', textDirection: TextDirection.rtl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: _navigateToNextPage,
                  child: Text('التالي', textDirection: TextDirection.rtl),
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
    );
  }
}
