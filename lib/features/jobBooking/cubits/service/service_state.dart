part of 'service_cubit.dart';

abstract class ServiceState {
  const ServiceState();
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final ServiceResponseModel servicesResponse;
  final String searchQuery;

  const ServiceLoaded({
    required this.servicesResponse,
    required this.searchQuery,
  });
}

class ServiceNoResults extends ServiceState {
  final String searchQuery;

  const ServiceNoResults({required this.searchQuery});
}

class ServiceError extends ServiceState {
  final String message;
  final String searchQuery;

  const ServiceError({required this.message, required this.searchQuery});
}
