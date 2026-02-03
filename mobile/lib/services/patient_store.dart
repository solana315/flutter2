import '../models/patient.dart';

class PatientStore {
  static final List<Patient> _patients = <Patient>[
    const Patient(id: 'p1', name: 'Paciente', type: 'Titular'),
  ];

  static List<Patient> get patients => List.unmodifiable(_patients);

  static Patient add({required String name, required String type}) {
    final id = 'p${_patients.length + 1}';
    final patient = Patient(id: id, name: name, type: type);
    _patients.add(patient);
    return patient;
  }
}
