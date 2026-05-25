enum MquizAuthProvider { google, apple, phone, guest }

extension AuthProviderExtension on MquizAuthProvider {
  String get apiType {
    switch (this) {
      case MquizAuthProvider.google:
        return 'google';
      case MquizAuthProvider.apple:
        return 'apple';
      case MquizAuthProvider.phone:
        return 'phone';
      case MquizAuthProvider.guest:
        return 'guest';
    }
  }
}
