import 'package:crafters_constellation/projects.dart';
import 'package:crafters_constellation/resources.dart';
import 'package:crafters_constellation/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static const String route = '/home';

  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        navigate(Welcome.route);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.diversity_3,
                ),
                text: 'Projects',
              ),
              Tab(
                icon: Icon(
                  Icons.public,
                ),
                text: 'Resources',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Projects(),
            Resources(),
          ],
        ),
      ),
    );
  }
}