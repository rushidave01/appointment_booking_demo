import '../../model/Doctor_booking_response_model.dart';
import '../../model/Patient_book_response_model.dart';

abstract class AppointmentState {}

class AppointmentInitState extends AppointmentState {}

class AppointmentLoadingState extends AppointmentState {}
class UpdateListState extends AppointmentState {}

class AppointmentDateGet extends AppointmentState {
  AppointmentDateGet(this.selectedDate);

  String? selectedDate;
}

class IsPmGet extends AppointmentState {
  IsPmGet(this.isPm);

  bool? isPm;
}

class TimeSlotGet extends AppointmentState {
  TimeSlotGet(this.timeSlot);

  String? timeSlot;
}

class DoctorNameGet extends AppointmentState {
  DoctorNameGet(this.selectedDoctorName);

  String? selectedDoctorName;
}

class BookPatientState extends AppointmentState {
  BookPatientState(this.responseModel);

  PatientBookResponseModel responseModel;
}

class AppointmentBookingState extends AppointmentState {
  AppointmentBookingState(this.responseModel);

  DoctorBookingResponseModel responseModel;
}

class CommonApiCallingFailureState extends AppointmentState {
  CommonApiCallingFailureState(this.message);

  String message;
}
