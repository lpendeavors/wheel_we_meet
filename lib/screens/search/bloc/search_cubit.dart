import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/repositories.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final AddressRepository addressRepository;

  StreamSubscription? _searchSubscription;

  SearchCubit({
    required this.addressRepository,
  }) : super(SearchInitial());

  void searchDestinations(String query) async {
    try {
      emit(SearchLoading());
      _searchSubscription?.cancel();
      _searchSubscription = addressRepository.search(query).listen(
        (results) {
          emit(SearchLoaded(results));
        },
        onError: (error) => emit(SearchError(error.toString())),
      );
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
