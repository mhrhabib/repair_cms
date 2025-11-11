import 'dart:async';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/repository/contact_type_repository.dart';

import 'package:equatable/equatable.dart';
part 'contact_type_state.dart';

class ContactTypeCubit extends Cubit<ContactTypeState> {
  final ContactTypeRepository contactTypeRepository;
  Timer? _searchTimer;

  ContactTypeCubit({required this.contactTypeRepository})
    : super(ContactTypeInitial());

  // Generalized method to search for both Business and Personal profiles
  Future<void> searchProfilesApi({
    required String userId,
    required String query,
    required String type2, // "business" or "personal"
    int limit = 10,
  }) async {
    emit(ContactTypeLoading());
    try {
      debugPrint(
        '🔍 [ContactTypeCubit] Searching for $type2 profiles with query: "$query"',
      );
      final profiles = await contactTypeRepository.getProfileList(
        userId: storage.read('userId') ?? userId,
        keyword: query,
        type2: type2,
        limit: limit,
      );
      debugPrint(
        '✅ [ContactTypeCubit] Search completed, found ${profiles.length} profiles',
      );
      emit(
        ContactTypeSearchResult(
          businesses: profiles,
          searchQuery: query,
          allBusinesses: [],
        ),
      );
    } on ContactTypeException catch (e) {
      debugPrint(
        '❌ [ContactTypeCubit] ContactTypeException during search: ${e.message}',
      );
      emit(ContactTypeError(message: e.message));
    } catch (e, stackTrace) {
      debugPrint(
        '💥 [ContactTypeCubit] Unexpected error during search: $e\n$stackTrace',
      );
      emit(ContactTypeError(message: 'Search failed: ${e.toString()}'));
    }
  }

  // Create new profile
  Future<Customersorsuppliers?> createBusiness({
    required Map<String, dynamic> payload,
  }) async {
    emit(ContactTypeLoading());
    try {
      debugPrint('🚀 [ContactTypeCubit] Creating new profile');
      final newBusiness = await contactTypeRepository.createBusiness(
        payload: payload,
      );
      debugPrint('✅ [ContactTypeCubit] Profile created successfully');
      emit(ContactTypeSuccess(message: 'Profile created successfully'));
      return newBusiness;
    } on ContactTypeException catch (e) {
      debugPrint(
        '❌ [ContactTypeCubit] ContactTypeException during creation: ${e.message}',
      );
      emit(ContactTypeError(message: e.message));
      return null;
    } catch (e, stackTrace) {
      debugPrint(
        '💥 [ContactTypeCubit] Unexpected error during creation: $e\n$stackTrace',
      );
      emit(
        ContactTypeError(message: 'Failed to create profile: ${e.toString()}'),
      );
      return null;
    }
  }

  // Update existing profile
  Future<Customersorsuppliers?> updateBusiness({
    required String profileId,
    required Map<String, dynamic> payload,
  }) async {
    emit(ContactTypeLoading());
    try {
      debugPrint('🚀 [ContactTypeCubit] Updating profile with ID: $profileId');
      final updatedBusiness = await contactTypeRepository.updateBusiness(
        profileId: profileId,
        payload: payload,
      );
      debugPrint('✅ [ContactTypeCubit] Profile updated successfully');
      emit(ContactTypeSuccess(message: 'Profile updated successfully'));
      return updatedBusiness;
    } on ContactTypeException catch (e) {
      debugPrint(
        '❌ [ContactTypeCubit] ContactTypeException during update: ${e.message}',
      );
      emit(ContactTypeError(message: e.message));
      return null;
    } catch (e, stackTrace) {
      debugPrint(
        '💥 [ContactTypeCubit] Unexpected error during update: $e\n$stackTrace',
      );
      emit(
        ContactTypeError(message: 'Failed to update profile: ${e.toString()}'),
      );
      return null;
    }
  }

  // Helper method to create payload for business creation/update
  Map<String, dynamic> createBusinessPayload({
    required String type,
    required String type2,
    String? firstName,
    String? lastName,
    String? organization,
    String? position,
    required String userId,
    String? location,
    List<Map<String, dynamic>>? telephones,
    List<Map<String, dynamic>>? emails,
    List<Map<String, dynamic>>? billingAddresses,
    List<Map<String, dynamic>>? shippingAddresses,
  }) {
    return {
      "customerDetail": {
        "type": type,
        "type2": type2,
        "firstName": firstName,
        "lastName": lastName,
        "organization": organization,
        "position": position ?? "Customer",
        "userId": userId,
        "location": location,
      },
      "customerContactDetail": {},
      "customerBillingAddress": billingAddresses ?? [],
      "customerShippingAddress": shippingAddresses ?? [],
      "customerTelephone": telephones ?? [],
      "customerEmail": emails ?? [],
    };
  }

  // Helper method to create address payload for update
  Map<String, dynamic> createAddressPayload({
    required String street,
    required String no,
    required String zip,
    required String city,
    required String country,
    String? state,
    bool primary = true,
  }) {
    return {
      "street": street,
      "no": no,
      "zip": zip,
      "city": city,
      "country": country,
      "state": state ?? city,
      "primary": primary,
    };
  }

  // Helper method to create contact data for job booking
  Map<String, dynamic> getContactDataForJobBooking(
    Customersorsuppliers contact,
  ) {
    final primaryBillingAddress = contact.billingAddresses?.firstWhere(
      (address) => address.primary == true,
      orElse: () => contact.billingAddresses?.first ?? BillingAddresses(),
    );

    final primaryShippingAddress = contact.shippingAddresses?.firstWhere(
      (address) => address.primary == true,
      orElse: () => contact.shippingAddresses?.first ?? ShippingAddresses(),
    );

    final primaryPhone = contact.customerContactDetail?.first.customerTelephones
        ?.firstWhere(
          (phone) => phone.isPrimary == true,
          orElse: () =>
              contact.customerContactDetail?.first.customerTelephones?.first ??
              CustomerTelephones(),
        );

    final primaryEmail = contact.customerContactDetail?.first.customerEmails
        ?.firstWhere(
          (email) => email.isPrimary == true,
          orElse: () =>
              contact.customerContactDetail?.first.customerEmails?.first ??
              CustomerEmails(),
        );

    return {
      'customerId': contact.sId,
      'type': contact.type,
      'type2': contact.type2,
      'organization': contact.organization,
      'customerNo': contact.customerNumber?.toString(),
      'email': primaryEmail?.email,
      'telephone': primaryPhone?.number,
      'telephone_prefix': primaryPhone?.phonePrefix,
      'shipping_address': primaryShippingAddress != null
          ? {
              'street': primaryShippingAddress.street,
              'no': primaryShippingAddress.iV,
              'zip': primaryShippingAddress.zip,
              'city': primaryShippingAddress.city,
              'country': primaryShippingAddress.country,
            }
          : null,
      'billing_address': primaryBillingAddress != null
          ? {
              'street': primaryBillingAddress.street,
              'no': primaryBillingAddress.iV,
              'zip': primaryBillingAddress.zip,
              'city': primaryBillingAddress.city,
              'state': primaryBillingAddress.city,
              'country': primaryBillingAddress.country,
            }
          : null,
      'firstName': contact.firstName,
      'lastName': contact.lastName,
      'position': contact.position,
      'vatNo': contact.customerBankDetails?.first.vatNo ?? '',
      'reverseCharge':
          contact.customerBankDetails?.first.reverseCharge ?? false,
    };
  }

  // Helper methods to extract primary contact info
  String? getPrimaryPhoneNumber(Customersorsuppliers business) {
    if (business.customerContactDetail?.isNotEmpty ?? false) {
      final contactDetail = business.customerContactDetail!.first;
      if (contactDetail.customerTelephones?.isNotEmpty ?? false) {
        final primaryPhone = contactDetail.customerTelephones!.firstWhere(
          (phone) => phone.isPrimary == true,
          orElse: () => contactDetail.customerTelephones!.first,
        );
        return '${primaryPhone.phonePrefix ?? ''}${primaryPhone.number ?? ''}';
      }
    }
    return null;
  }

  String? getPrimaryEmail(Customersorsuppliers business) {
    if (business.customerContactDetail?.isNotEmpty ?? false) {
      final contactDetail = business.customerContactDetail!.first;
      if (contactDetail.customerEmails?.isNotEmpty ?? false) {
        final primaryEmail = contactDetail.customerEmails!.firstWhere(
          (email) => email.isPrimary == true,
          orElse: () => contactDetail.customerEmails!.first,
        );
        return primaryEmail.email;
      }
    }
    return null;
  }

  ShippingAddresses? getPrimaryShippingAddress(Customersorsuppliers business) {
    if (business.shippingAddresses?.isNotEmpty ?? false) {
      return business.shippingAddresses!.firstWhere(
        (address) => address.primary == true,
        orElse: () => business.shippingAddresses!.first,
      );
    }
    return null;
  }

  BillingAddresses? getPrimaryBillingAddress(Customersorsuppliers business) {
    if (business.billingAddresses?.isNotEmpty ?? false) {
      return business.billingAddresses!.firstWhere(
        (address) => address.primary == true,
        orElse: () => business.billingAddresses!.first,
      );
    }
    return null;
  }

  // Check if profile has empty address fields
  bool hasEmptyAddressFields(Customersorsuppliers profile) {
    final shippingAddress = getPrimaryShippingAddress(profile);
    final billingAddress = getPrimaryBillingAddress(profile);

    // Check if either address is missing or has empty fields
    final hasIncompleteShipping =
        shippingAddress == null ||
        shippingAddress.street?.isEmpty == true ||
        shippingAddress.iV?.toString().isEmpty == true ||
        shippingAddress.zip?.isEmpty == true ||
        shippingAddress.city?.isEmpty == true;

    final hasIncompleteBilling =
        billingAddress == null ||
        billingAddress.street?.isEmpty == true ||
        billingAddress.iV?.toString().isEmpty == true ||
        billingAddress.zip?.isEmpty == true ||
        billingAddress.city?.isEmpty == true;

    return hasIncompleteShipping || hasIncompleteBilling;
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
