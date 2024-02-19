class PatientBookResponseModel {
  PatientBookResponseModel({
    this.patientId,
  });

  PatientBookResponseModel.fromJson(dynamic json) {
    patientId = json['patient_id'];
  }

  String? patientId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['patient_id'] = patientId;
    return map;
  }
}
