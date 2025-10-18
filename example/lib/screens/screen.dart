import 'package:flutter/widgets.dart';

abstract class AppScreen extends StatelessWidget {
  final String title;
  final String routeName;

  const AppScreen({super.key, required this.title, required this.routeName});
}
