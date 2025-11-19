import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/company_repo.dart';
import '../models/company_model.dart';

part 'company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository companyRepository;

  CompanyCubit({required this.companyRepository}) : super(CompanyInitial());

  Future<void> getCompanyInfo({required String companyId}) async {
    debugPrint('🚀 [CompanyCubit] Starting to fetch company info');
    debugPrint('🏢 [CompanyCubit] Company ID: $companyId');

    emit(CompanyLoading());

    try {
      final company = await companyRepository.getCompanyInfo(companyId: companyId);

      debugPrint('✅ [CompanyCubit] Company info fetched successfully');
      debugPrint('📦 [CompanyCubit] Company: ${company.companyName}');

      emit(CompanyLoaded(company: company));
    } on CompanyException catch (e) {
      debugPrint('❌ [CompanyCubit] Error fetching company: ${e.message}');
      emit(CompanyError(message: e.message));
    } catch (e) {
      debugPrint('💥 [CompanyCubit] Unexpected error: $e');
      emit(CompanyError(message: 'Unexpected error occurred: ${e.toString()}'));
    }
  }

  void reset() {
    debugPrint('🔄 [CompanyCubit] Resetting state');
    emit(CompanyInitial());
  }
}
