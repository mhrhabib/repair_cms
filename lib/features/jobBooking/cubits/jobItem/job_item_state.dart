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
  const JobItemLoading({required String searchQuery}) : super(searchQuery: searchQuery);
}

class JobItemLoaded extends JobItemState {
  final JobItemsModel itemsResponse;

  const JobItemLoaded({required this.itemsResponse, required String searchQuery}) : super(searchQuery: searchQuery);
}

class JobItemNoResults extends JobItemState {
  const JobItemNoResults({required String searchQuery}) : super(searchQuery: searchQuery);
}

class JobItemError extends JobItemState {
  final String message;

  const JobItemError({required this.message, required String searchQuery}) : super(searchQuery: searchQuery);
}
