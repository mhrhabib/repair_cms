part of 'contact_type_cubit.dart';

abstract class ContactTypeState extends Equatable {
  const ContactTypeState();

  @override
  List<Object> get props => [];
}

class ContactTypeInitial extends ContactTypeState {}

class ContactTypeLoading extends ContactTypeState {}

class ContactTypeLoaded extends ContactTypeState {
  final List<Customersorsuppliers> businesses;
  final List<Customersorsuppliers> allBusinesses;

  const ContactTypeLoaded({required this.businesses, required this.allBusinesses});

  @override
  List<Object> get props => [businesses, allBusinesses];
}

class ContactTypeSearchResult extends ContactTypeState {
  final List<Customersorsuppliers> businesses;
  final List<Customersorsuppliers> allBusinesses;
  final String searchQuery;

  const ContactTypeSearchResult({required this.businesses, required this.allBusinesses, required this.searchQuery});

  @override
  List<Object> get props => [businesses, allBusinesses, searchQuery];
}

// NEW: Success state for create business
class ContactTypeSuccess extends ContactTypeState {
  final String message;

  const ContactTypeSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ContactTypeError extends ContactTypeState {
  final String message;

  const ContactTypeError({required this.message});

  @override
  List<Object> get props => [message];
}
