enum MquizAuthProvider { google, apple, phone, guest, email }

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
      case MquizAuthProvider.email:
        return 'email';
    }
  }
}
