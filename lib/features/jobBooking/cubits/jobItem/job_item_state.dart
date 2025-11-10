// features/jobBooking/cubits/item/item_state.dart
part of 'job_item_cubit.dart';

abstract class JobItemState {
  final String searchQuery;

  const JobItemState({this.searchQuery = ''});
}

class JobItemInitial extends JobItemState {
  const JobItemInitial() : super(searchQuery: '');
}

class JobItemLoading extends JobItemState {
  const JobItemLoading({required super.searchQuery});
}

class JobItemLoaded extends JobItemState {
  final JobItemsModel itemsResponse;

  const JobItemLoaded({required this.itemsResponse, required super.searchQuery});
}

class JobItemNoResults extends JobItemState {
  const JobItemNoResults({required super.searchQuery});
}

class JobItemError extends JobItemState {
  final String message;

  const JobItemError({required this.message, required super.searchQuery});
}
