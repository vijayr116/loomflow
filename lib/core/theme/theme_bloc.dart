import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:loomflow/core/theme/theme_event.dart';
import 'package:loomflow/core/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    add(const LoadThemeEvent());
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(status: ThemeStatus.loading));

    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    final mode = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: mode, status: ThemeStatus.loaded));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final mode = event.isDark ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: mode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, event.isDark ? 'dark' : 'light');
  }
}
