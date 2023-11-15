import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram/models/comment.dart';
import 'package:flutter_instagram/models/post.dart';
import 'package:flutter_instagram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    String res = 'Some error occurred';
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(
      String postId, String? uid, List likes, bool smallLike) async {
    try {
      if (uid != null && (smallLike || !likes.contains(uid))) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': likes.contains(uid)
              ? FieldValue.arrayRemove([uid])
              : FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> likeComment(
      String postId, String commentId, String? uid, List likes) async {
    try {
      if (uid != null) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': likes.contains(uid)
              ? FieldValue.arrayRemove([uid])
              : FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> postComment(String postId, String text, String? uid,
      String? username, String? profImage) async {
    try {
      if (text.isNotEmpty && uid != null) {
        String commentId = const Uuid().v1();
        Comment comment = Comment(
          postId: postId,
          commentId: commentId,
          username: username!,
          uid: uid,
          text: text,
          datePublished: DateTime.now(),
          profImage: profImage!,
          likes: [],
        );
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deletePostAndComments(String postId, String postUrl) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      documentReference.collection('comments').get().then((comments) async {
        for (var comment in comments.docs) {
          await documentReference
              .collection('comments')
              .doc(comment.id.toString())
              .delete();
        }
      });
      await StorageMethods().deleteImage(postUrl);
      await documentReference.delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      
    } catch (err) {
      print(err.toString());
    }
  }
  Future<void> followUser(
    String uid,
    String followId
  ) async{
    try{
      DocumentSnapshot snap =  await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)){ // we are following that person
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else{
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    }catch(err){
      print(err.toString());
    }
  }
}
