

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:twitter/models/user_info_with_follow.dart';
import 'package:twitter/screens/authentication/sign_in.dart';
import 'package:twitter/screens/authentication/sign_up.dart';
import 'package:twitter/screens/home/home.dart';

import '../models/user.dart';

class GlobalVariable{

  static double paddingScreen = 15;
  static String avatar = "https://firebasestorage.googleapis.com/v0/b/twitter-a10b3.appspot.com/o/avatar%2Fblack.jpg?alt=media&token=ab719234-3771-4309-b004-c464e0ed2281";
  static late String wall;
  static late MyUserWithFollow? currentUser = null;
  static int numOfFollowing = 0;
  static int numOfFollowed = 0;
  static Map<String, WidgetBuilder>  routes = {
    '/home' : (context) => Home(),
    '/login' : (context) => SignIn(),
    '/login-step-1': (context) => SignInStep1(),
    '/login-step-2' : (context) => SignInStep2(),
    '/register' : (context) => SignUp(),
    '/register-step-2': (context) =>SignUpStep2()
  };

  String caculateUploadDate(DateTime date){
    DateTime currentDate = DateTime.now().toUtc();
    // Calculate the absolute difference
    Duration difference = currentDate.difference(date);
    if (difference.inHours >= 24 ) {
      if(difference.inDays>365){
        return DateFormat.yMMMd("en_US").format(date).toString();
      }else {
        return DateFormat.MMMd("en_US").format(date).toString();
      }
    }else {
      return "${(difference.inMinutes/60).round()}h";
    }
  }
}
