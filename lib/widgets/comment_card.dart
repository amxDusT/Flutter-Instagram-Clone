import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/user.dart';
import 'package:flutter_instagram/providers/user_provider.dart';
import 'package:flutter_instagram/resources/firestore_methods.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({super.key, required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profImage']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          text: widget.snap['username'],
                        ),
                        TextSpan(
                          style: const TextStyle(fontSize: 14),
                          text: ' ${widget.snap['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat.yMMMd().add_Hm()
                        .format(widget.snap['datePublished'].toDate()),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      )),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              FirestoreMethods().likeComment(widget.snap['postId'], widget.snap['commentId'], user?.uid, widget.snap['likes']);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                widget.snap['likes'].contains(user?.uid)? Icons.favorite : Icons.favorite_border,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
