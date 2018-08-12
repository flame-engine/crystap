package xyz.luan.games.crystap;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.SignInButton;

public class MainActivity extends AppCompatActivity {

    private static final int RC_SIGN_IN = 1;
    private FloatingActionButton fab;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fab = findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
            }
        });
        fab.hide();

        SignInButton b = new SignInButton(this);
        RelativeLayout.LayoutParams layout = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layout.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        addContentView(b, layout);
        b.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startSignIn();
            }
        });
    }

    private void startSignIn() {
        GoogleSignInOptions opts = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)
//                .requestServerAuthCode("309817578324")
//                .requestEmail()
                .build();
        GoogleSignInClient signInClient = GoogleSignIn.getClient(this, opts);
        Intent intent = signInClient.getSignInIntent();
        startActivityForResult(intent, RC_SIGN_IN);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_SIGN_IN) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);
            if (result.isSuccess()) {
                GoogleSignInAccount signedInAccount = result.getSignInAccount();
                signedIn(signedInAccount);
            } else {
                String message = result.getStatus().getStatusMessage();
                System.out.println(result.getStatus().getStatusCode());
                System.out.println(result.getStatus().getStatusMessage());
                System.out.println(result.getStatus().getResolution());
                if (message == null || message.isEmpty()) {
                    message = "Unexpected error " + result.getStatus();
                }
                new AlertDialog.Builder(this).setMessage(message).setNeutralButton(android.R.string.ok, null).show();
            }
        }
    }

    private void signedIn(GoogleSignInAccount account) {
        System.out.println("------------------------------------------");
        System.out.println(account);
        System.out.println("------------------------------------------");
        fab.show();
    }
}
