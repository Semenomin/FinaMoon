/// This class used to handle category data
class Categories
{
  int categoryId;
  String categoryType;
  String categoryName;

  Categories(this.categoryId, this.categoryType, this.categoryName);

  Categories.fromMap(Map map) {
    categoryId = map[categoryId];
    categoryType = map[categoryType];
    categoryName = map[categoryName];
  }
}