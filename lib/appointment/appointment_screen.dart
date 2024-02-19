import 'dart:math';

import 'package:appointment_booking_demo/appointment/bloc/appointmentState.dart';
import 'package:appointment_booking_demo/appointment/bloc/appointment_cubit.dart';
import 'package:appointment_booking_demo/appointment/widgets/custom_circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../model/Patient_book_response_model.dart';
import '../model/date_list_model.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime now = DateTime.now();
  List<DateListModel>? datesList;
  DateTime? sameDayNextMonth;
  int? nextMonth;
  int? nextYear;
  int? lastDayOfNextMonth;
  int? dayInNextMonth;
  bool isPm = false;
  double firstQuadrant = 0;
  double secondQuadrant = 0;
  double thirdQuadrant = 0;
  double fourthQuadrant = 0;
  double fifthQuadrant = 0;
  int lastUpdatedTime = 0;
  String? selectedDoctorName;
  DateListModel? _selectedDateListModel;
  final List<String> dropdownItems = ['Doctor 1', 'Doctor 2', 'Doctor 3'];
  String? selectedValue;
  PatientBookResponseModel? _patientBookResponseModel;
  late AppointmentCubit appointmentCubit;

  @override
  void initState() {
    appointmentCubit = BlocProvider.of<AppointmentCubit>(context);
    appointmentCubit.getDoctorName();
    appointmentCubit.getSelectedDate();
    appointmentCubit.getIsPm();
    appointmentCubit.getTimeSlot();
    appointmentCubit.bookPatientDetails();
    // ApiCall().bookPatientDetails().then((value) =>
    //     ApiCall().bookAppointment().then((value) => ApiCall().getDoctorData()));
    nextMonth = now.month == 12 ? 1 : now.month + 1;
    nextYear = now.month == 12 ? now.year + 1 : now.year;
    lastDayOfNextMonth = DateTime(nextYear ?? 0, (nextMonth ?? 0) + 1, 0).day;
    dayInNextMonth =
        now.day > (lastDayOfNextMonth ?? 0) ? lastDayOfNextMonth : now.day;
    sameDayNextMonth = DateTime(nextYear!, nextMonth!, dayInNextMonth!);
    datesList = List<DateListModel>.generate(
        sameDayNextMonth!.difference(now).inDays + 1,
        (i) => DateListModel(
              day: DateFormat('dd').format(now.add(Duration(days: i))),
              dayName: DateFormat('EEE').format(now.add(Duration(days: i))),
              month: DateFormat('MMM').format(now.add(Duration(days: i))),
              year: DateFormat('yyyy').format(now.add(Duration(days: i))),
            ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Appointments',
            style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.25)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
          bloc: appointmentCubit,
          listener: (context, state) {
            if (state is BookPatientState) {
              _patientBookResponseModel = state.responseModel;
            } else if (state is AppointmentBookingState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment Booked successFully!'),
                ),
              );
            } else if (state is IsPmGet) {
              isPm = state.isPm ?? false;
            } else if (state is TimeSlotGet) {
              if (state.timeSlot != null && state.timeSlot!.isNotEmpty) {
                List<String> splittedTimeZone = state.timeSlot!.split(',');
                lastUpdatedTime = int.parse(splittedTimeZone[0]);
                double quadrantValue = double.parse(splittedTimeZone[1]);
                _setTimeSlot(quadrantValue);
              }
            } else if (state is AppointmentDateGet) {
              if (state.selectedDate != null &&
                  state.selectedDate!.isNotEmpty &&
                  datesList != null &&
                  datesList!.isNotEmpty) {
                _selectedDateListModel = datesList?.firstWhere(
                    (element) =>
                        state.selectedDate ==
                        '${element.year},${element.month},${element.day}',
                    orElse: () => datesList!.first);
              } else {
                _selectedDateListModel = datesList?.first;
              }
            } else if (state is DoctorNameGet) {
              selectedDoctorName =
                  state.selectedDoctorName ?? dropdownItems.first;
              // hideLoadingDialog(context);
            }
          },
          builder: (context, state) {
            if (state is AppointmentLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pick a Date',
                              style: GoogleFonts.roboto(
                                  fontSize: 22,
                                  color: const Color.fromRGBO(0, 101, 144, 1),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.25)),
                          InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                'assets/calendar.svg',
                                height: 24,
                                width: 24,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 125,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: datesList?.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _selectedDateListModel = datesList![index];
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 68,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(246, 250, 255, 1),
                                    border: _selectedDateListModel?.day ==
                                            datesList![index].day
                                        ? Border.all(
                                            color: const Color.fromRGBO(
                                                129, 147, 162, 1),
                                            width: 1,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Column(
                                      children: [
                                        Text(datesList![index].month,
                                            style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                color: _selectedDateListModel
                                                            ?.day ==
                                                        datesList![index].day
                                                    ? const Color.fromRGBO(
                                                        0, 0, 0, 1)
                                                    : const Color.fromRGBO(
                                                        127, 127, 127, 1),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.1)),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(datesList![index].day,
                                            style: GoogleFonts.lato(
                                                fontSize: 24,
                                                color: _selectedDateListModel
                                                            ?.day ==
                                                        datesList![index].day
                                                    ? const Color.fromRGBO(
                                                        0, 0, 0, 1)
                                                    : const Color.fromRGBO(
                                                        127, 127, 127, 1),
                                                fontWeight: FontWeight.w400)),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(datesList![index].dayName,
                                            style: GoogleFonts.roboto(
                                                fontSize: 16,
                                                color: _selectedDateListModel
                                                            ?.day ==
                                                        datesList![index].day
                                                    ? const Color.fromRGBO(
                                                        0, 0, 0, 1)
                                                    : const Color.fromRGBO(
                                                        127, 127, 127, 1),
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.1)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(246, 250, 255, 1),
                              // Background color
                              borderRadius: BorderRadius.circular(8),
                              // Border radius
                              border: Border.all(
                                color: const Color.fromRGBO(226, 226, 229, 1),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedValue,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: dropdownItems.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  selectedDoctorName = newValue;
                                  setState(() {});
                                },
                                hint: Text(
                                  selectedDoctorName ?? '',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color:
                                          const Color.fromRGBO(65, 72, 77, 1)),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              isPm = !isPm;
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: isPm
                                        ? const Color.fromRGBO(249, 249, 252, 1)
                                        : const Color.fromRGBO(
                                            212, 235, 255, 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'AM',
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: !isPm
                                        ? const Color.fromRGBO(249, 249, 252, 1)
                                        : const Color.fromRGBO(
                                            212, 235, 255, 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'PM',
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 110,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                lastUpdatedTime = 5;
                                if (firstQuadrant == 0) {
                                  firstQuadrant = 0.45;
                                } else if (firstQuadrant == 0.45) {
                                  firstQuadrant = 0.95;
                                } else if (firstQuadrant == 0.95) {
                                  firstQuadrant = 1.45;
                                } else {
                                  firstQuadrant = 2;
                                }
                                setState(() {});
                              },
                              child: CustomCircleProgress(
                                percentage: -(firstQuadrant / 2), // 45%
                                number: isPm ? 5 : 8,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                lastUpdatedTime = 6;
                                if (secondQuadrant == 0) {
                                  secondQuadrant = 0.45;
                                } else if (secondQuadrant == 0.45) {
                                  secondQuadrant = 0.95;
                                } else if (secondQuadrant == 0.95) {
                                  secondQuadrant = 1.45;
                                } else {
                                  secondQuadrant = 2;
                                }
                                setState(() {});
                              },
                              child: CustomCircleProgress(
                                percentage: -(secondQuadrant / 2), // 45%
                                number: isPm ? 6 : 9,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                lastUpdatedTime = 7;
                                if (thirdQuadrant == 0) {
                                  thirdQuadrant = 0.45;
                                } else if (thirdQuadrant == 0.45) {
                                  thirdQuadrant = 0.95;
                                } else if (thirdQuadrant == 0.95) {
                                  thirdQuadrant = 1.45;
                                } else {
                                  thirdQuadrant = 2;
                                }
                                setState(() {});
                              },
                              child: CustomCircleProgress(
                                percentage: -(thirdQuadrant / 2), // 45%
                                number: isPm ? 7 : 10,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                lastUpdatedTime = 8;
                                if (fourthQuadrant == 0) {
                                  fourthQuadrant = 0.45;
                                } else if (fourthQuadrant == 0.45) {
                                  fourthQuadrant = 0.95;
                                } else if (fourthQuadrant == 0.95) {
                                  fourthQuadrant = 1.45;
                                } else {
                                  fourthQuadrant = 2;
                                }
                                setState(() {});
                              },
                              child: CustomCircleProgress(
                                percentage: -(fourthQuadrant / 2), // 45%
                                number: isPm ? 8 : 11,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                lastUpdatedTime = 9;
                                if (fifthQuadrant == 0) {
                                  fifthQuadrant = 0.45;
                                } else if (fifthQuadrant == 0.45) {
                                  fifthQuadrant = 0.95;
                                } else if (fifthQuadrant == 0.95) {
                                  fifthQuadrant = 1.45;
                                } else {
                                  fifthQuadrant = 2;
                                }
                                setState(() {});
                              },
                              child: CustomCircleProgress(
                                percentage: -(fifthQuadrant / 2), // 45%
                                number: isPm ? 9 : 12,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        appointmentCubit.storeDoctorName(selectedDoctorName);
                        appointmentCubit.storeIsPm(isPm);
                        appointmentCubit.storeTimeSlot(
                            '$lastUpdatedTime,${_getLastUpdatedQuardrnt().toString()}');
                        appointmentCubit
                            .storeSelectedDate(_selectedDateListModel);
                        appointmentCubit.bookAppointment(
                            _patientBookResponseModel?.patientId,
                            Random().nextInt(96).toString(),
                            _getScheduledDate());
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(210, 229, 245, 1),
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      child: Text(
                        'Schedule an Appointment',
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color.fromRGBO(11, 29, 41, 1)),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  double _getLastUpdatedQuardrnt() {
    switch (lastUpdatedTime) {
      case 5:
        return firstQuadrant;
      case 6:
        return secondQuadrant;
      case 7:
        return thirdQuadrant;
      case 8:
        return fourthQuadrant;
      case 9:
        return fifthQuadrant;
      default:
        return fifthQuadrant;
    }
  }

  void _setTimeSlot(double quadrantValue) {
    switch (lastUpdatedTime) {
      case 5:
        firstQuadrant = quadrantValue;
      case 6:
        secondQuadrant = quadrantValue;
      case 7:
        thirdQuadrant = quadrantValue;
      case 8:
        fourthQuadrant = quadrantValue;
      case 9:
        fifthQuadrant = quadrantValue;
      default:
        fifthQuadrant = quadrantValue;
    }
  }

  String? _getScheduledDate() {
    DateTime dateTime = DateFormat('yyyy MMM dd').parse(
        '${_selectedDateListModel?.year} ${_selectedDateListModel?.month} ${_selectedDateListModel?.day}');
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }
}
