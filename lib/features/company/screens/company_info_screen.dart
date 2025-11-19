import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import '../cubits/company_cubit.dart';

/// Example screen showing how to use CompanyCubit
///
/// Usage:
/// 1. Get companyId from user's location (saved in GetStorage during login)
/// 2. Trigger getCompanyInfo() in initState or on button press
/// 3. Listen to states: Loading, Loaded, Error
class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  void _loadCompanyInfo() {
    // Get companyId from location (stored during login)
    // In your login flow, you should save: storage.write('companyId', user.location.companyId)
    final companyId = storage.read('companyId');

    if (companyId != null) {
      context.read<CompanyCubit>().getCompanyInfo(companyId: companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Information'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCompanyInfo)],
      ),
      body: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          if (state is CompanyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompanyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadCompanyInfo, child: const Text('Retry')),
                ],
              ),
            );
          }

          if (state is CompanyLoaded) {
            final company = state.company;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(company.companyName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Email: ${company.companyEmail}'),
                          Text('Phone: ${company.telephone}'),
                          Text('Employees: ${company.employees}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Company Address
                  if (company.companyAddress != null && company.companyAddress!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...company.companyAddress!.map(
                              (addr) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${addr.organization}'),
                                  Text('${addr.street}, ${addr.num}'),
                                  Text('${addr.zip} ${addr.city}'),
                                  Text(addr.country),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Contact Details
                  if (company.companyContactDetail != null && company.companyContactDetail!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...company.companyContactDetail!.map(
                              (contact) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone: ${contact.telephone}'),
                                  Text('Email: ${contact.email}'),
                                  Text('Website: ${contact.website}'),
                                  Text('Fax: ${contact.fax}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Tax Details
                  if (company.companyTaxDetail != null && company.companyTaxDetail!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tax Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...company.companyTaxDetail!.map(
                              (tax) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CEO: ${tax.ceo}'),
                                  Text('Tax ID: ${tax.uidTaxId}'),
                                  Text('Registration: ${tax.registrationNum}'),
                                  Text('Default Tax: ${tax.defaultTax}%'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Bank Details
                  if (company.companyBankDetail != null && company.companyBankDetail!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...company.companyBankDetail!.map(
                              (bank) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bank: ${bank.bankName}'),
                                  Text('IBAN: ${bank.iban}'),
                                  Text('BIC: ${bank.bic}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const Center(child: Text('No company information available'));
        },
      ),
    );
  }
}
