import 'package:flutter_bloc/flutter_bloc.dart';
import 'material_event_state.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final MaterialRepository _repository;
  List<dynamic> _todosLosMateriales = [];

  MaterialBloc(this._repository) : super(MaterialInitial()) {
    on<CargarMateriales>(_onCargar);
    on<BuscarMaterial>(_onBuscar);
  }

  Future<void> _onCargar(
    CargarMateriales event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    final result = await _repository.listarActivos();
    if (result.failure != null) {
      emit(MaterialError(result.failure!));
    } else {
      _todosLosMateriales = result.materiales!;
      emit(MaterialesLoaded(result.materiales!));
    }
  }

  void _onBuscar(BuscarMaterial event, Emitter<MaterialState> emit) {
    if (state is MaterialesLoaded) {
      final todos = (state as MaterialesLoaded).materiales;
      if (event.query.isEmpty) {
        emit(MaterialesLoaded(todos));
        return;
      }
      final filtrados = todos
          .where((m) =>
              m.nombre.toLowerCase().contains(event.query.toLowerCase()) ||
              m.codigo.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(MaterialesLoaded.conFiltro(todos, filtrados));
    }
  }
}
