import '../../../models/models.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<AddressEntity> searchResults;

  SearchLoaded(this.searchResults);
}

class SearchError extends SearchState {
  final String errorMessage;

  SearchError(this.errorMessage);
}
