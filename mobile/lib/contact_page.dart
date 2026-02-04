import 'package:flutter/material.dart';

<<<<<<< HEAD
import 'widgets/app/app_colors.dart';
import 'widgets/app/app_scaffold.dart';

=======
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
/// Simplified contact page: shows only clinic information.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // Clinic information (could be moved to a model or localization)
  static const String clinicName = 'Clinimolelos';
  static const String openingHours = 'Seg–Sex: 9:00–19:00\nSáb: 9:00–19:00';
  static const String address =
      'Av. Dr. Adriano Figueiredo 158, 3460-009 Tondela';
  static const String phone = '+351 232 823 220';
  static const String email = 'contacto@clinicadentaria.pt';

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return AppScaffold(
      title: 'Contactar Clínica',
      leading: AppLeading.close,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular badge + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGold,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'm.',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primaryGold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinicName,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Clínica Dentária',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(
                    color: AppColors.primaryGold,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  _infoRow(
                    context,
                    icon: Icons.schedule,
                    label: 'Horário',
                    value: openingHours,
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    context,
                    icon: Icons.location_on,
                    label: 'Morada',
                    value: address,
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    context,
                    icon: Icons.phone,
                    label: 'Telefone',
                    value: phone,
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    context,
                    icon: Icons.email,
                    label: 'Email',
                    value: email,
                  ),
                ],
=======
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFECE7DF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.event_note_outlined,
                  color: Color(0xFFB8A876),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contactar Clínica',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circular badge + title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB8A876),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'm.',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFFB8A876),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinicName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Clínica Dentária',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(
                      color: Color(0xFFB8A876),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    _infoRow(
                      context,
                      icon: Icons.schedule,
                      label: 'Horário',
                      value: openingHours,
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Morada',
                      value: address,
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Telefone',
                      value: phone,
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      value: email,
                    ),
                  ],
                ),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable info row used by the card. Kept as a method to keep layout consistent.
  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
<<<<<<< HEAD
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
=======
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
