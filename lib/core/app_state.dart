import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'models.dart';
export 'models.dart';

// ─── ESTADO GLOBAL ─────────────────────────────────────────────────────────

final ValueNotifier<bool> modoEscuro = ValueNotifier(false);
final ValueNotifier<String> perfilAtivo = ValueNotifier('');
final ValueNotifier<double> escalaFonte = ValueNotifier(1.0);
final ValueNotifier<String> tipoFonte = ValueNotifier('Padrão');

final ValueNotifier<List<Lembrete>> lembretes = ValueNotifier([
  Lembrete(
    titulo: 'Tomar medicamento',
    descricao: 'Donepezil 10mg — após o café da manhã',
    horario: '08:00',
    icone: Icons.medication_outlined,
  ),
  Lembrete(
    titulo: 'Hidratação',
    descricao: 'Beber um copo d\'água',
    horario: '10:00',
    icone: Icons.local_drink_outlined,
  ),
  Lembrete(
    titulo: 'Exercício cognitivo',
    descricao: 'Fazer um exercício de memória',
    horario: '14:00',
    icone: Icons.psychology_outlined,
  ),
  Lembrete(
    titulo: 'Caminhada',
    descricao: '20 minutos ao ar livre',
    horario: '16:00',
    icone: Icons.directions_walk_outlined,
  ),
]);

final ValueNotifier<List<Compromisso>> compromissos = ValueNotifier([
  Compromisso(
    titulo: 'Consulta Dr. Fernandes',
    descricao: 'Neurologista — Clínica Neuro Vida',
    horario: '09:00',
    data: DateTime.now(),
  ),
  Compromisso(
    titulo: 'Visita da Maria',
    descricao: 'Filha vem almoçar',
    horario: '12:00',
    data: DateTime.now(),
  ),
  Compromisso(
    titulo: 'Fisioterapia',
    descricao: 'Centro de Reabilitação',
    horario: '15:30',
    data: DateTime.now(),
  ),
]);

final ValueNotifier<List<Pessoa>> pessoas = ValueNotifier([
  Pessoa(
    nome: 'Maria Silva',
    relacao: 'Filha',
    descricao: 'Mora em São Paulo. Liga todos os domingos.',
    icone: Icons.person,
    cor: AppColors.lavender,
  ),
  Pessoa(
    nome: 'João Silva',
    relacao: 'Filho',
    descricao: 'Trabalha como médico. Visita às quintas.',
    icone: Icons.person,
    cor: AppColors.primary,
  ),
  Pessoa(
    nome: 'Ana Costa',
    relacao: 'Neta',
    descricao: 'Tem 8 anos. Adora brincar de xadrez.',
    icone: Icons.person,
    cor: AppColors.caregiver,
  ),
  Pessoa(
    nome: 'Carlos Lima',
    relacao: 'Cuidador',
    descricao: 'Cuida todos os dias das 8h às 18h.',
    icone: Icons.person,
    cor: AppColors.amber,
  ),
  Pessoa(
    nome: 'Dr. Fernandes',
    relacao: 'Médico',
    descricao: 'Neurologista. Consulta mensal.',
    icone: Icons.local_hospital_outlined,
    cor: AppColors.berry,
  ),
  Pessoa(
    nome: 'Rosa Oliveira',
    relacao: 'Irmã',
    descricao: 'Mora na mesma cidade. Visita às sextas.',
    icone: Icons.person,
    cor: AppColors.amberDark,
  ),
]);

final ValueNotifier<List<JogoStat>> jogoStats = ValueNotifier([
  JogoStat(titulo: 'Sequência de cores'),
  JogoStat(titulo: 'Complete a palavra'),
  JogoStat(titulo: 'Encontre o par'),
  JogoStat(titulo: 'Calendário da memória'),
  JogoStat(titulo: 'Respiração guiada'),
  JogoStat(titulo: 'Leitura em voz alta'),
]);

final ValueNotifier<List<RegistroSono>> registrosSono = ValueNotifier([
  RegistroSono(
    data: DateTime.now().subtract(const Duration(days: 1)),
    horas: 7.5,
  ),
  RegistroSono(
    data: DateTime.now().subtract(const Duration(days: 2)),
    horas: 6.0,
  ),
  RegistroSono(
    data: DateTime.now().subtract(const Duration(days: 3)),
    horas: 8.0,
  ),
  RegistroSono(
    data: DateTime.now().subtract(const Duration(days: 4)),
    horas: 6.5,
  ),
  RegistroSono(
    data: DateTime.now().subtract(const Duration(days: 5)),
    horas: 7.0,
  ),
]);

final ValueNotifier<List<EsquecimentoRegistro>> esquecimentos = ValueNotifier([
  EsquecimentoRegistro(
    data: DateTime.now().subtract(const Duration(days: 1)),
    descricao: 'Não lembrou onde deixou os óculos',
  ),
  EsquecimentoRegistro(
    data: DateTime.now().subtract(const Duration(days: 2)),
    descricao: 'Esqueceu o nome da vizinha',
  ),
]);

final ValueNotifier<List<VisitaRegistro>> visitas = ValueNotifier([
  VisitaRegistro(
    data: DateTime.now().subtract(const Duration(days: 1)),
    nomePessoa: 'Maria Silva',
  ),
  VisitaRegistro(
    data: DateTime.now().subtract(const Duration(days: 3)),
    nomePessoa: 'Rosa Oliveira',
  ),
]);
