enum SearchResultType { restaurant, dish }

class SearchResult {
  final String id;
  final SearchResultType type;
  final String name;
  final String subtitle;
  final String price;
  final String deliveryTime;
  final List<String> tags;
  final String? restaurantId;

  const SearchResult({
    required this.id,
    required this.type,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.deliveryTime,
    required this.tags,
    this.restaurantId,
  });
}
