import 'package:flutter/material.dart';

import 'models/patient.dart';
import 'pages/add_patient_page.dart';
import 'services/patient_store.dart';

import 'widgets/schedule/schedule_models.dart';
import 'widgets/schedule/sheet_container.dart';
import 'widgets/schedule/sheet_header.dart';
import 'widgets/schedule/section_label.dart';
import 'widgets/schedule/section_card.dart';
import 'widgets/schedule/select_chip.dart';
import 'widgets/schedule/dropdown_card.dart';
import 'widgets/schedule/day_chip.dart';
import 'widgets/schedule/legend_pill.dart';
import 'widgets/schedule/time_slot_button.dart';
import 'widgets/schedule/sheet_summary_row.dart';
import 'widgets/schedule/sheet_bottom_nav_bar.dart';

// -----------------------------------------------------------------------------
// Mock data
// -----------------------------------------------------------------------------

List<Patient> get _patients => PatientStore.patients;

const _doctors = <Doctor>[
  Doctor(id: 'd1', name: 'Dra. Sofia Lima'),
  Doctor(id: 'd2', name: 'Dr. Tiago Santos'),
  Doctor(id: 'd3', name: 'Dra. Ana Rocha'),
];

const _specialties = <Specialty>[
  Specialty(id: 's1', name: 'Higiene Oral'),
  Specialty(id: 's2', name: 'Ortodontia'),
  Specialty(id: 's3', name: 'Endodontia'),
];

final _days = <DayOption>[
  DayOption(date: DateTime(2026, 11, 12), labelWeekday: 'Seg', dayNumber: 12),
  DayOption(date: DateTime(2026, 11, 13), labelWeekday: 'Ter', dayNumber: 13),
  DayOption(date: DateTime(2026, 11, 14), labelWeekday: 'Qua', dayNumber: 14),
  DayOption(date: DateTime(2026, 11, 15), labelWeekday: 'Qui', dayNumber: 15),
  DayOption(date: DateTime(2026, 11, 16), labelWeekday: 'Sex', dayNumber: 16),
  DayOption(date: DateTime(2026, 11, 17), labelWeekday: 'Sáb', dayNumber: 17),
  DayOption(date: DateTime(2026, 11, 18), labelWeekday: 'Dom', dayNumber: 18),
];

const _slots = <TimeSlot>[
  TimeSlot(timeLabel: '09:00', status: SlotStatus.available),
  TimeSlot(timeLabel: '09:30', status: SlotStatus.available),
  TimeSlot(timeLabel: '10:00', status: SlotStatus.unavailable),
  TimeSlot(timeLabel: '10:30', status: SlotStatus.available),
  TimeSlot(timeLabel: '11:00', status: SlotStatus.available),
  TimeSlot(timeLabel: '11:30', status: SlotStatus.available),
];

// -----------------------------------------------------------------------------
// Public API: open the modal sheet
// -----------------------------------------------------------------------------

Future<void> showScheduleAppointmentSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.30),
    builder: (ctx) {
      final height = MediaQuery.of(ctx).size.height;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SheetContainer(
          height: height,
          child: const ScheduleAppointmentSheet(),
        ),
      );
    },
  );
}

// -----------------------------------------------------------------------------
// Main widget
// -----------------------------------------------------------------------------

class ScheduleAppointmentSheet extends StatefulWidget {
  const ScheduleAppointmentSheet({super.key});

  @override
  State<ScheduleAppointmentSheet> createState() =>
      _ScheduleAppointmentSheetState();
}

class _ScheduleAppointmentSheetState extends State<ScheduleAppointmentSheet> {
  Patient? _selectedPatient;
  Doctor? _selectedDoctor = _doctors.first;
  Specialty? _selectedSpecialty = _specialties.first;
  DayOption? _selectedDay = _days[2]; // Qua 14 (selecionado por defeito)
  TimeSlot? _selectedSlot = _slots[3]; // 10:30 (selecionado por defeito)

  int _bottomIndex = 1; // Consultas (mock)

  static const Duration _minAdvanceTime = Duration(hours: 48);

  @override
  void initState() {
    super.initState();
    final patients = _patients;
    _selectedPatient = patients.isNotEmpty ? patients.first : null;
  }

  Future<void> _addPatient() async {
    final created = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(builder: (_) => const AddPatientPage()),
    );
    if (!mounted || created == null) return;
    setState(() => _selectedPatient = created);
  }

  DateTime? get _selectedAppointmentDateTime {
    final day = _selectedDay?.date;
    final timeLabel = _selectedSlot?.timeLabel;
    if (day == null || timeLabel == null) return null;

    final parts = timeLabel.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  bool get _meetsMinAdvanceTime {
    final appointment = _selectedAppointmentDateTime;
    if (appointment == null) return false;
    final threshold = DateTime.now().add(_minAdvanceTime);
    return !appointment.isBefore(threshold);
  }

  bool get _canConfirm {
    return _selectedPatient != null &&
        _selectedDoctor != null &&
        _selectedSpecialty != null &&
        _selectedDay != null &&
        _selectedSlot != null &&
        _meetsMinAdvanceTime;
  }

  Future<void> _pickDoctor() async {
    final picked = await _showPickerBottomSheet<Doctor>(
      title: 'Selecionar Médico',
      items: _doctors,
      itemLabel: (d) => d.name,
      selectedId: _selectedDoctor?.id,
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDoctor = picked);
  }

  Future<void> _pickSpecialty() async {
    final picked = await _showPickerBottomSheet<Specialty>(
      title: 'Selecionar Especialidade',
      items: _specialties,
      itemLabel: (s) => s.name,
      selectedId: _selectedSpecialty?.id,
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedSpecialty = picked);
  }

  Future<T?> _showPickerBottomSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    required String? selectedId,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final label = itemLabel(item);
                  final isSelected = (item as dynamic).id == selectedId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    trailing: isSelected
                        ? Icon(Icons.check, color: scheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, item),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirm() {
    if (!_canConfirm) return;

    final day = _selectedDay!;
    final slot = _selectedSlot!;
    final specialty = _selectedSpecialty!;
    final doctor = _selectedDoctor!;
    final patient = _selectedPatient!;

    final summary =
        '${day.dayNumber} Nov • ${slot.timeLabel} • ${specialty.name} • ${doctor.name} • ${patient.name} (${patient.type})';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Marcação confirmada: $summary')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Soft palette close to the screenshot.
    const bg = Color(0xFFFAF7F4);
    const card = Colors.white;
    const chipSelectedBg = Color(0xFFE4F3EA);
    const chipSelectedBorder = Color(0xFF2E7D32);
    const chipNeutralBg = Color(0xFFF3EDE7);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: scheme.copyWith(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF2E7D32),
          surface: card,
        ),
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: SheetHeader(
                  title: 'Agendar Consulta',
                  subtitle: 'Vamos marcar a sua consulta',
                  helper: 'Siga os passos simples abaixo',
                  onClose: () => Navigator.pop(context),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Paciente
                      const SectionLabel('1. Paciente'),
                      const SizedBox(height: 8),
                      SectionCard(
                        child: SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _patients.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              if (i == _patients.length) {
                                return SelectChip(
                                  label: '+',
                                  selected: false,
                                  selectedBackground: chipSelectedBg,
                                  selectedBorderColor: chipSelectedBorder,
                                  unselectedBackground: chipNeutralBg,
                                  onTap: _addPatient,
                                );
                              }
                              final p = _patients[i];
                              final selected = _selectedPatient?.id == p.id;
                              return SelectChip(
                                label: '${p.name} (${p.type})',
                                selected: selected,
                                selectedBackground: chipSelectedBg,
                                selectedBorderColor: chipSelectedBorder,
                                unselectedBackground: chipNeutralBg,
                                onTap: () =>
                                    setState(() => _selectedPatient = p),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Médico e Especialidade
                      const SectionLabel('2. Médico e Especialidade'),
                      const SizedBox(height: 8),
                      SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownCard(
                                icon: Icons.person_outline,
                                label: 'Médico',
                                value: _selectedDoctor?.name ?? 'Selecionar',
                                onTap: _pickDoctor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownCard(
                                icon: Icons.medical_services_outlined,
                                label: 'Especialidade',
                                value: _selectedSpecialty?.name ?? 'Selecionar',
                                onTap: _pickSpecialty,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Data e Hora
                      const SectionLabel('3. Data e Hora'),
                      const SizedBox(height: 8),
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 56,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _days.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (ctx, i) {
                                  final d = _days[i];
                                  final isSelected =
                                      _selectedDay?.dayNumber == d.dayNumber;
                                  return DayChip(
                                    weekday: d.labelWeekday,
                                    day: d.dayNumber.toString(),
                                    selected: isSelected,
                                    onTap: () =>
                                        setState(() => _selectedDay = d),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: const [
                                LegendPill(
                                  label: 'Disponível',
                                  kind: SlotStatus.available,
                                ),
                                SizedBox(width: 10),
                                LegendPill(
                                  label: 'Indisponível',
                                  kind: SlotStatus.unavailable,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _slots.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 2.25,
                                  ),
                              itemBuilder: (ctx, i) {
                                final slot = _slots[i];
                                final selected =
                                    _selectedSlot?.timeLabel == slot.timeLabel;
                                return TimeSlotButton(
                                  label: slot.timeLabel,
                                  status: slot.status,
                                  selected: selected,
                                  onTap: slot.status == SlotStatus.unavailable
                                      ? null
                                      : () => setState(
                                          () => _selectedSlot = slot,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Confirmar
                      const SectionLabel('4. Confirmar'),
                      const SizedBox(height: 8),
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SheetSummaryRow(
                              line:
                                  '${_selectedDay?.dayNumber ?? '--'} Nov • ${_selectedSlot?.timeLabel ?? '--:--'} • ${_selectedSpecialty?.name ?? '--'} • ${(_selectedDoctor?.name ?? '--').replaceAll('Lima', '').trim()}'
                                      .trim(),
                            ),
                            if (!_meetsMinAdvanceTime) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Só é possível marcar com pelo menos 48 horas de antecedência.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.red.shade700),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: _canConfirm ? _confirm : null,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Confirmar Marcação'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // Bottom navigation (mock)
              SheetBottomNavBar(
                index: _bottomIndex,
                onChanged: (i) => setState(() => _bottomIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
