import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/models/accessories_model.dart';
import 'package:repair_cms/features/jobBooking/repository/accessories_repository.dart';
import 'package:equatable/equatable.dart';
part 'accessories_state.dart';

class AccessoriesCubit extends Cubit<AccessoriesState> {
  final AccessoriesRepository accessoriesRepository;

  AccessoriesCubit({required this.accessoriesRepository}) : super(AccessoriesInitial());

  Future<void> getAccessories({required String userId}) async {
    emit(AccessoriesLoading());

    try {
      debugPrint('🚀 [AccessoriesCubit] Fetching accessories for user: $userId');
      final accessories = await accessoriesRepository.getAccessoriesList(userId: userId);

      debugPrint('✅ [AccessoriesCubit] Successfully loaded ${accessories.length} accessories');
      emit(AccessoriesLoaded(accessories: accessories, allAccessories: accessories));
    } on AccessoriesException catch (e) {
      debugPrint('❌ [AccessoriesCubit] AccessoriesException: ${e.message}');
      emit(AccessoriesError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [AccessoriesCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(AccessoriesError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  void clearAccessories() {
    emit(AccessoriesInitial());
  }

  void refreshAccessories({required String userId}) async {
    await getAccessories(userId: userId);
  }

  // Search accessories by label
  void searchAccessories(String query) {
    final currentState = state;
    if (currentState is AccessoriesLoaded) {
      if (query.isEmpty) {
        emit(AccessoriesLoaded(accessories: currentState.allAccessories, allAccessories: currentState.allAccessories));
      } else {
        final filteredAccessories = currentState.allAccessories.where((accessory) {
          return accessory.label?.toLowerCase().contains(query.toLowerCase()) ?? false;
        }).toList();

        emit(
          AccessoriesSearchResult(
            accessories: filteredAccessories,
            allAccessories: currentState.allAccessories,
            searchQuery: query,
          ),
        );
      }
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is AccessoriesSearchResult) {
      emit(AccessoriesLoaded(accessories: currentState.allAccessories, allAccessories: currentState.allAccessories));
    }
  }

  // Create new accessory
  Future<void> createAccessory({required String value, required String label, required String userId}) async {
    try {
      debugPrint('🚀 [AccessoriesCubit] Creating new accessory: $label');
      final newAccessory = await accessoriesRepository.createAccessory(value: value, label: label, userId: userId);

      debugPrint('✅ [AccessoriesCubit] Accessory created successfully');

      // Refresh the accessories list to include the new accessory
      await getAccessories(userId: userId);
    } on AccessoriesException catch (e) {
      debugPrint('❌ [AccessoriesCubit] AccessoriesException while creating: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('💥 [AccessoriesCubit] Unexpected error while creating accessory: $e');
      rethrow;
    }
  }

  // Get accessory by ID
  Data? getAccessoryById(String accessoryId) {
    final currentState = state;
    if (currentState is AccessoriesLoaded) {
      return currentState.allAccessories.firstWhere((accessory) => accessory.sId == accessoryId, orElse: () => Data());
    }
    return null;
  }
}
