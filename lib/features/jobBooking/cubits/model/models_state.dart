part of 'models_cubit.dart';

abstract class ModelsState extends Equatable {
  const ModelsState();

  @override
  List<Object> get props => [];
}

class ModelsInitial extends ModelsState {}

class ModelsLoading extends ModelsState {}

class ModelsLoaded extends ModelsState {
  final List<ModelsModel> models;
  final List<ModelsModel> allModels;

  const ModelsLoaded({required this.models, required this.allModels});

  @override
  List<Object> get props => [models, allModels];
}

class ModelsSearchResult extends ModelsState {
  final List<ModelsModel> models;
  final List<ModelsModel> allModels;
  final String searchQuery;

  const ModelsSearchResult({
    required this.models,
    required this.allModels,
    required this.searchQuery,
  });

  @override
  List<Object> get props => [models, allModels, searchQuery];
}

class ModelsError extends ModelsState {
  final String message;

  const ModelsError({required this.message});

  @override
  List<Object> get props => [message];
}
