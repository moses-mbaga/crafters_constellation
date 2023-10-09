import 'package:crafters_constellation/home.dart';
import 'package:crafters_constellation/models.dart';
import 'package:crafters_constellation/project.dart';
import 'package:crafters_constellation/sign_in.dart';
import 'package:crafters_constellation/sign_up.dart';
import 'package:crafters_constellation/welcome.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

String removeSpecialCharactersFromEmail(String email) {
  // Define a regular expression pattern to match alphabetic characters
  final RegExp pattern = RegExp(r'[a-zA-Z]+');

  // Use the pattern to find matches in the email string
  final Iterable<Match> matches = pattern.allMatches(email);

  // Join the matched characters to form the cleaned email
  final cleanedEmail = matches.map((match) => match.group(0)).join();

  return cleanedEmail;
}


class Path {
  const Path(this.name, this.builder);

  final String name;
  final Future<Widget> Function(BuildContext, String) builder;
}

class RouteConfiguration {
  static List<Path> paths = [
    Path(
      Welcome.route,
          (context, match) async => const Welcome(),
    ),
    Path(
      SignIn.route,
          (context, match) async => const SignIn(),
    ),
    Path(
      SignUp.route,
          (context, match) async => const SignUp(),
    ),
    Path(
      Home.route,
          (context, match) async => const Home(),
    ),
    Path(
      ProjectPage.route,
          (context, match) async {
        final projects = await getProjects(); // Await the result here
        return Project.getProject(projects, match);
      },
    ),
  ];

  static Future<List<Project>> getProjects() async {
    List<Project> projects = [];
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('projects').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, values) {
        projects.add(
          Project.fromJson(values),
        );
      });

      return projects;
    } else {
      return [];
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;

    if (routeName == null) {
      return null;
    }

    for (Path path in paths) {
      if (routeName == path.name) {
        final String parameters = routeName.substring(path.name.length);

        return MaterialPageRoute<void>(
          builder: (context) {
            return FutureBuilder<Widget>(
              future: path.builder(context, parameters),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? Container();
                }
              },
            );
          },
          settings: settings,
        );
        ;
      } else if (path.name == '/project' && routeName.startsWith('/project/')) {
        final String parameters = routeName.substring('/project/'.length);

        return MaterialPageRoute<void>(
          builder: (context) {
            return FutureBuilder<Widget>(
              future: path.builder(context, parameters),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? Container();
                }
              },
            );
          },
          settings: settings,
        );
      }
    }

    return null;
  }
}