import 'package:appointment_booking_demo/appointment/appointment_screen.dart';
import 'package:appointment_booking_demo/appointment/bloc/appointment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        // useMaterial3: true,
      ),
      home: MultiBlocProvider(providers: [
        BlocProvider(create: (context)=> AppointmentCubit()),
      ],
      child: const AppointmentScreen()),
    );
  }
}