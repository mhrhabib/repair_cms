import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/repository/models_repository.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';
import 'package:equatable/equatable.dart';
part 'models_state.dart';

class ModelsCubit extends Cubit<ModelsState> {
  final ModelsRepository modelsRepository;

  ModelsCubit({required this.modelsRepository}) : super(ModelsInitial());

  Future<void> getModels({required String brandId}) async {
    emit(ModelsLoading());

    try {
      debugPrint('🚀 [ModelsCubit] Fetching models for brand: $brandId');
      final models = await modelsRepository.getModelsList(brandId: brandId);

      debugPrint('✅ [ModelsCubit] Successfully loaded ${models.length} models');
      emit(ModelsLoaded(models: models, allModels: models));
    } on ModelsException catch (e) {
      debugPrint('❌ [ModelsCubit] ModelsException: ${e.message}');
      emit(ModelsError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [ModelsCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ModelsError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> createModel({required String name, required String userId, required String brandId}) async {
    try {
      debugPrint('🚀 [ModelsCubit] Creating new model: $name');
      final newModel = await modelsRepository.createModel(name: name, userId: userId, brandId: brandId);

      debugPrint('✅ [ModelsCubit] Model created successfully');

      // Refresh the models list to include the new model
      await getModels(brandId: brandId);
    } on ModelsException catch (e) {
      debugPrint('❌ [ModelsCubit] ModelsException while creating: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('💥 [ModelsCubit] Unexpected error while creating model: $e');
      rethrow;
    }
  }

  void clearModels() {
    emit(ModelsInitial());
  }

  void refreshModels({required String brandId}) async {
    await getModels(brandId: brandId);
  }

  // Search models by name
  void searchModels(String query) {
    final currentState = state;
    if (currentState is ModelsLoaded) {
      if (query.isEmpty) {
        emit(ModelsLoaded(models: currentState.allModels, allModels: currentState.allModels));
      } else {
        final filteredModels = currentState.allModels.where((model) {
          return model.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
        }).toList();

        emit(ModelsSearchResult(models: filteredModels, allModels: currentState.allModels, searchQuery: query));
      }
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is ModelsSearchResult) {
      emit(ModelsLoaded(models: currentState.allModels, allModels: currentState.allModels));
    }
  }

  // Get model by ID
  ModelsModel? getModelById(String modelId) {
    final currentState = state;
    if (currentState is ModelsLoaded) {
      return currentState.allModels.firstWhere((model) => model.sId == modelId, orElse: () => ModelsModel());
    }
    return null;
  }
}
