// features/jobBooking/cubits/item/item_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/jobBooking/models/job_item_model.dart';
import 'package:repair_cms/features/jobBooking/repository/job_item_repository.dart';
part 'job_item_state.dart';

class JobItemCubit extends Cubit<JobItemState> {
  final JobItemRepository itemRepository;

  JobItemCubit(this.itemRepository) : super(JobItemInitial());

  String _currentSearchQuery = '';
  String get currentSearchQuery => _currentSearchQuery;

  Future<void> searchItems({required String userId, required String keyword, int page = 1, int limit = 20}) async {
    if (keyword.isEmpty) {
      emit(JobItemNoResults(searchQuery: keyword));
      return;
    }

    emit(JobItemLoading(searchQuery: keyword));
    _currentSearchQuery = keyword;

    try {
      final itemsModel = await itemRepository.searchItems(userId: userId, keyword: keyword, page: page, limit: limit);

      if (itemsModel.items == null || itemsModel.items!.isEmpty) {
        emit(JobItemNoResults(searchQuery: keyword));
      } else {
        emit(JobItemLoaded(itemsResponse: itemsModel, searchQuery: keyword));
      }
    } catch (e) {
      emit(JobItemError(message: e.toString(), searchQuery: keyword));
    }
  }

  void clearSearch() {
    _currentSearchQuery = '';
    emit(JobItemInitial());
  }

  void refreshSearch({required String userId}) {
    if (_currentSearchQuery.isNotEmpty) {
      searchItems(userId: userId, keyword: _currentSearchQuery);
    }
  }
}
