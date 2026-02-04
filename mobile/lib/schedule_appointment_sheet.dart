import 'package:flutter/material.dart';

import 'models/patient.dart';
import 'pages/add_patient_page.dart';
import 'services/patient_store.dart';

// -----------------------------------------------------------------------------
// Mock data + models
// -----------------------------------------------------------------------------

enum SlotStatus { available, unavailable }

class Doctor {
  final String id;
  final String name;
  const Doctor({required this.id, required this.name});
}

class Specialty {
  final String id;
  final String name;
  const Specialty({required this.id, required this.name});
}

class DayOption {
  final DateTime date;
  final String labelWeekday;
  final int dayNumber;
  const DayOption({
    required this.date,
    required this.labelWeekday,
    required this.dayNumber,
  });
}

class TimeSlot {
  final String timeLabel;
  final SlotStatus status;
  const TimeSlot({required this.timeLabel, required this.status});
}

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
        child: _SheetContainer(
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
                child: _Header(
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
                      const _SectionLabel('1. Paciente'),
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
                      const _SectionLabel('2. Médico e Especialidade'),
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
                      const _SectionLabel('3. Data e Hora'),
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
                      const _SectionLabel('4. Confirmar'),
                      const SizedBox(height: 8),
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SummaryRow(
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
              _BottomNavBar(
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

// -----------------------------------------------------------------------------
// Reusable building blocks
// -----------------------------------------------------------------------------

class _SheetContainer extends StatelessWidget {
  final double height;
  final Widget child;

  const _SheetContainer({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.92),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final String helper;
  final VoidCallback onClose;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Fechar',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          helper,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedBackground;
  final Color selectedBorderColor;
  final Color unselectedBackground;

  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedBackground,
    required this.selectedBorderColor,
    required this.unselectedBackground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedBackground : unselectedBackground;
    final border = selected ? selectedBorderColor : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class DropdownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const DropdownCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayChip extends StatelessWidget {
  final String weekday;
  final String day;
  final bool selected;
  final VoidCallback onTap;

  const DayChip({
    super.key,
    required this.weekday,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$weekday $day',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 54,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE4F3EA) : const Color(0xFFF3EDE7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                day,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LegendPill extends StatelessWidget {
  final String label;
  final SlotStatus kind;

  const LegendPill({super.key, required this.label, required this.kind});

  Color _bg() {
    switch (kind) {
      case SlotStatus.available:
        return const Color(0xFFE4F3EA);
      case SlotStatus.unavailable:
        return const Color(0xFFE6E6E6);
    }
  }

  Color _fg(BuildContext context) {
    switch (kind) {
      case SlotStatus.available:
        return Theme.of(context).colorScheme.primary;
      case SlotStatus.unavailable:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _fg(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TimeSlotButton extends StatelessWidget {
  final String label;
  final SlotStatus status;
  final bool selected;
  final VoidCallback? onTap;

  const TimeSlotButton({
    super.key,
    required this.label,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  Color _bg() {
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFFE4F3EA);
      case SlotStatus.unavailable:
        return const Color(0xFFE6E6E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = status == SlotStatus.unavailable || onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      selected: selected,
      label: 'Horário $label',
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _bg(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: disabled ? Colors.black38 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE4F3EA) : const Color(0xFFFAF7F4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? scheme.primary : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? scheme.primary : Colors.black54,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, size: 18, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String line;
  const _SummaryRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNavBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                selected: index == 0,
                onTap: () => onChanged(0),
                active: scheme.primary,
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Consultas',
                selected: index == 1,
                onTap: () => onChanged(1),
                active: scheme.primary,
              ),
              _NavItem(
                icon: Icons.folder_open_outlined,
                label: 'Planos',
                selected: index == 2,
                onTap: () => onChanged(2),
                active: scheme.primary,
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                selected: index == 3,
                onTap: () => onChanged(3),
                active: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? active : Colors.black54;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF3EDE7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
