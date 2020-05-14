import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'activity_feed.dart';
import 'create_account.dart';
import 'profile.dart';
import 'search.dart';
import 'upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageReference = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection("posts");
final commentsRef = Firestore.instance.collection('comments');
final feedRef = Firestore.instance.collection('feed');
final timeStamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Declare Variables
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  //OnStart
  @override
  void initState() { 
    super.initState();

    //set variables
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err){
        print('Error signing in: $err');
       }
    );
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
      }).catchError((err){
        print('Error signing in: $err');
      });
  }

  @override
  void dispose() { 
    pageController.dispose();
    super.dispose();
  }
  
  //Funtion Handlers
  handleSignIn(GoogleSignInAccount account){
    if(account != null){
      createUserInFirestore();
      print("User signed in!: $account");
      setState(() {
        isAuth = true;
      });
    }
    else{
      setState(() {
        isAuth = false;
      });
    }
  }
  
  createUserInFirestore() async{
    //exists in userscollection in database
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    //if doesnt exists take to create account page
    if(!doc.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
      //get username from create account, use it to make a  new users document in the collection.
      usersRef.document(user.id).setData({
        "id": user.id,
        "username" : username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp":timeStamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    
  }
  
  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          RaisedButton(
            child: Text('Logout'),
            onPressed: logout,
          ),
          //Timeline(),
          ActivityFeed(),
          Upload(currentUser : currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController ,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap ,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 35.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      )
      );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FameGame',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Theme.of(context).accentColor,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
