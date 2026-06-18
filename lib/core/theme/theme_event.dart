import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {
  final bool isDark;

  const ToggleThemeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}
