import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserProfile {
  final UserModel model;
  final String initials;
  final String? photoUrl;
  final int followers;
  final int following;

  const UserProfile({
    required this.model,
    required this.initials,
    this.photoUrl,
    required this.followers,
    required this.following,
  });
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;

  final repo = ref.read(userRepositoryProvider);
  UserModel? userModel = await repo.getUser(user.uid);

  // If user doesn't exist in Firestore yet, create a basic one from Auth
  userModel ??= UserModel(
    id: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ?? 'Athlete',
  );

  final initials = userModel.displayName.isNotEmpty ? userModel.displayName[0].toUpperCase() : '?';

  return UserProfile(
    model: userModel,
    initials: initials,
    photoUrl: user.photoURL,
    followers: 0,
    following: 0,
  );
});
