import 'package:crafters_constellation/main.dart';
import 'package:crafters_constellation/models.dart';
import 'package:crafters_constellation/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Projects extends StatefulWidget {

  const Projects({super.key});

  @override
  State<Projects> createState() => _Projects();
}

class _Projects extends State<Projects> {
  navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      ),
    );
  }
}