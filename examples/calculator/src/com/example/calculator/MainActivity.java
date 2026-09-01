package com.example.calculator;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.GridLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import java.util.Locale;

public class MainActivity extends Activity {
    private TextView display;
    private String input = "0", pending = "";
    private double stored;
    private boolean fresh = true;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(dp(16), dp(24), dp(16), dp(16));
        root.setBackgroundColor(Color.rgb(18, 18, 18));
        TextView title = label("電卓", 18, Color.rgb(190, 190, 190));
        title.setTypeface(Typeface.DEFAULT, Typeface.BOLD); root.addView(title, new LinearLayout.LayoutParams(-1, dp(32)));
        display = label("0", 46, Color.WHITE); display.setGravity(Gravity.RIGHT | Gravity.CENTER_VERTICAL); display.setSingleLine(true);
        display.setPadding(dp(8), 0, dp(8), 0); display.setBackground(round(Color.rgb(35, 35, 35), dp(16)));
        LinearLayout.LayoutParams displayParams = new LinearLayout.LayoutParams(-1, dp(112)); displayParams.bottomMargin = dp(16); root.addView(display, displayParams);
        GridLayout grid = new GridLayout(this); grid.setColumnCount(4);
        String[] keys = {"AC", "C", "⌫", "÷", "7", "8", "9", "×", "4", "5", "6", "−", "1", "2", "3", "＋", "0", ".", "="};
        for (String key : keys) addKey(grid, key);
        root.addView(grid, new LinearLayout.LayoutParams(-1, dp(356)));
        TextView nextHint = label("Chromeに戻って、次のステップへ進みます", 14, Color.rgb(190, 190, 190)); nextHint.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams hintParams = new LinearLayout.LayoutParams(-1, dp(42)); hintParams.topMargin = dp(12); root.addView(nextHint, hintParams);
        Button next = actionButton("次の開発に進む", Color.rgb(255, 209, 102), Color.rgb(25, 25, 25)); next.setOnClickListener(v -> returnToChrome());
        root.addView(next, new LinearLayout.LayoutParams(-1, dp(56))); setContentView(root);
    }

    private TextView label(String text, int size, int color) { TextView view = new TextView(this); view.setText(text); view.setTextSize(size); view.setTextColor(color); return view; }
    private void addKey(GridLayout grid, String key) {
        int color = key.equals("=") ? Color.rgb(255, 209, 102) : key.matches("[÷×−＋]") ? Color.rgb(75, 85, 105) : Color.rgb(52, 52, 52);
        Button button = actionButton(key, color, key.equals("=") ? Color.rgb(25, 25, 25) : Color.WHITE); button.setTextSize(20); button.setOnClickListener(v -> tap(key));
        GridLayout.LayoutParams params = new GridLayout.LayoutParams(); params.width = 0; params.height = dp(64); params.columnSpec = GridLayout.spec(GridLayout.UNDEFINED, key.equals("0") ? 2 : 1, 1f); params.setMargins(dp(3), dp(3), dp(3), dp(3)); grid.addView(button, params);
    }
    private Button actionButton(String text, int background, int foreground) {
        Button button = new Button(this); button.setText(text); button.setTextColor(foreground); button.setTextSize(16); button.setGravity(Gravity.CENTER); button.setAllCaps(false); button.setMinHeight(0); button.setMinWidth(0); button.setPadding(0, 0, 0, 0); button.setTypeface(Typeface.DEFAULT, Typeface.BOLD); button.setBackground(round(background, dp(14))); return button;
    }
    private GradientDrawable round(int color, int radius) { GradientDrawable drawable = new GradientDrawable(); drawable.setColor(color); drawable.setCornerRadius(radius); return drawable; }
    private int dp(int value) { return Math.round(value * getResources().getDisplayMetrics().density); }

    private void returnToChrome() {
        Uri page = Uri.parse("http://127.0.0.1:8765/?completed=1"); Intent chrome = new Intent(Intent.ACTION_VIEW, page); chrome.setPackage("com.android.chrome");
        try { startActivity(chrome); return; } catch (Exception ignored) { }
        try { startActivity(new Intent(Intent.ACTION_VIEW, page)); } catch (Exception ignored) { Toast.makeText(this, "Chromeで http://127.0.0.1:8765/?completed=1 を開いてください", Toast.LENGTH_LONG).show(); }
    }
    private void tap(String key) {
        try {
            if (key.matches("[0-9]")) { if (fresh || input.equals("0")) { input = key; fresh = false; } else input += key; }
            else if (key.equals(".")) { if (fresh) { input = "0"; fresh = false; } if (!input.contains(".")) input += "."; }
            else if (key.equals("⌫")) { if (input.equals("Error") || input.length() <= 1) input = "0"; else input = input.substring(0, input.length() - 1); fresh = false; }
            else if (key.equals("AC") || key.equals("C")) { input = "0"; pending = ""; stored = 0; fresh = true; }
            else if (key.equals("=")) { if (!pending.isEmpty()) { stored = calc(stored, Double.parseDouble(input), pending); input = fmt(stored); pending = ""; } fresh = true; }
            else { String op = key.equals("＋") ? "+" : key.equals("−") ? "-" : key; if (fresh && !pending.isEmpty()) pending = op; else { if (!pending.isEmpty()) stored = calc(stored, Double.parseDouble(input), pending); else stored = Double.parseDouble(input); pending = op; fresh = true; } }
            display.setText(input);
        } catch (Exception error) { input = "Error"; pending = ""; fresh = true; display.setText(input); }
    }
    private double calc(double a, double b, String op) { if (op.equals("÷") && b == 0) throw new ArithmeticException(); return op.equals("+") ? a + b : op.equals("-") ? a - b : op.equals("×") ? a * b : a / b; }
    private String fmt(double number) { return String.format(Locale.US, "%.10f", number).replaceAll("0+$", "").replaceAll("\\.$", ""); }
}
