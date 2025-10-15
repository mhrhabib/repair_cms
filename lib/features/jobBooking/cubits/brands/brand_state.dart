part of 'brand_cubit.dart';

abstract class BrandState {
  const BrandState();
}

class BrandInitial extends BrandState {}

class BrandLoading extends BrandState {}

class BrandLoaded extends BrandState {
  final List<BrandModel> brands;
  final List<BrandModel> allBrands; // Keep original list for search

  const BrandLoaded({required this.brands}) : allBrands = brands;

  BrandLoaded copyWith({List<BrandModel>? brands}) {
    return BrandLoaded(brands: brands ?? this.brands);
  }
}

class BrandSearchResult extends BrandState {
  final List<BrandModel> brands;
  final List<BrandModel> allBrands;
  final String searchQuery;

  const BrandSearchResult({required this.brands, required this.allBrands, required this.searchQuery});
}

class BrandError extends BrandState {
  final String message;

  const BrandError({required this.message});
}
