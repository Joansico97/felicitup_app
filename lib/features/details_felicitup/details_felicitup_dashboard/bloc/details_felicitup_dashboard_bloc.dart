import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'details_felicitup_dashboard_event.dart';
part 'details_felicitup_dashboard_state.dart';
part 'details_felicitup_dashboard_bloc.freezed.dart';

class DetailsFelicitupDashboardBloc extends Bloc<DetailsFelicitupDashboardEvent, DetailsFelicitupDashboardState> {
  DetailsFelicitupDashboardBloc() : super(DetailsFelicitupDashboardState.initial()) {
    on<DetailsFelicitupDashboardEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<DetailsFelicitupDashboardState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
