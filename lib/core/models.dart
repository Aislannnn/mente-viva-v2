import 'package:flutter/material.dart';

// ─── MODELOS ───────────────────────────────────────────────────────────────

class Lembrete {
  String titulo;
  String descricao;
  String horario;
  IconData icone;
  bool concluido;
  DateTime? concluidoEm;

  Lembrete({
    required this.titulo,
    required this.descricao,
    required this.horario,
    required this.icone,
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
  IconData icone;
  Color cor;

  Pessoa({
    required this.nome,
    required this.relacao,
    required this.descricao,
    required this.icone,
    required this.cor,
  });
}

class JogoStat {
  final String titulo;
  int vezes;
  int minutosTotais;
  DateTime? ultimaVez;

  JogoStat({
    required this.titulo,
    this.vezes = 0,
    this.minutosTotais = 0,
    this.ultimaVez,
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
