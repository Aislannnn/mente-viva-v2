// ─── MODELOS ───────────────────────────────────────────────────────────────

class Lembrete {
  String titulo;
  String descricao;
  String horario;
  int iconCodePoint;
  bool concluido;
  DateTime? concluidoEm;

  Lembrete({
    required this.titulo,
    required this.descricao,
    required this.horario,
    required this.iconCodePoint,
    this.concluido = false,
    this.concluidoEm,
  });
}

class Compromisso {
  String titulo;
  String descricao;
  String horario;
  DateTime data;
  bool realizado;

  Compromisso({
    required this.titulo,
    required this.descricao,
    required this.horario,
    required this.data,
    this.realizado = false,
  });
}

class Pessoa {
  String nome;
  String relacao;
  String descricao;
  int iconCodePoint;
  int colorArgb;

  Pessoa({
    required this.nome,
    required this.relacao,
    required this.descricao,
    required this.iconCodePoint,
    required this.colorArgb,
  });
}

class RegistroSono {
  final DateTime data;
  final double horas;
  RegistroSono({required this.data, required this.horas});
}

class EsquecimentoRegistro {
  final DateTime data;
  final String descricao;
  EsquecimentoRegistro({required this.data, required this.descricao});
}

class VisitaRegistro {
  final DateTime data;
  final String nomePessoa;
  VisitaRegistro({required this.data, required this.nomePessoa});
}

// ─── DADOS REATIVOS ────────────────────────────────────────────────────────
