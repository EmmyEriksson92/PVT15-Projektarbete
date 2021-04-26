class Favorites {
  int date;
  String name;
  bool isAFavorite;
  List<String> dates = [];
  List<Favorites> favouritePlaces = [];

  Favorites(this.name, isFavorite);

  String getName() {
    return name;
  }

  int getDate() {
    return date;
  }

  bool checkIsAFavorite(String name) {
    if (name == getName() && isAFavorite == true)
      return true;
    else
      return false;
  }

  List<Favorites> getFavorite() {
    return favouritePlaces;
  }

  void addFavorite(Favorites fav) {
    isAFavorite = true;
    favouritePlaces.add(fav);
  }

  void removeFavorite(Favorites fav) {
    isAFavorite = false;
    favouritePlaces.remove(fav);
  }
}
