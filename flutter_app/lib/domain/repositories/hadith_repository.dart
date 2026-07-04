import '../entities/hadith_entity.dart';

abstract class HadithRepository {
  List<HadithEntity> getAll();

  List<HadithEntity> getByBook(String book);

  List<HadithEntity> search(String query, {String? book});
}
