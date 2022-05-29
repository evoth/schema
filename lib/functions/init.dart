import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void initApp(BuildContext context, User? user) async {
  if (user == null) {
    Navigator.of(context).pushNamed('/signIn');
    return;
  }

  Navigator.of(context).pushNamed('/home');
}
