import 'package:crafters_constellation/models.dart';
import 'package:crafters_constellation/project.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Projects extends StatefulWidget {

  const Projects({super.key});

  @override
  State<Projects> createState() => _Projects();
}

class _Projects extends State<Projects> {
  List<Project> projects = [];

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

  getProjects() async {
    showLoading();
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('projects').get();
    if (snapshot.exists) {
      setState(() {
        Map<dynamic, dynamic> values = snapshot.value as Map;
        values.forEach((key, values) {
          projects.add(
            Project.fromJson(values),
          );
        });
      });
    } else {
      print('No data available.');
    }
  }

  GridBox(int index) {
    Project project = projects[index];

    return Column(
      children: [
        InkWell(
          child: Center(
            child: Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    'https://corsproxy.io/?${project.coverUrl}',
                  ),
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
          ),
          onTap: () {
            navigate('${ProjectPage.route}/${project.path}');
          },
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 8,
          ),
          child: Text(
            project.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    getProjects();
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
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              return GridBox(index);
            },
          ),
        ),
      ),
    );
  }
}