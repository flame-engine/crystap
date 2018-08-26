package xyz.luan.games.crystap;

import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
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
import com.google.android.gms.common.images.ImageManager;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesClient;
import com.google.android.gms.games.Player;
import com.google.android.gms.games.PlayersClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class MainActivity extends AppCompatActivity {

    private static final int RC_SIGN_IN = 1;
    private FloatingActionButton fab;
    private Object registrar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fab = findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                System.out.println("clicked!!");
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

        signInClient.silentSignIn().addOnSuccessListener(new OnSuccessListener<GoogleSignInAccount>() {
            @Override
            public void onSuccess(GoogleSignInAccount googleSignInAccount) {

            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {

            }
        })

        Intent intent = signInClient.getSignInIntent();
        startActivityForResult(intent, RC_SIGN_IN);
    }

    private void println(Object o) {
        System.out.println(o == null ? "-null-" : o);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_SIGN_IN) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);
            if (result.isSuccess()) {
                GoogleSignInAccount signedInAccount = result.getSignInAccount();
                GamesClient gamesClient = Games.getGamesClient(this, signedInAccount);
                gamesClient.setViewForPopups(findViewById(android.R.id.content));
                signedIn(signedInAccount);
            } else {
                String message = result.getStatus().getStatusMessage();
                println(result.getStatus().getStatusMessage());
                println(result.getStatus().getResolution());
                println(result.getStatus().getStatusCode());
                if (message == null || message.isEmpty()) {
                    message = "Unexpected error " + result.getStatus();
                }
                new AlertDialog.Builder(this).setMessage(message).setNeutralButton(android.R.string.ok, null).show();
            }
        }
    }

    private Future<byte[]> readImage(final Uri uri) {
        if (uri == null) {
            return Promise.completed(null);
        }
        return new Promise<byte[]>(new Promise.Consumer<Promise<byte[]>.Resolver>() {
            @Override
            public void accept(final Promise<byte[]>.Resolver resolver) {
                ImageManager manager = ImageManager.create(MainActivity.this);
                manager.loadImage(new ImageManager.OnImageLoadedListener() {
                    @Override
                    public void onImageLoaded(Uri uri1, Drawable drawable, boolean isRequestedDrawable) {
                        Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
                        byte[] bits = stream.toByteArray();
                        resolver.resolve(bits);
                    }
                }, uri);
            }
        }).getFuture();
    }

    private void signedIn(GoogleSignInAccount account) {
        System.out.println("------------------------------------------");
        System.out.println(account);
        System.out.println("------------------------------------------");
        fab.show();
        PlayersClient playersClient = Games.getPlayersClient(this, null);
        playersClient.getCurrentPlayer().addOnSuccessListener(new OnSuccessListener<Player>() {
            @Override
            public void onSuccess(Player player) {
                try {
                    readImage(null).get();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } catch (ExecutionException e) {
                    e.printStackTrace();
                }
            }
        }).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {

            }
        })
    }
}
