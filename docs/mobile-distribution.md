# Distribuição nativa

## Estado da versão de teste

- Android: o workflow `Build mobile test apps` gera `app-debug.apk` e publica o artefato `mente-viva-android-test-apk` por 14 dias em **GitHub → Actions → execução do workflow → Artifacts**. É um APK instalável para testes, assinado automaticamente com a chave de desenvolvimento do Android. O build local desse APK já compilou. Instale apenas em aparelhos de teste.
- iOS: o mesmo workflow compila o projeto em um runner macOS com `--no-codesign`. Isso verifica o código nativo, mas não produz um IPA instalável.
- O identificador de aplicativo é `com.aislannnn.menteviva` nas duas plataformas. O callback OAuth registrado no aplicativo é `menteviva://login-callback/`.

## Gerar localmente

```sh
flutter pub get
flutter build apk --debug \
  --dart-define=ENABLE_SUPABASE_AUTH=true \
  --dart-define=SUPABASE_URL=https://hdgxxdaedzidkpfmsvra.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICA
```

A chave publicável não é segredo. Não coloque uma chave `service_role`, um arquivo de assinatura nem uma senha no Git. Para iOS, rode `flutter build ios --release --no-codesign` em um Mac com Xcode e CocoaPods. O projeto exige iOS 15 ou superior.

## Alertas de lembretes

A Pessoa Assistida ativa **Configurações → Alertas diários neste aparelho**. O aplicativo pede permissão e agenda os lembretes do banco diariamente no horário local. Ao editar ou excluir lembretes, a agenda local é recriada. Ao sair da conta, mudar para convidado ou prévia, os alertas são cancelados. Cada aparelho precisa ativar a preferência separadamente. O cuidador não recebe esses alertas. O agendamento Android é inexato, então o sistema pode atrasar uma entrega; não use o alerta para uma tarefa que exija horário exato. Não há push nem alertas persistentes no navegador fechado.

## Antes de publicar nas lojas

1. Registrar `menteviva://login-callback/` em **Supabase → Authentication → URL Configuration → Redirect URLs** e testar retorno OAuth em aparelhos reais. Google e Apple também exigem ativação e credenciais próprias em **Authentication → Sign In / Providers**.
2. Android: criar e guardar fora do repositório uma chave de assinatura de produção, configurar assinatura de release, gerar AAB e cadastrar o aplicativo no Google Play Console. A identidade `com.aislannnn.menteviva` e a chave escolhida devem ser mantidas em futuras atualizações.
3. iOS: usar uma conta Apple Developer, configurar o time e os perfis de provisionamento no Xcode, assinar o aplicativo e enviar o IPA por App Store Connect/TestFlight.
4. Testar em aparelhos Android e iOS: cadastro, confirmação de e-mail, convite, revogação do vínculo, retorno OAuth, permissões, alertas após fechar o app e após reiniciar o aparelho.

O APK de teste é a entrega instalável atual. A publicação em Google Play e TestFlight depende das contas e credenciais de assinatura dos responsáveis pelo projeto.
