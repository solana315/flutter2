// Modelo simples para um dependente
class Dependent {
  final String id;
  final String name;
  final String relation; // e.g. Filho, Filha, Cônjuge
  final DateTime? dob; // data de nascimento (pode ser null)
  final String? avatarUrl;

  Dependent({
    required this.id,
    required this.name,
    required this.relation,
    this.dob,
    this.avatarUrl,
  });

  // Calcula a idade baseada em `dob`; retorna 0 se `dob` for null
  int get age {
    if (dob == null) return 0;
    final now = DateTime.now();
    int a = now.year - dob!.year;
    if (now.month < dob!.month || (now.month == dob!.month && now.day < dob!.day)) {
      a -= 1;
    }
    return a;
  }

  // Representação legível: idade ou data de nascimento
  String get ageOrDob {
    if (dob == null) return 'Data desconhecida';
    return '$age anos';
  }
}
