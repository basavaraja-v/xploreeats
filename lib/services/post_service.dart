import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xploreeats/models/post.dart';

class PostService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference reference =
          _storage.ref().child('postimages').child(fileName);
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> addPost(Post newPost, File imageFile) async {
    try {
      // Upload image and get the download URL
      String imageUrl = await _uploadImage(imageFile);

      // Add the image URL to the newPost
      newPost.imageUrl = imageUrl;

      // Convert newPost to a map
      Map<String, dynamic> postData = newPost.toMap();

      // Save the newPost to the Firestore collection
      FirebaseFirestore.instance.collection('posts').add(postData);
      print('Post created successfully!');
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Stream<List<Post>> getPostsStream() {
    return FirebaseFirestore.instance.collection('posts').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Post.fromMap(data, doc.id);
        }).toList();
      },
    );
  }

  Future<void> updateLoveStatus(Post post) async {
    bool isLoved = !post.isLikedByCurrentUser!;
    DocumentReference postRef = _db.collection('posts').doc(post.docId);
    if (isLoved) {
      await postRef.update({
        'likeCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([post.userId]),
      });
    } else {
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([post.userId]),
      });
    }
  }
}
