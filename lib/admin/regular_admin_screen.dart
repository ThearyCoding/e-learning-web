import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_learningapp_admin/utils/assets_image_utils.dart';
import '../RegularAdmin/RegularScreen/manage_lesson_screen.dart';
import '../controller/quiz_controller.dart';
import '../export/export.dart';
import '../utils/toast_notification_config.dart';

class RegularAdminScreen extends StatefulWidget {
  const RegularAdminScreen({super.key});

  @override
  State<RegularAdminScreen> createState() => _RegularAdminScreenState();
}

class _RegularAdminScreenState extends State<RegularAdminScreen> {
  String currentPage = '/';
  User? user = FirebaseAuth.instance.currentUser;
  String? selectedQuizId;
  bool showAddQuestionPage = false;
  final AdminController adminController = Get.find();
  QuizQuestion? editingQuestion;
  final RegularAdminController controller = Get.find<RegularAdminController>();
  final SideMenuController sideMenu = SideMenuController();
  PageController pageController = PageController();
  final QuizController _quizController = Get.find<QuizController>();
  @override
  void initState() {
    super.initState();
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    _quizController.fetchQuizzes(user!.uid);
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  Uint8List? _imageBytes;

  Future<void> _pickImageweb(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
      });
      String photoUrl = await FirebaseService()
          .uploadPhotoAndGetUrl(_imageBytes!, "admin_image");
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(user!.uid)
          .update({'imageUrl': photoUrl});

      toastificationUtils('update photo Sucessfully',
          icon: Icons.check,
          primaryColor: Colors.green,
          showProgressBar: true,
          title: 'Successfully updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            Row(
              children: [
                Image.asset(
                    width: 100,
                    height: 100,
                    assetPath(
                        "open-book-logo-vector-36080284-removebg-preview.png")),
                const Text(
                  'Devkh E-Learning',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )
              ],
            ),
          ],
        ),
        backgroundColor: Color(0xff212121),
        leading: _isMobile(context)
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        notificationPredicate: (notification) {
          return SnackbarController.isSnackbarBeingShown;
        },
        actions: [
          _isMobile(context)
              ? Container()
              : Obx(() {
                  if (adminController.admin.value == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    Admin superAdmin = adminController.admin.value!;
                    return Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${superAdmin.firstName} ${superAdmin.lastName}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(width: 10),
                            Text(
                                superAdmin.role.isNotEmpty
                                    ? 'Regular Admin'
                                    : 'No Role',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          hoverColor: Colors.lightGreenAccent,
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            _pickImageweb(context);
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                                superAdmin.imageUrl ?? ''),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    );
                  }
                }),
          _isMobile(context)
              ? Container()
              : IconButton(
                  tooltip: 'Sign Out',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          if (!_isMobile(context))
            SideMenu(
              controller: sideMenu,
              style: SideMenuStyle(
                decoration: BoxDecoration(
                 
                  boxShadow: [
                  BoxShadow(
                    color: Colors.indigo,
                    blurRadius: 20,
                    spreadRadius: 0.01,
                    offset: Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Colors.green,
                    blurRadius: 50,
                    spreadRadius: 0.01,
                    offset: Offset(3, 3),
                  ),
                ]),
                itemOuterPadding: EdgeInsets.all(10),
                backgroundColor: Color(0xff1D1E21),
                displayMode: SideMenuDisplayMode.auto,
                hoverColor: Color(0xff2F4047),
                unselectedTitleTextStyle: TextStyle(
                  color: Colors.grey[50],
                  fontSize: 15,
                ),
                unselectedIconColor: Color(0xff6A7886),
                selectedHoverColor: Color(0xff2F4047),
                selectedColor: Color(0xff2F4047),
                selectedTitleTextStyle: const TextStyle(
                    color: Colors.limeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                selectedIconColor: Color(0xff4AC6EA),
              ),
              title: Text(''),
              items: [
                SideMenuItem(
                  title: 'Dashboard',
                  icon: const Icon(Icons.dashboard),
                  onTap: (index, _) {
                    setState(() {
                      currentPage = '/';
                      selectedQuizId = null;
                      showAddQuestionPage = false;
                      editingQuestion = null;
                    });
                    sideMenu.changePage(0);
                  },
                ),
                SideMenuItem(
                  badgeColor: Colors.red,
                  badgeContent: controller.courses.length == 0
                      ? null
                      : Text(
                          controller.courses.length.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                  title: 'Course Overview',
                  icon: const Icon(Icons.school),
                  onTap: (index, _) {
                    setState(() {
                      currentPage = '/subcategories';
                      selectedQuizId = null;
                      showAddQuestionPage = false;
                      editingQuestion = null;
                    });
                    sideMenu.changePage(1);
                  },
                ),
                SideMenuItem(
                  title: 'Manage Lessons',
                  icon: const Icon(Icons.video_collection),
                  onTap: (index, _) {
                    setState(() {
                      currentPage = '/topic';
                      selectedQuizId = null;
                      showAddQuestionPage = false;
                      editingQuestion = null;
                    });
                    sideMenu.changePage(2);
                  },
                ),
                SideMenuItem(
                  title: 'Quiz Manage',
                  icon: const Icon(Icons.quiz),
                  onTap: (index, _) {
                    setState(() {
                      currentPage = '/quiz_manage';
                      selectedQuizId = null;
                      showAddQuestionPage = false;
                      editingQuestion = null;
                    });
                    sideMenu.changePage(3);
                  },
                ),
              ],
            ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _getPage('/'),
                _getPage('/subcategories'),
                _getPage('/topic'),
                _getPage('/quiz_manage'),
              ],
            ),
          ),
        ],
      ),
      drawer: _isMobile(context)
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Obx(() {
                      if (adminController.admin.value == null) {
                        return configloadingProgressIndicator();
                      } else {
                        Admin superAdmin = adminController.admin.value!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(superAdmin.imageUrl ?? ''),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${superAdmin.firstName} ${superAdmin.lastName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              superAdmin.role.isNotEmpty
                                  ? 'Regular Admin'
                                  : 'No Role',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () {
                      sideMenu.changePage(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Courses Manage'),
                    onTap: () {
                      sideMenu.changePage(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(IconlyBold.video),
                    title: const Text('Topic Manage'),
                    onTap: () {
                      sideMenu.changePage(2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.quiz),
                    title: const Text('Quiz Manage'),
                    onTap: () {
                      sideMenu.changePage(3);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _getPage(String page) {
    switch (page) {
      case '/':
        return SingleChildScrollView(
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
        );
      case '/subcategories':
        return const RegularCoursesScreen();
      case '/topic':
        return const ManageLessonScreen();
      case '/quiz_manage':
        if (selectedQuizId == null) {
          return ShowAllQuizPage(
            adminId: user!.uid,
            onQuizSelected: (quizId) {
              setState(() {
                selectedQuizId = quizId;
                showAddQuestionPage = false;
                editingQuestion = null;
              });
              sideMenu.changePage(3);
            },
          );
        } else if (showAddQuestionPage || editingQuestion != null) {
          return AddUpdateQuiz(
            courseId: selectedQuizId!,
            question: editingQuestion,
            onQuestionAdded: () {
              setState(() {
                showAddQuestionPage = false;
                editingQuestion = null;
              });
            },
            onCancel: () {
              setState(() {
                showAddQuestionPage = false;
                editingQuestion = null;
              });
            },
            onSave: (question) {
              setState(() {
                showAddQuestionPage = false;
                editingQuestion = null;
              });
            },
          );
        } else {
          return ShowQuizPage(
            courseId: selectedQuizId!,
            onQuizSelected: (value) {
              setState(() {
                selectedQuizId = null;
              });
            },
            onAddQuestion: () {
              setState(() {
                showAddQuestionPage = true;
                editingQuestion = null;
              });
            },
            onEditQuestion: (question) {
              setState(() {
                showAddQuestionPage = false;
                editingQuestion = question;
              });
            },
          );
        }
      default:
        return Container();
    }
  }
}
