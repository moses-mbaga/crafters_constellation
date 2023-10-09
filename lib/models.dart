import 'package:crafters_constellation/home.dart';
import 'package:crafters_constellation/project.dart';
import 'package:flutter/material.dart';

class Project {
  final String coverUrl;
  final String name;
  final String path;
  final String website;
  final String information;
  final Map<String, dynamic> resources;
  final List<dynamic> users;
  final bool isOpen;

  Project({
    required this.coverUrl,
    required this.name,
    required this.path,
    required this.website,
    required this.information,
    required this.resources,
    required this.users,
    required this.isOpen,
  });

  static Widget getProject(List<Project> projects, String path) {
    Project? selectedProject;
    for (Project project in projects) {
      if (project.path == path) {
        selectedProject = project;
        break;
      }
    }

    if (selectedProject != null) {
      return ProjectPage(
        project: selectedProject,
      );
    } else {
      return const Home();
    }
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    String titleToUrlPath(String title) {
      String cleanedTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').toLowerCase();
      cleanedTitle = cleanedTitle.replaceAll(RegExp(r'\s+'), '-');
      cleanedTitle = cleanedTitle.replaceAll(RegExp(r'^-+|-+$'), '');
      return cleanedTitle;
    }

    return Project(
      coverUrl: json['cover_url'] as String,
      name: json['name'] as String,
      path: titleToUrlPath(json['name']),
      website: json['website'] as String,
      information: json['information'] as String,
      resources: json['resources'] as Map<String, dynamic>,
      users: json['users'] ?? [],
      isOpen: json['isOpen'] as bool,
    );
  }
}

class Media {
  final String url;
  final String title;

  Media({
    required this.url,
    required this.title,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      url: json['url'] as String,
      title: json['title'] as String,
    );
  }
}

class ProjectMedia {
  final Map<String, Media> images;
  final Map<String, Media> videos;
  final Map<String, Media> objects3D;

  ProjectMedia({
    required this.images,
    required this.videos,
    required this.objects3D,
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      images: json['images'] != null ? (json['images'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, Media.fromJson(value)),
      ) : {},
      videos: json['videos'] != null ? (json['videos'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, Media.fromJson(value)),
      ) : {},
      objects3D: json['3d_objects'] != null ? (json['3d_objects'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, Media.fromJson(value)),
      ) : {},
    );
  }
}

class Resource {
  final String name;
  final String url;
  final List<dynamic> tags;

  Resource({
    required this.name,
    required this.url,
    required this.tags,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    String titleToUrlPath(String title) {
      String cleanedTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').toLowerCase();
      cleanedTitle = cleanedTitle.replaceAll(RegExp(r'\s+'), '-');
      cleanedTitle = cleanedTitle.replaceAll(RegExp(r'^-+|-+$'), '');
      return cleanedTitle;
    }

    return Resource(
      name: json['name'] as String,
      url: json['url'] as String,
      tags: json['tags'] as List<dynamic>,
    );
  }
}