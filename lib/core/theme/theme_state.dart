import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ThemeStatus { initial, loading, loaded }

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final ThemeStatus status;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.status = ThemeStatus.initial,
  });

  ThemeState copyWith({ThemeMode? themeMode, ThemeStatus? status}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [themeMode, status];
}
