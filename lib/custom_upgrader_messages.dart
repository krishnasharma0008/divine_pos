import 'package:upgrader/upgrader.dart';

class MyUpgraderMessages extends UpgraderMessages {
  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.title:
        return 'Update Required';

      case UpgraderMessage.body:
        return 'A new version is available.';

      case UpgraderMessage.prompt:
        return 'Please update to continue using the application.';

      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';

      default:
        return super.message(messageKey) ?? '';
    }
  }
}
