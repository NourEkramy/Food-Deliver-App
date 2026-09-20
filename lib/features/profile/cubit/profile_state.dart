import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isSaving;

  /// Set once a save succeeds so the screen can confirm and pop, then cleared.
  final bool justSaved;
  final String? errorMessage;

  const ProfileState({
    this.isSaving = false,
    this.justSaved = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isSaving,
    bool? justSaved,
    String? errorMessage,
  }) {
    return ProfileState(
      isSaving: isSaving ?? this.isSaving,
      justSaved: justSaved ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSaving, justSaved, errorMessage];
}
