import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/repository/brand_repository.dart';
import 'package:repair_cms/features/jobBooking/models/brand_model.dart';
part 'brand_state.dart';

class BrandCubit extends Cubit<BrandState> {
  final BrandRepository brandRepository;

  BrandCubit({required this.brandRepository}) : super(BrandInitial());

  Future<void> getBrands({required String userId}) async {
    emit(BrandLoading());

    try {
      debugPrint('🚀 [BrandCubit] Fetching brands for user: $userId');
      final brands = await brandRepository.getBrandsList(userId: userId);

      debugPrint('✅ [BrandCubit] Successfully loaded ${brands.length} brands');
      emit(BrandLoaded(brands: brands));
    } on BrandException catch (e) {
      debugPrint('❌ [BrandCubit] BrandException: ${e.message}');
      emit(BrandError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [BrandCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(BrandError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  void clearBrands() {
    emit(BrandInitial());
  }

  void refreshBrands({required String userId}) async {
    await getBrands(userId: userId);
  }

  // Search brands by name
  void searchBrands(String query) {
    final currentState = state;
    if (currentState is BrandLoaded) {
      if (query.isEmpty) {
        emit(BrandLoaded(brands: currentState.allBrands));
      } else {
        final filteredBrands = currentState.allBrands.where((brand) {
          return brand.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        }).toList();

        emit(BrandSearchResult(brands: filteredBrands, allBrands: currentState.allBrands, searchQuery: query));
      }
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is BrandSearchResult) {
      emit(BrandLoaded(brands: currentState.allBrands));
    }
  }
}
