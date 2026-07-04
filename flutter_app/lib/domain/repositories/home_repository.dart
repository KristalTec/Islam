import '../entities/feed_item_entity.dart';

abstract class HomeRepository {
  Future<List<FeedItemEntity>> loadFromStorage();

  Future<void> saveToStorage(List<FeedItemEntity> items);

  Future<FeedItemEntity?> fetchNewItem(String type);
}
