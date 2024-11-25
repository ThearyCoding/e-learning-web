import '../export/export.dart';
import '../utils/assets_image_utils.dart';
import '../widgets/build_deshboard_card.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({Key? key}) : super(key: key);

  @override
  SuperAdminScreenState createState() => SuperAdminScreenState();
}

class SuperAdminScreenState extends State<SuperAdminScreen> {
  final AdminController adminController = Get.find();

  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
      if (index == 3) {
        adminController.fetchRegularAdmins();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isMobile(context) == false  ?  Color(0xff212121) : Colors.transparent,
        notificationPredicate: (notification) {
          return SnackbarController.isSnackbarBeingShown;
        },
        iconTheme: IconThemeData(
          color:  _isMobile(context) == false ?  Colors.white : Colors.black,
        ),
        title:  _isMobile(context) == false ?  Row(
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
            )
          ],
        ): null,
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
                                    fontSize: 14, color: Colors.white)),
                            const SizedBox(width: 10),
                            Text(
                                superAdmin.role.isNotEmpty
                                    ? 'Super Admin'
                                    : 'No Role',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage(superAdmin.imageUrl ?? ''),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _isMobile(context)
              ? [
                  // Mobile layout
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardPage(),
                        CategoryPage(),
                        CourseListScreen(),
                        const AdministratorControlScreen(),
                      ],
                    ),
                  ),
                ]
              : [
                  // Tablet and desktop layout
                  SideMenu(
                    controller: sideMenu,
                    style: SideMenuStyle(
                      decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
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
                    items: [
                      SideMenuItem(
                        title: 'Dashboard',
                        onTap: (index, _) {
                          sideMenu.changePage(index);
                        },
                        icon: const Icon(Icons.dashboard),
                      ),
                      SideMenuItem(
                        title: 'Manage Categories',
                        onTap: (index, _) {
                          sideMenu.changePage(index);
                        },
                        icon: const Icon(IconlyBold.category),
                      ),
                      SideMenuItem(
                        title: 'Manage Courses',
                        onTap: (index, _) {
                          sideMenu.changePage(index);
                        },
                        icon: const Icon(IconlyBold.video),
                      ),
                      SideMenuItem(
                        title: 'Manage Teachers',
                        onTap: (index, _) {
                          sideMenu.changePage(index);
                        },
                        icon: const Icon(IconlyBold.category),
                      ),
                    
                    ],
                  ),
                  const VerticalDivider(width: 0),
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardPage(),
                        CategoryPage(),
                        CourseListScreen(),
                        const AdministratorControlScreen(),
                      ],
                    ),
                  ),
                ],
        ),
      ),
      drawer: _isMobile(context)
          ? Drawer(
              // Drawer for mobile devices
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Obx(() {
                      if (adminController.admin.value == null) {
                        return const CircularProgressIndicator();
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
                                  ? 'Super Admin'
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
                    leading: const Icon(IconlyBold.category),
                    title: const Text('Categories Manage'),
                    onTap: () {
                      sideMenu.changePage(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(IconlyBold.video),
                    title: const Text('Courses Manage'),
                    onTap: () {
                      sideMenu.changePage(2);
                      Navigator.pop(context);
                    },
                  ),
                
                  ListTile(
                    leading: const Icon(IconlyBold.category),
                    title: const Text('Teacher Manage'),
                    onTap: () {
                      sideMenu.changePage(3);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Sign Out'),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardPage() {
    return Obx(() {
      if (adminController.isLoading.value) {
        return configloadingProgressIndicator();
      } else if (adminController.errorMessage.isNotEmpty) {
        return Center(child: Text(adminController.errorMessage.value));
      } else {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Tablet/Desktop layout
              return _buildWideLayout();
            } else {
              // Mobile layout
              return _buildNarrowLayout();
            }
          },
        );
      }
    });
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: buildDashboardCard('Total Courses',
                      adminController.totalCourses.toString(), Icons.school)),
              const SizedBox(width: 20),
              Expanded(
                  child: buildDashboardCard('Total Users',
                      adminController.totalUsers.toString(), Icons.people)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: buildDashboardCard(
                      'Active Courses',
                      adminController.activeCourses.toString(),
                      Icons.play_circle_fill)),
              const SizedBox(width: 20),
              Expanded(
                  child: buildDashboardCard(
                      'Pending Approvals',
                      adminController.pendingApprovals.toString(),
                      Icons.pending)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        buildDashboardCard('Total Courses',
            adminController.totalCourses.toString(), Icons.school),
        const SizedBox(height: 20),
        buildDashboardCard(
            'Total Users', adminController.totalUsers.toString(), Icons.people),
        const SizedBox(height: 20),
        buildDashboardCard('Active Courses',
            adminController.activeCourses.toString(), Icons.play_circle_fill),
        const SizedBox(height: 20),
        buildDashboardCard('Pending Approvals',
            adminController.pendingApprovals.toString(), Icons.pending),
      ],
    );
  }
}
