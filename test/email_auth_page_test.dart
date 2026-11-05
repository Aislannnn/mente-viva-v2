import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_viva/core/app_state.dart';
import 'package:mente_viva/features/auth/domain/access_role.dart';
import 'package:mente_viva/features/auth/domain/auth_repository.dart';
import 'package:mente_viva/features/auth/email_auth_page.dart';

class _FakeAuthRepository implements AuthRepository {
  int signInCalls = 0;
  int signUpCalls = 0;
  AccessRole? submittedRole;
  String? submittedEmail;

  @override
  bool get hasSession => false;

  @override
  Future<AccessRole?> loadRole() async => null;

  @override
  Future<AccessRole> completeRole(AccessRole role) async => role;

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {}

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
    required AccessRole role,
  }) async {
    signInCalls++;
    submittedRole = role;
    submittedEmail = email;
    return AuthResult.signedIn;
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required AccessRole role,
  }) async {
    signUpCalls++;
    submittedRole = role;
    submittedEmail = email;
    return AuthResult.confirmationRequired;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('E-mail inválido não inicia autenticação', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: EmailAuthPage(role: AccessRole.caregiver, repository: repository),
      ),
    );

    await tester.tap(find.text('Entrar').last);
    await tester.pump();

    expect(find.text('Digite um e-mail válido.'), findsOneWidget);
    expect(find.text('Use pelo menos 6 caracteres.'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('Cadastro informa a confirmação e preserva o perfil', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: EmailAuthPage(role: AccessRole.assisted, repository: repository),
      ),
    );

    await tester.tap(find.text('Criar uma conta'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextFormField).first,
      ' pa@example.com ',
    );
    await tester.enterText(find.byType(TextFormField).last, 'senha123');
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(repository.signUpCalls, 1);
    expect(repository.submittedRole, AccessRole.assisted);
    expect(repository.submittedEmail, 'pa@example.com');
    expect(find.textContaining('Enviamos uma confirmação'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Entrada usa o perfil selecionado', (tester) async {
    final repository = _FakeAuthRepository();
    addTearDown(() => perfilAtivo.value = '');
    await tester.pumpWidget(
      MaterialApp(
        home: EmailAuthPage(role: AccessRole.caregiver, repository: repository),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'cuidador@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'senha123');
    await tester.tap(find.text('Entrar').last);
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(repository.submittedRole, AccessRole.caregiver);
    expect(perfilAtivo.value, AccessRole.caregiver.profileId);
  });
}
