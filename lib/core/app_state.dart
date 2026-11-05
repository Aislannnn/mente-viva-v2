import 'package:flutter/foundation.dart';

import '../features/home/domain/entities.dart';
export '../features/home/domain/entities.dart';

// Estado temporário da interface. Somente ações do usuário preenchem as listas.
final ValueNotifier<bool> modoEscuro = ValueNotifier(false);
final ValueNotifier<String> perfilAtivo = ValueNotifier('');
final ValueNotifier<double> escalaFonte = ValueNotifier(1.0);
final ValueNotifier<String> tipoFonte = ValueNotifier('Padrão');

final ValueNotifier<List<Lembrete>> lembretes = ValueNotifier(<Lembrete>[]);
final ValueNotifier<List<Compromisso>> compromissos = ValueNotifier(
  <Compromisso>[],
);
final ValueNotifier<List<Pessoa>> pessoas = ValueNotifier(<Pessoa>[]);
final ValueNotifier<List<RegistroSono>> registrosSono = ValueNotifier(
  <RegistroSono>[],
);
final ValueNotifier<List<EsquecimentoRegistro>> esquecimentos = ValueNotifier(
  <EsquecimentoRegistro>[],
);
final ValueNotifier<List<VisitaRegistro>> visitas = ValueNotifier(
  <VisitaRegistro>[],
);
