import 'package:movie_watchlist/core/domain/entities/media_item.dart';

String mediaDetailsPath(MediaItem item) {
  return mediaDetailsPathById(item.type, item.id);
}

String mediaDetailsPathById(String type, int id) {
  return '/details/$type/$id';
}

String mediaDetailsPathForObject(Object item) {
  if (item is MediaItem) {
    return mediaDetailsPath(item);
  }

  throw ArgumentError('Unsupported media item: ${item.runtimeType}');
}
