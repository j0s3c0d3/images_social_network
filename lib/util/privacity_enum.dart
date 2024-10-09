
enum Privacity {
  none,
  friends,
  all
}

extension PrivacityExtension on Privacity {

  static Privacity getPrivacity(String string) {
    switch (string) {
      case "friends":
        return Privacity.friends;
      case "all":
        return Privacity.all;
      default:
        return Privacity.none;
    }
  }

}