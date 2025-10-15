import 'dart:async';

import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/repository/contact_type_repository.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:equatable/equatable.dart';
part 'contact_type_state.dart';

class ContactTypeCubit extends Cubit<ContactTypeState> {
  final ContactTypeRepository contactTypeRepository;
  Timer? _searchTimer;
  String _lastSearchQuery = '';

  ContactTypeCubit({required this.contactTypeRepository}) : super(ContactTypeInitial());

  // Existing getBusinesses method remains the same
  Future<void> getBusinesses({required String userId, String? keyword, int? limit = 20, int? page = 1}) async {
    emit(ContactTypeLoading());

    try {
      debugPrint('🚀 [ContactTypeCubit] Fetching businesses for user: $userId');
      final businesses = await contactTypeRepository.getBusinessList(
        userId: storage.read('userId') ?? userId,
        keyword: keyword,
        limit: limit,
        page: page,
      );

      debugPrint('✅ [ContactTypeCubit] Successfully loaded ${businesses.length} businesses');
      emit(ContactTypeLoaded(businesses: businesses, allBusinesses: businesses));
    } on ContactTypeException catch (e) {
      debugPrint('❌ [ContactTypeCubit] ContactTypeException: ${e.message}');
      emit(ContactTypeError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeCubit] Unexpected error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ContactTypeError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  // NEW: Create Business Method
  Future<void> createBusiness({required Map<String, dynamic> payload}) async {
    emit(ContactTypeLoading());

    try {
      debugPrint('🚀 [ContactTypeCubit] Creating new business');
      final newBusiness = await contactTypeRepository.createBusiness(payload: payload);

      debugPrint('✅ [ContactTypeCubit] Business created successfully');

      // Add the new business to the current state if we're in a loaded state
      final currentState = state;
      if (currentState is ContactTypeLoaded) {
        final updatedBusinesses = List<Customersorsuppliers>.from(currentState.allBusinesses)..add(newBusiness);
        emit(ContactTypeLoaded(businesses: updatedBusinesses, allBusinesses: updatedBusinesses));
      } else if (currentState is ContactTypeSearchResult) {
        final updatedAllBusinesses = List<Customersorsuppliers>.from(currentState.allBusinesses)..add(newBusiness);

        // Also update the filtered list if the new business matches the search query
        final filteredBusinesses = _filterBusinessesByQuery(updatedAllBusinesses, currentState.searchQuery);

        emit(
          ContactTypeSearchResult(
            businesses: filteredBusinesses,
            allBusinesses: updatedAllBusinesses,
            searchQuery: currentState.searchQuery,
          ),
        );
      } else {
        // If not in a loaded state, just emit success without updating the list
        emit(ContactTypeSuccess(message: 'Business created successfully'));

        // Optionally, you can reload the businesses list after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          final userId = payload['customerDetail']['userId'];
          if (userId != null) {
            getBusinesses(userId: userId);
          }
        });
      }
    } on ContactTypeException catch (e) {
      debugPrint('❌ [ContactTypeCubit] ContactTypeException during business creation: ${e.message}');
      emit(ContactTypeError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint('💥 [ContactTypeCubit] Unexpected error during business creation: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      emit(ContactTypeError(message: 'Failed to create business: ${e.toString()}'));
    }
  }

  // Helper method to filter businesses by search query
  List<Customersorsuppliers> _filterBusinessesByQuery(List<Customersorsuppliers> businesses, String query) {
    if (query.isEmpty) return businesses;

    return businesses.where((business) {
      final name = '${business.firstName ?? ''} ${business.lastName ?? ''}'.trim().toLowerCase();
      final organization = business.organization?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          organization.contains(searchQuery) ||
          (business.customerNumber?.toLowerCase() ?? '').contains(searchQuery);
    }).toList();
  }

  // Helper method to create payload for business creation
  Map<String, dynamic> createBusinessPayload({
    required String type,
    required String type2,
    String? firstName,
    String? lastName,
    required String organization,
    String? position,
    required String userId,
    required String location,
    List<Map<String, dynamic>>? telephones,
    List<Map<String, dynamic>>? emails,
  }) {
    return {
      "customerDetail": {
        "type": type,
        "type2": type2,
        "customerNumber": null,
        "firstName": firstName,
        "lastName": lastName,
        "organization": organization,
        "position": position,
        "userId": userId,
        "location": location,
      },
      "customerContactDetail": {},
      "customerTelephone": telephones ?? [],
      "customerEmail": emails ?? [],
    };
  }

  // Example usage of createBusinessPayload:
  //
  // final payload = createBusinessPayload(
  //   type: "Business",
  //   type2: "business",
  //   firstName: "John",
  //   lastName: "Doe",
  //   organization: "ABC Corp",
  //   position: "Manager",
  //   userId: "64106cddcfcedd360d7096cc",
  //   location: "66d99ac61eb5f6623aa07801",
  //   telephones: [
  //     {
  //       "number": "456464",
  //       "phone_prefix": "+213",
  //       "type": "Private"
  //     }
  //   ],
  //   emails: [
  //     {
  //       "email": "john.doe@abccorp.com",
  //       "type": "Private"
  //     }
  //   ],
  // );

  // Existing methods remain the same...
  Future<void> searchBusinessesApi({
    required String userId,
    required String query,
    int? limit = 20,
    int? page = 1,
  }) async {
    _searchTimer?.cancel();

    if (query.isEmpty) {
      await getBusinesses(userId: userId);
      return;
    }

    _searchTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_lastSearchQuery == query) return;
      _lastSearchQuery = query;

      emit(ContactTypeLoading());

      try {
        debugPrint('🔍 [ContactTypeCubit] Searching businesses with query: $query');
        final businesses = await contactTypeRepository.getBusinessList(
          userId: storage.read('userId') ?? userId,
          keyword: query,
          limit: limit,
          page: page,
        );

        debugPrint('✅ [ContactTypeCubit] Search completed, found ${businesses.length} businesses');
        emit(ContactTypeSearchResult(businesses: businesses, allBusinesses: businesses, searchQuery: query));
      } on ContactTypeException catch (e) {
        debugPrint('❌ [ContactTypeCubit] ContactTypeException during search: ${e.message}');
        emit(ContactTypeError(message: e.message));
      } catch (e, stackTrace) {
        debugPrint('💥 [ContactTypeCubit] Unexpected error during search: $e');
        debugPrint('📋 Stack trace: $stackTrace');
        emit(ContactTypeError(message: 'Search failed: ${e.toString()}'));
      }
    });
  }

  void searchBusinessesLocal(String query) {
    final currentState = state;
    if (currentState is ContactTypeLoaded) {
      if (query.isEmpty) {
        emit(ContactTypeLoaded(businesses: currentState.allBusinesses, allBusinesses: currentState.allBusinesses));
      } else {
        final filteredBusinesses = currentState.allBusinesses.where((business) {
          final name = '${business.firstName ?? ''} ${business.lastName ?? ''}'.trim().toLowerCase();
          final organization = business.organization?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              organization.contains(searchQuery) ||
              (business.customerNumber?.toLowerCase() ?? '').contains(searchQuery);
        }).toList();

        emit(
          ContactTypeSearchResult(
            businesses: filteredBusinesses,
            allBusinesses: currentState.allBusinesses,
            searchQuery: query,
          ),
        );
      }
    }
  }

  void clearBusinesses() {
    _searchTimer?.cancel();
    emit(ContactTypeInitial());
  }

  void refreshBusinesses({required String userId}) async {
    await getBusinesses(userId: userId);
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is ContactTypeSearchResult) {
      emit(ContactTypeLoaded(businesses: currentState.allBusinesses, allBusinesses: currentState.allBusinesses));
    }
  }

  Customersorsuppliers? getBusinessById(String businessId) {
    final currentState = state;
    if (currentState is ContactTypeLoaded || currentState is ContactTypeSearchResult) {
      final businesses = currentState is ContactTypeLoaded
          ? currentState.allBusinesses
          : (currentState as ContactTypeSearchResult).allBusinesses;

      return businesses.firstWhere((business) => business.sId == businessId, orElse: () => Customersorsuppliers());
    }
    return null;
  }

  String? getPrimaryPhoneNumber(Customersorsuppliers business) {
    final contactDetail = business.customerContactDetail?.firstOrNull;
    if (contactDetail != null && contactDetail.customerTelephones != null) {
      final primaryPhone = contactDetail.customerTelephones!.firstWhere(
        (phone) => phone.isPrimary == true,
        orElse: () => contactDetail.customerTelephones!.firstOrNull ?? CustomerTelephones(),
      );
      return primaryPhone.number != null ? '${primaryPhone.phonePrefix ?? ''}${primaryPhone.number}' : null;
    }
    return null;
  }

  String? getPrimaryEmail(Customersorsuppliers business) {
    final contactDetail = business.customerContactDetail?.firstOrNull;
    if (contactDetail != null && contactDetail.customerEmails != null) {
      final primaryEmail = contactDetail.customerEmails!.firstWhere(
        (email) => email.isPrimary == true,
        orElse: () => contactDetail.customerEmails!.firstOrNull ?? CustomerEmails(),
      );
      return primaryEmail.email;
    }
    return null;
  }

  ShippingAddresses? getPrimaryShippingAddress(Customersorsuppliers business) {
    if (business.shippingAddresses != null) {
      return business.shippingAddresses!.firstWhere(
        (address) => address.primary == true,
        orElse: () => business.shippingAddresses!.firstOrNull ?? ShippingAddresses(),
      );
    }
    return null;
  }

  BillingAddresses? getPrimaryBillingAddress(Customersorsuppliers business) {
    if (business.billingAddresses != null) {
      return business.billingAddresses!.firstWhere(
        (address) => address.primary == true,
        orElse: () => business.billingAddresses!.firstOrNull ?? BillingAddresses(),
      );
    }
    return null;
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
