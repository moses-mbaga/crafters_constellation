import 'package:cached_network_image/cached_network_image.dart';
import 'package:crafters_constellation/main.dart';
import 'package:crafters_constellation/models.dart';
import 'package:crafters_constellation/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:object_3d/object_3d.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectPage extends StatefulWidget {
  static const String route = '/project';
  static String Function(String path) routeFromPath =
      (String path) => '$route/$path';
  Project project;

  ProjectPage({
    required this.project,
  });

  @override
  State<ProjectPage> createState() => _ProjectPage();
}

class _ProjectPage extends State<ProjectPage> {
  Project? project;

  navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  Information() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: 'https://corsproxy.io/?${project!.coverUrl}',
            imageBuilder: (context, imageProvider) {
              return Container(
                width: 400,
                child: Image(
                  image: imageProvider,
                ),
              );
            },
            errorWidget: (context, url, error) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(.5),
                ),
                child: Center(
                  child: Text(
                    project!.name[0],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
            placeholder: (context, url) {
              return const CircularProgressIndicator();
            },
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 40,
            ),
            child: Text(
              project!.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: const Text(
              "The Project's Website",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 15,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  await launchUrl(
                    Uri.parse(project!.website),
                  );
                },
                child: Text(
                  project!.website,
                  style: const TextStyle(
                    color: MyApp.mainColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: const Text(
              "Information",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 15,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: Text(
              project!.information,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Images(List<Media> media) {
    if (media == []) {
      return Container();
    } else {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 20,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: const Text(
              "Images",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: media.length != 1 || media.length != index ? 10 : 0,
                  ),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://corsproxy.io/?${media[index].url}',
                        imageBuilder: (context, imageProvider) {
                          return Image(
                            image: imageProvider,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary.withOpacity(.5),
                            ),
                            child: Center(
                              child: Text(
                                project!.name[0],
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                        placeholder: (context, url) {
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Videos(List<Media> media) {
    if (media == []) {
      return Container();
    } else {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 20,
              right: 300,
              left: 300,
            ),
            width: double.infinity,
            child: const Text(
              "Videos",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }
  }

  Resources() {
    List<Media> images = project!.resources['images'] != null ? List<Media>.from(
      project!.resources['images'].values.map((model) {
        return Media.fromJson(model);
      }),
    ) : [];
    List<Media> videos = project!.resources['videos'] != null ? List<Media>.from(
      project!.resources['videos'].values.map((model) {
        return Media.fromJson(model);
      }),
    ) : [];

    return Column(
      children: [
        Images(images),
        Videos(videos),
        Container(
          margin: const EdgeInsets.only(
            bottom: 20,
            right: 300,
            left: 300,
          ),
          width: double.infinity,
          child: const Text(
            "3D Objects",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const Object3D(
          size: Size(
            400.0,
            400.0,
          ),
          path: "assets/arduino_board.obj",
        ),
      ],
    );
  }

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        navigate(Welcome.route);
      }
    });
    project = widget.project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 10,
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.question_mark,
                  ),
                  text: 'Information',
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
          body: TabBarView(
            children: [
              Information(),
              Resources(),
            ],
          ),
        ),
      ),
    );
  }
}