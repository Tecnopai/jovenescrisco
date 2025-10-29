package com.miltonbass.jovenescrisco;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import androidx.core.view.WindowCompat;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Habilitar edge-to-edge para Android 15+
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
    }
}