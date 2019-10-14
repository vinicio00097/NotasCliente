package com.undefined_constant.notas_cliente;

import android.app.KeyguardManager;
import android.content.Intent;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final int INTENT_AUTHENTICATE=1;
  private static final String CHANNEL = "flutter_cliente_notas/request_basic_auth";
    private MethodChannel.Result globalResult;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

      new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
              (call, result) -> {
                  if (call.method.equals("request_basic_auth")) {
                      globalResult=result;

                      requestAuth();
                  } else {
                      result.notImplemented();
                  }
              });
  }

  private void requestAuth(){
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
          KeyguardManager km = (KeyguardManager) getSystemService(KEYGUARD_SERVICE);

          assert km != null;
          if (km.isKeyguardSecure()) {
              Intent authIntent = km.createConfirmDeviceCredentialIntent("Identifíquese", "Para poder ingresar a la aplicación deberá autenticarse.");
              startActivityForResult(authIntent, INTENT_AUTHENTICATE);
          }else{
              globalResult.success(2);
          }
      }
  }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == INTENT_AUTHENTICATE) {
            if (resultCode == RESULT_OK) {
                //do something you want when pass the security
                globalResult.success(1);
            }else{
                globalResult.success(0);
            }
        }
    }
}
