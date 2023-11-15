import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String profImage;
  final String username;
  final String uid;
  final String text;
  final datePublished;
  final List likes;
  final String commentId;
  final String postId;

  const Comment({
    required this.postId,
    required this.commentId,
    required this.username,
    required this.uid,
    required this.text,
    required this.datePublished,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'username': username,
        'uid': uid,
        'datePublished': datePublished,
        'profImage': profImage,
        'likes': likes,
        'text': text,
        'postId': postId,
      };

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      postId: snapshot['postId'],
      commentId: snapshot['commentId'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      text: snapshot['text'],
      likes: snapshot['likes'],
      profImage: snapshot['profImage'],
      datePublished: snapshot['datePublished'],
    );
  }
}
