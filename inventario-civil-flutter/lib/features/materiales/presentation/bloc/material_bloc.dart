import 'package:flutter_bloc/flutter_bloc.dart';
import 'material_event_state.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialBloc extends Bloc<MaterialEvent, MatBlocState> {
  final MaterialRepository _repository;

  MaterialBloc(this._repository) : super(MaterialInitial()) {
    on<CargarMateriales>(_onCargar);
    on<BuscarMaterial>(_onBuscar);
    on<BuscarConFiltros>(_onBuscarConFiltros);
    on<FiltrarPorCategoria>(_onFiltrarCategoria);
  }

  Future<void> _onCargar(CargarMateriales event, Emitter<MatBlocState> emit) async {
    emit(MaterialLoading());
    final result = await _repository.listarActivos();
    if (result.failure != null) {
      emit(MaterialError(result.failure!));
    } else {
      emit(MaterialesLoaded(result.materiales!));
    }
  }

  void _onBuscar(BuscarMaterial event, Emitter<MatBlocState> emit) {
    if (state is MaterialesLoaded) {
      final todos = (state as MaterialesLoaded).materiales;
      if (event.query.isEmpty) { emit(MaterialesLoaded(todos)); return; }
      final filtrados = todos
          .where((m) =>
              m.nombre.toLowerCase().contains(event.query.toLowerCase()) ||
              m.codigo.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(MaterialesLoaded.conFiltro(todos, filtrados));
    }
  }

  Future<void> _onBuscarConFiltros(BuscarConFiltros event, Emitter<MatBlocState> emit) async {
    emit(MaterialLoading());
    final result = await _repository.buscar(q: event.q, categoriaId: event.categoriaId);
    if (result.failure != null) {
      emit(MaterialError(result.failure!));
    } else {
      emit(MaterialesLoaded(result.materiales!));
    }
  }

  void _onFiltrarCategoria(FiltrarPorCategoria event, Emitter<MatBlocState> emit) {
    add(BuscarConFiltros(categoriaId: event.categoriaId));
  }
}
