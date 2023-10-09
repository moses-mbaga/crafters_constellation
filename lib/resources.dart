import 'package:crafters_constellation/main.dart';
import 'package:crafters_constellation/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Resources extends StatefulWidget {

  const Resources({super.key});

  @override
  State<Resources> createState() => _Resources();
}

class _Resources extends State<Resources> {
  List<Resource> resources = [];

  navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  showLoading() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  getResources() async {
    showLoading();
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('resources').get();
    if (snapshot.exists) {
      setState(() {
        Map<dynamic, dynamic> values = snapshot.value as Map;
        values.forEach((key, values) {
          resources.add(
            Resource.fromJson(values),
          );
        });
      });
    } else {
      print('No data available.');
    }
  }

  @override
  void initState() {
    getResources();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: resources.length,
            itemBuilder: (BuildContext context, int index) {
              Resource resource = resources[index];
              return Column(
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Text(
                              resource.name,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            height: resource.tags.isNotEmpty ? 40 : 0,
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: resource.tags.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: resource.tags.length != 1 || resource.tags.length != index ? 10 : 0,
                                  ),
                                  child: Chip(
                                    label: Text(resource.tags[index]),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    backgroundColor: MyApp.mainColor,
                                    deleteIconColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(resource.url),
                        webOnlyWindowName: '_blank',
                      );
                    },
                  ),
                  const Divider(
                    thickness: .5,
                    color: Color(0xFFCDCDCD),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}