part of 'accessories_cubit.dart';

abstract class AccessoriesState extends Equatable {
  const AccessoriesState();

  @override
  List<Object> get props => [];
}

class AccessoriesInitial extends AccessoriesState {}

class AccessoriesLoading extends AccessoriesState {}

class AccessoriesLoaded extends AccessoriesState {
  final List<Data> accessories;
  final List<Data> allAccessories;

  const AccessoriesLoaded({required this.accessories, required this.allAccessories});

  @override
  List<Object> get props => [accessories, allAccessories];
}

class AccessoriesSearchResult extends AccessoriesState {
  final List<Data> accessories;
  final List<Data> allAccessories;
  final String searchQuery;

  const AccessoriesSearchResult({required this.accessories, required this.allAccessories, required this.searchQuery});

  @override
  List<Object> get props => [accessories, allAccessories, searchQuery];
}

class AccessoriesError extends AccessoriesState {
  final String message;

  const AccessoriesError({required this.message});

  @override
  List<Object> get props => [message];
}
