import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/screens/profile_screen.dart';
import 'package:flutter_instagram/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          decoration: const InputDecoration(
            label: Text('Search for user'),
          ),
          controller: _searchController,
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('username')
                  .startAt([_searchController.text]).endAt(
                      ["${_searchController.text}\uf8ff"]).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: ((context, index) {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: snapshot.data!.docs[index]['uid']))),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  snapshot.data!.docs[index]['photoUrl']),
                            ),
                            title: Text(
                                snapshot.data!.docs[index].data()['username']),
                          ),
                        );
                    }));
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                  child: StaggeredGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children:
                        List.generate(snapshot.data!.docs.length, (index) {
                      return StaggeredGridTile.count(
                        crossAxisCellCount: index % 7 == 0 ? 2 : 1,
                        mainAxisCellCount: index % 7 == 0 ? 2 : 1,
                        child: CachedNetworkImage(imageUrl: snapshot.data!.docs[index]['postUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                        )
                        // child: Image.network(
                        //     snapshot.data!.docs[index]['postUrl'],
                        //     fit: BoxFit.cover),
                      );
                    }),
                  ),
                );
              }),
            ),
    );
  }
}
