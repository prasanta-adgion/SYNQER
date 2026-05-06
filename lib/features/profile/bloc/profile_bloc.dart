import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/profile/model/user_profile_model.dart';
import 'package:synqer_io/features/profile/repository/profile_repo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepo profileRepo;

  ProfileBloc({required this.profileRepo}) : super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final res = await profileRepo.fetchUserProfile();

      if (res.success == true) {
        emit(ProfileLoaded(profile: res));
      } else {
        emit(
          ProfileError(
            message: res.message ?? 'Failed to load profile',
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
