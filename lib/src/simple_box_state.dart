class SimpleBoxState {}

// Most used states in any screen , you can add yours by simply extending SimpleBoxState
final class InitialState extends SimpleBoxState {}

final class RebuildScreenState extends SimpleBoxState {}

final class LoadingState extends SimpleBoxState {}

final class ErrorState extends SimpleBoxState {
  ErrorState({this.message});

  final String? message;
}

final class SuccessState extends SimpleBoxState {
  SuccessState({this.data});

  final dynamic data;
}

final class LoadingDialogState extends SimpleBoxState {}

final class ErrorDialogState extends SimpleBoxState {
  ErrorDialogState({this.message});

  final String? message;
}

final class SuccessDialogState extends SimpleBoxState {
  SuccessDialogState({this.data});

  final dynamic data;
}
