import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/repository/service_repository.dart';
import 'package:repair_cms/features/jobBooking/models/service_response_model.dart';
part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository serviceRepository;

  ServiceCubit({required this.serviceRepository}) : super(ServiceInitial());

  // Search services with keyword
  Future<void> searchServices({
    String keyword = '',
    String manufacturer = '1',
    String model = '1',
    bool ase = false,
    String name = '-1',
  }) async {
    // If keyword is empty, show initial state
    if (keyword.isEmpty) {
      emit(ServiceInitial());
      return;
    }

    emit(ServiceLoading());

    try {
      final servicesResponse = await serviceRepository.getServicesList(
        keyword: keyword,
        manufacturer: manufacturer,
        model: model,
        ase: ase,
        name: name,
      );

      if (servicesResponse.services.isEmpty) {
        emit(ServiceNoResults(searchQuery: keyword));
      } else {
        emit(ServiceLoaded(servicesResponse: servicesResponse, searchQuery: keyword));
      }
    } on ServiceException catch (e) {
      emit(ServiceError(message: e.message, searchQuery: keyword));
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      throw Exception('Unexpected error: $e');
    }
  }

  // Clear search
  void clearSearch() {
    emit(ServiceInitial());
  }

  // Refresh current search
  Future<void> refreshSearch() async {
    if (state is ServiceLoaded) {
      await searchServices(keyword: '');
    }
  }
}
