import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      navigateToGetStarted();
    });
    super.initState();
  }

  void navigateToGetStarted() {
    if (storage.read('token') != null) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.getStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(AssetsConstant.mainLogo)));
  }
}
