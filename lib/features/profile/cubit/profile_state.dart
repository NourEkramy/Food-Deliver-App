import 'package:equatable/equatable.dart';

/// What just finished, so the screen knows which message to show.
enum ProfileOutcome { none, nameSaved, passwordChanged, accountDeleted }

class ProfileState extends Equatable {
  final bool isBusy;
  final ProfileOutcome outcome;
  final String? errorMessage;

  const ProfileState({
    this.isBusy = false,
    this.outcome = ProfileOutcome.none,
    this.errorMessage,
  });

  /// Outcome and error both reset unless explicitly passed: each describes one
  /// completed attempt and should not leak into the next state.
  ProfileState copyWith({
    bool? isBusy,
    ProfileOutcome? outcome,
    String? errorMessage,
  }) {
    return ProfileState(
      isBusy: isBusy ?? this.isBusy,
      outcome: outcome ?? ProfileOutcome.none,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isBusy, outcome, errorMessage];
}
