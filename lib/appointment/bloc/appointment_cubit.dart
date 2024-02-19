import 'package:appointment_booking_demo/common/app_constants.dart';
import 'package:appointment_booking_demo/model/date_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Doctor_booking_response_model.dart';
import '../../model/Patient_book_response_model.dart';
import 'appointmentState.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit() : super(AppointmentInitState());

  void storeDoctorName(String? doctorName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(AppConstants.keySelectedDoctor, doctorName ?? '');
  }

  void storeSelectedDate(DateListModel? model) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(AppConstants.keySelectedDate,
        '${model?.year},${model?.month},${model?.day}');
  }

  void storeIsPm(bool isPm) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(AppConstants.keyIsPm, isPm);
  }

  void storeTimeSlot(String timeSlot) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(AppConstants.keyTimeSlot, timeSlot);
  }

  void getTimeSlot() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    emit(TimeSlotGet(pref.getString(AppConstants.keyTimeSlot)));
  }

  void getIsPm() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    emit(IsPmGet(pref.getBool(AppConstants.keyIsPm)));
  }

  void getSelectedDate() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    emit(AppointmentDateGet(pref.getString(AppConstants.keySelectedDate)));
  }

  void getDoctorName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    emit(DoctorNameGet(pref.getString(AppConstants.keySelectedDoctor)));
  }

  void getDoctorData() async {
    try {
      // var response = await Dio().get(
      //     'https://oh5oe1gr6i.execute-api.ap-south-1.amazonaws.com/dev/admin/test?scheduled_date=2024-01-18&doctor_id=135');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void bookPatientDetails() async {
    emit(AppointmentLoadingState());
    try {
      var response = await Dio(
          BaseOptions(
              headers: {"Content-Type": "application/json"})).post(
          'https://oh5oe1gr6i.execute-api.ap-south-1.amazonaws.com/dev/admin/test/create-patient',
          data: {"full_name": "p1", "phone": "9002124563", "gender": "male"});
      PatientBookResponseModel responseModel =
          PatientBookResponseModel.fromJson(response.data);
      emit(BookPatientState(responseModel));
    } on DioException {
      emit(CommonApiCallingFailureState('Something Went wrong :('));
    }
  }

  void bookAppointment(
    String? patientId,
    String? slotValue,
    String? scheduledDate,
  ) async {
    emit(AppointmentLoadingState());
    try {
      var response = await Dio(
          BaseOptions(
              headers: {"Content-Type": "application/json"})).post(
          'https://oh5oe1gr6i.execute-api.ap-south-1.amazonaws.com/dev/admin/test',
          data: {
            "doctor_id": "128",
            "patient_id": patientId,
            "slot_value": "$slotValue",
            "status": "scheduled",
            "created_on": "",
            "scheduled_date": scheduledDate, //"2024-02-09",
            "created_by": "1106"
          });
      DoctorBookingResponseModel responseModel =
          DoctorBookingResponseModel.fromJson(response.data);
      emit(AppointmentBookingState(responseModel));
    } on DioException {
      emit(CommonApiCallingFailureState('Something Went wrong :('));
    }
  }
}
