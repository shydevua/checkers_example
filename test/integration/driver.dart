// Host side of `flutter drive`: forwards the device test results.
// flutter drive --driver=test/integration/driver.dart \
//   --target=test/integration/app_test.dart -d <device>
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
