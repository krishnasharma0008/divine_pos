/// A icon to display before the toolbar's [title].
enum AppBarLeading { none, drawer, back }

enum AppBarAction { search, cart, notification, profile }

enum TopTabType { productInStore, allDesignCheck }

enum JewelleryProductKey {
  category("category"),
  collection("collection");

  // Associate a custom string value
  const JewelleryProductKey(this.value);
  final String value;

  // A static method to convert a custom string back to an enum value
  static JewelleryProductKey? fromValue(String val) {
    for (var status in JewelleryProductKey.values) {
      if (status.value == val) return status;
    }
    return null;
  }
}