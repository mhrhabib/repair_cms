import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
import 'package:repair_cms/features/profile/repository/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  Future<void> getUserProfile() async {
    debugPrint('🔄 ProfileCubit: Getting user profile...');
    emit(ProfileLoading());
    try {
      final ProfileResponseModel user = await repository.getProfile();
      debugPrint('✅ ProfileCubit: User data loaded successfully');
      debugPrint('👤 User Name: ${user.data?.fullName}');
      debugPrint('📧 User Email: ${user.data?.email}');
      emit(ProfileLoaded(user: user.data!));
    } catch (e) {
      debugPrint('❌ ProfileCubit Error: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> loadUserFromStorage() async {
    emit(ProfileLoading());
    try {
      final userData = await storage.read('user');
      if (userData != null) {
        final UserData user = UserData.fromJson(userData);
        emit(ProfileLoaded(user: user));
      } else {
        emit(ProfileError(message: 'No user data found in storage'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updateData) async {
    emit(ProfileLoading());
    try {
      final UserData updatedUser = await repository.updateUserProfile(userId, updateData);

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser)); // Also emit loaded state for consistency
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateProfileField(String userId, String field, dynamic value) async {
    emit(ProfileLoading());
    try {
      final UserData updatedUser = await repository.updateUserProfile(userId, {field: value});

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserAvatar(String userId, String avatarPath) async {
    emit(ProfileLoading());
    try {
      final success = await repository.updateUserAvatar(userId, avatarPath);
      if (success) {
        // Reload user data to get updated avatar URL
        final ProfileResponseModel user = await repository.getProfile();
        await storage.write('user', user.data!.toJson());
        emit(ProfileUpdated(user: user.data!));
        emit(ProfileLoaded(user: user.data!));
      } else {
        emit(ProfileError(message: 'Failed to update avatar'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    emit(ProfileLoading());
    try {
      final success = await repository.changePassword(userId, currentPassword, newPassword);
      if (success) {
        emit(PasswordChanged());
        // Reload user profile after password change
        await getUserProfile();
      } else {
        emit(ProfileError(message: 'Failed to change password'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserEmail(String userId, String email, String password) async {
    emit(ProfileLoading());
    try {
      final success = await repository.updateUserEmail(userId, email, password);
      if (success) {
        emit(EmailUpdated(email: email));
        // Reload user profile after email change
        await getUserProfile();
      } else {
        emit(ProfileError(message: 'Failed to update email'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    emit(ProfileLoading());
    try {
      final UserData updatedUser = await repository.updateUserPreferences(userId, preferences);

      // Update storage with new user data
      await storage.write('user', updatedUser.toJson());

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  void clearProfile() {
    emit(ProfileInitial());
  }
}
