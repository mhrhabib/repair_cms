part of 'company_cubit.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final CompanyModel company;

  CompanyLoaded({required this.company});
}

class CompanyError extends CompanyState {
  final String message;

  CompanyError({required this.message});
}
