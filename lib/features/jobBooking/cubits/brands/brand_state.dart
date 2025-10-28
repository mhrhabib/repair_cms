part of 'brand_cubit.dart';

abstract class BrandState {}

class BrandInitial extends BrandState {}

class BrandLoading extends BrandState {}

class BrandLoaded extends BrandState {
  final List<BrandModel> brands;

  BrandLoaded({required this.brands});

  List<BrandModel> get allBrands => brands;
}

class BrandError extends BrandState {
  final String message;

  BrandError({required this.message});
}

class BrandSearchResult extends BrandState {
  final List<BrandModel> brands;
  final List<BrandModel> allBrands;
  final String searchQuery;

  BrandSearchResult({required this.brands, required this.allBrands, required this.searchQuery});
}

class BrandAdding extends BrandState {}

class BrandAdded extends BrandState {
  final BrandModel brand;
  final List<BrandModel> brands;

  BrandAdded({required this.brand, required this.brands});
}

class BrandAddError extends BrandState {
  final String message;

  BrandAddError({required this.message});
}
