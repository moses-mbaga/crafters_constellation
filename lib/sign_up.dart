import 'dart:async';

import 'package:crafters_constellation/home.dart';
import 'package:crafters_constellation/main.dart';
import 'package:crafters_constellation/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SignUp extends StatefulWidget {
  static const String route = '/sign-up';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  bool isPasswordVisible = false;
  List<dynamic> interests = [];
  List<dynamic> selectedInterests = [];
  List<dynamic> skills = [];
  List<dynamic> selectedSkills = [];
  List<dynamic> languages = [];
  List<dynamic> selectedLanguages = [];
  TextEditingController bioController = TextEditingController();
  VideoPlayerController? _controller;

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ).then((value) async {
        print('it worked 1');

        DatabaseReference ref = FirebaseDatabase.instance.ref("users/${removeSpecialCharactersFromEmail(emailController.text)}");

        await ref.set({
          "skills": selectedSkills,
          "interests": selectedInterests,
          "languages": selectedLanguages,
          "bio": bioController.text,
          "countryOfResidence": countryController.text,
        }).then((value) async {
          navigate(Home.route);
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  String? validateEmail(String? value) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(pattern);

    if (value!.isEmpty) {
      return 'Fill this field';
    } else if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Fill this field';
    } else if (value.length < 8) {
      return 'Password length is less than 8 characters';
    } else if (!hasComplexity(value)) {
      return 'Password is not strong enough';
    } else if (hasCommonPatterns(value)) {
      return 'Password has a common pattern';
    }
    return null;
  }

  bool hasComplexity(String value) {
    bool hasUppercase = false;
    bool hasLowercase = false;
    bool hasNumber = false;

    for (int i = 0; i < value.length; i++) {
      if (value[i].toUpperCase() != value[i]) {
        hasUppercase = true;
      } else if (value[i].toLowerCase() != value[i]) {
        hasLowercase = true;
      } else if (int.tryParse(value[i]) != null) {
        hasNumber = true;
      }
    }

    return hasUppercase && hasLowercase && hasNumber;
  }

  bool hasCommonPatterns(String value) {
    List<String> commonPatterns = [
      "123456",
      "password",
      "qwerty",
      "admin",
      "abc123",
      "letmein",
      "welcome",
      "login",
      "iloveyou",
      "sunshine",
      "princess",
      "password1",
      "1234567890",
      "qwertyuiop",
      "asdfghjkl",
      "zxcvbnm",
      "123123",
      "12345678",
      "football",
      "baseball",
    ];

    for (String pattern in commonPatterns) {
      if (value.toLowerCase().contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  getInterests() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('tags').get();
    if (snapshot.exists) {
      interests = snapshot.value as List<dynamic>;
    } else {
      print('No data available.');
    }
  }

  getSkills() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('skills').get();
    if (snapshot.exists) {
      skills = snapshot.value as List<dynamic>;
    } else {
      print('No data available.');
    }
  }

  getLanguages() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('languages').get();
    if (snapshot.exists) {
      languages = snapshot.value as List<dynamic>;
    } else {
      print('No data available.');
    }
  }

  addSkill() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          skills[index],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedSkills.add(skills[index]);
                          skills.removeAt(index);
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }
    );
  }

  Skills() {
    return Container(
      height: selectedSkills.isNotEmpty ? 60 : 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedSkills.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              right: selectedSkills.length != 1 || selectedSkills.length != index ? 10 : 0,
            ),
            child: InputChip(
              label: Text(selectedSkills[index]),
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              backgroundColor: MyApp.mainColor,
              deleteIconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onDeleted: () {
                setState(() {
                  skills.add(selectedSkills[index]);
                  selectedSkills.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }

  addInterest() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: interests.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          interests[index],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedInterests.add(interests[index]);
                          interests.removeAt(index);
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }
    );
  }

  Interests() {
    return Container(
      height: selectedInterests.isNotEmpty ? 60 : 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedInterests.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              right: selectedInterests.length != 1 || selectedInterests.length != index ? 10 : 0,
            ),
            child: InputChip(
              label: Text(selectedInterests[index]),
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              backgroundColor: MyApp.mainColor,
              deleteIconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onDeleted: () {
                setState(() {
                  skills.add(selectedInterests[index]);
                  selectedInterests.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }

  addLanguage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          languages[index],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedLanguages.add(languages[index]);
                          languages.removeAt(index);
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }
    );
  }

  Languages() {
    return Container(
      height: selectedLanguages.isNotEmpty ? 60 : 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedLanguages.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              right: selectedLanguages.length != 1 || selectedLanguages.length != index ? 10 : 0,
            ),
            child: InputChip(
              label: Text(selectedLanguages[index]),
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              backgroundColor: MyApp.mainColor,
              deleteIconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onDeleted: () {
                setState(() {
                  skills.add(selectedLanguages[index]);
                  selectedLanguages.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    getInterests();
    getSkills();
    getLanguages();
    _controller = VideoPlayerController.asset("assets/video_2.mp4");
    _controller!.initialize().then((_) {
      _controller!.setLooping(true);
      Timer(const Duration(milliseconds: 100), () {
        setState(() {
          _controller!.play();
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width ?? 0,
                    height: _controller!.value.size.height ?? 0,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 120,
                      horizontal: 30,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Sign Up',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 25,
                              bottom: 10,
                            ),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1.2,
                                    color: Color(0xFFCDCDCD),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                labelText: 'Email Address',
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              validator: validatePassword,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1.2,
                                    color: Color(0xFFCDCDCD),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                labelText: 'Password',
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: TextFormField(
                              controller: countryController,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'Fill this field';
                                }
                              },
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1.2,
                                    color: Color(0xFFCDCDCD),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                labelText: 'Country of Residence',
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Skills',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  isExtended: true,
                                  elevation: 0,
                                  focusElevation: 0,
                                  hoverElevation: 0,
                                  hoverColor: Colors.transparent,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text('Add'),
                                    ],
                                  ),
                                  onPressed: () {
                                    addSkill();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Skills(),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Interests',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  isExtended: true,
                                  elevation: 0,
                                  focusElevation: 0,
                                  hoverElevation: 0,
                                  hoverColor: Colors.transparent,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text('Add'),
                                    ],
                                  ),
                                  onPressed: () {
                                    addInterest();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Interests(),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Languages',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                FloatingActionButton(
                                  backgroundColor: Colors.transparent,
                                  isExtended: true,
                                  elevation: 0,
                                  focusElevation: 0,
                                  hoverElevation: 0,
                                  hoverColor: Colors.transparent,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text('Add'),
                                    ],
                                  ),
                                  onPressed: () {
                                    addLanguage();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Languages(),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: TextFormField(
                              controller: bioController,
                              minLines: 15,
                              maxLines: 30,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Fill this field';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1.2,
                                    color: Color(0xFFCDCDCD),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                labelText: 'Bio',
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 120,
                              ),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: MyApp.mainColor,
                                  minimumSize: const Size.fromHeight(60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    if (selectedSkills.length < 3) {
                                      showSnackBar('Add at least three Skills');
                                    } else if (selectedInterests.length < 3) {
                                      showSnackBar('Add at least three Interests');
                                    } else if (selectedLanguages.isEmpty) {
                                      showSnackBar('Add at least one Language');
                                    }

                                    signUp();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}