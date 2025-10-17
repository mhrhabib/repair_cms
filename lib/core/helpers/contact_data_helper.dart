// utils/contact_data_helper.dart
class ContactDataHelper {
  static Map<String, dynamic> getContactDataForJobContact(
    Map<String, dynamic> contactData, {
    String option = 'select',
  }) {
    // Extract primary addresses
    final primaryBillingAddress = (contactData['billing_addresses'] as List?)
        ?.where((address) => address['primary'] == true)
        .toList();

    final billingAddresses = (primaryBillingAddress?.isNotEmpty ?? false)
        ? primaryBillingAddress
        : [contactData['billing_addresses']?.first];

    final primaryShippingAddress = (contactData['shipping_addresses'] as List?)
        ?.where((address) => address['primary'] == true)
        .toList();

    final shippingAddresses = (primaryShippingAddress?.isNotEmpty ?? false)
        ? primaryShippingAddress
        : [contactData['shipping_addresses']?.first];

    // Extract contact details
    final customerContactDetail = contactData['CustomerContactDetail']?.first ?? {};
    final customerEmails = customerContactDetail['CustomerEmails'] ?? [];
    final customerTelephones = customerContactDetail['customer_telephones'] ?? [];

    // Business data structure
    final selectBusinessData = {
      'customerId': contactData['_id'],
      'type': contactData['type'],
      'type2': contactData['type2'],
      'organization': contactData['organization'],
      'customerNo': contactData['customerNumber'],
      'email': customerEmails.isNotEmpty ? customerEmails.first['email'] : '',
      'telephone': customerTelephones.isNotEmpty ? customerTelephones.first['number'] : '',
      'telephone_prefix': customerTelephones.isNotEmpty ? customerTelephones.first['phone_prefix'] : '',
      'shipping_address': shippingAddresses?.isNotEmpty == true ? shippingAddresses!.first : {},
      'billing_address': billingAddresses?.isNotEmpty == true ? billingAddresses!.first : {},
      'salutation': contactData['salutation'] ?? '',
      'firstName': contactData['firstName'],
      'lastName': contactData['lastName'],
      'position': contactData['position'],
      'vatNo': contactData['customer_bank_details']?.first?['vatNo'] ?? "",
      'reverseCharge': contactData['customer_bank_details']?.first?['reverseCharge'] ?? false,
      'contact_persons': [
        {
          'salutation': contactData['salutation'] ?? '',
          'firstName': contactData['firstName'],
          'lastName': contactData['lastName'],
          'position': contactData['position'],
          'email': '',
          'telephone': '',
        },
      ],
    };

    // Personal data structure
    final selectPersonalData = {
      'customerId': contactData['_id'],
      'type': contactData['type'],
      'type2': contactData['type2'],
      'organization': contactData['organization'],
      'customerNo': contactData['customerNumber'],
      'email': customerEmails.isNotEmpty ? customerEmails.first['email'] : '',
      'telephone': customerTelephones.isNotEmpty ? customerTelephones.first['number'] : '',
      'telephone_prefix': customerTelephones.isNotEmpty ? customerTelephones.first['phone_prefix'] : '',
      'shipping_address': shippingAddresses?.isNotEmpty == true ? shippingAddresses!.first : {},
      'billing_address': billingAddresses?.isNotEmpty == true ? billingAddresses!.first : {},
      'salutation': contactData['salutation'] ?? '',
      'firstName': contactData['firstName'],
      'lastName': contactData['lastName'],
      'position': contactData['position'],
      'vatNo': contactData['customer_bank_details']?.first?['vatNo'] ?? "",
      'reverseCharge': contactData['customer_bank_details']?.first?['reverseCharge'] ?? false,
    };

    return option == 'select' ? selectBusinessData : selectPersonalData;
  }

  static Map<String, dynamic> getContactDataToNewContact(Map<String, dynamic> contact) {
    final customerContactDetail = contact['customer_contact_detail']?.first ?? {};
    final customerEmails = customerContactDetail['customer_emails'] ?? [];
    final customerTelephones = customerContactDetail['customer_telephones'] ?? [];

    return {
      'customerId': contact['_id'] ?? "",
      'organization': contact['organization'] ?? "",
      'supplierName': contact['supplierName'] ?? "",
      'salutation': contact['salutation'] ?? "",
      'title': contact['title'] ?? "",
      'customerNo': contact['customerNumber'] ?? "${_randomNumber()}",
      'firstName': contact['firstName'] ?? "",
      'lastName': contact['lastName'] ?? "",
      'position': contact['position'],
      'type': contact['type'] ?? "",
      'type2': contact['type2'] ?? "",
      'email': customerEmails.isNotEmpty ? customerEmails.first['email'] : "",
      'telephone': customerTelephones.isNotEmpty ? customerTelephones.first['number'] : "",
      'telephone_prefix': customerTelephones.isNotEmpty ? customerTelephones.first['phone_prefix'] : "",
      'billing_address': contact['billing_addresses']?.first ?? {},
      'shipping_address': contact['shipping_addresses']?.first ?? {},
      'vatNo': contact['customer_bank_details']?.first?['vatNo'] ?? "",
      'reverseCharge': contact['customer_bank_details']?.first?['reverseCharge'] ?? false,
    };
  }

  static int _randomNumber() {
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }
}
