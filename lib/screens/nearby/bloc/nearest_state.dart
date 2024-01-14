import 'nearest_vm.dart';

abstract class NearestState {}

class NearestInitial extends NearestState {}

class NearestLoading extends NearestState {}

class NearestSuccess extends NearestState {
  final List<NearestVM> places;
  final NearestVM? selected;

  NearestSuccess(this.places, this.selected);
}

class NearestError extends NearestState {
  final String message;

  NearestError(this.message);
}
