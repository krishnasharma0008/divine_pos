class FilterModelState {
  final bool isLoading;
  final List<String> categories;
  final List<String> subCategories;
  final List<String> collections;
  final Object? error;
  final String? errorMessage;

  const FilterModelState({
    this.isLoading = false,
    this.categories = const [],
    this.subCategories = const [],
    this.collections = const [],
    this.error,
    this.errorMessage,
  });

  FilterModelState copyWith({
    bool? isLoading,
    List<String>? categories,
    List<String>? subCategories,
    List<String>? collections,
    Object? error,
    String? errorMessage,
  }) {
    return FilterModelState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      collections: collections ?? this.collections,
      error: error,
      errorMessage: errorMessage,
    );
  }
}
