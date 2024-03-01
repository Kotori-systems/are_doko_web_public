enum FirestoreCollections {
  users('users'),
  items('items'),
  locationCategories('location_categories'),
  itemCategories('item_categories');

  final String name;

  const FirestoreCollections(this.name);
}
