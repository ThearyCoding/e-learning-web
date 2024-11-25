import 'package:e_learningapp_admin/utils/easy_loading__configure_utils.dart';
import 'package:toastification/toastification.dart';
import 'bindings/init_bindings.dart';
import 'export/export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E Learning Admin',
        builder: EasyLoading.init(),
        initialBinding: InitBindings(),
        home: IsAuthenticated(),
      ),
    );
  }
}
