import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import 'home.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;


  clearSearch(){
    searchController.clear();
  }
  handleSearch(String query){
    Future<QuerySnapshot> users = usersRef.where("displayName", isGreaterThanOrEqualTo: query ).getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }
  buildSearchResults(){
    return FutureBuilder(
      builder: (context, snapShot){

        if(!snapShot.hasData){
          return circularProgress(context);
        }
        List<UserResult> searchResults = [];
        snapShot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult =  UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
      future: searchResultsFuture,
      );
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Find a user ...",
          filled: true,
          prefixIcon: Icon(Icons.account_circle, size : 28.0),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear), 
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }
  Container buildNoContent() {
    final ori = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: ori == Orientation.portrait? 250.0 : 200.0
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
     super.build(context);
     return Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        appBar: buildSearchField(),
        body: searchResultsFuture == null ?  buildNoContent() : 
        buildSearchResults(),
     );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(children: <Widget>[
        GestureDetector(
          onTap : () => showProfile(context, profileId: user.id),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              user.displayName, 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
            subtitle: Text(
              user.username, 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ),
        Divider(
          height: 2.0,
          color: Colors.white54,
        ),
      ],)
    );
  }
}
