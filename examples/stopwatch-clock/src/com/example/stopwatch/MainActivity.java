package com.example.stopwatch;
import android.app.*; import android.os.*; import android.graphics.Color; import android.view.*; import android.widget.*; import java.text.*; import java.util.*;
public final class MainActivity extends Activity {
  TextView clock, sw; long started, elapsed; boolean running; final Handler h=new Handler();
  public void onCreate(Bundle b){super.onCreate(b); LinearLayout l=new LinearLayout(this); l.setOrientation(LinearLayout.VERTICAL); l.setPadding(24,48,24,24); l.setBackgroundColor(Color.BLACK);
    clock=t("00:00:00",42); sw=t("00:00.0",36); l.addView(clock); l.addView(sw); LinearLayout row=new LinearLayout(this);
    Button start=button("開始"), stop=button("停止"), reset=button("リセット"); row.addView(start);row.addView(stop);row.addView(reset);l.addView(row); setContentView(l);
    start.setOnClickListener(v->{if(!running){started=System.currentTimeMillis()-elapsed;running=true;}}); stop.setOnClickListener(v->{if(running){elapsed=System.currentTimeMillis()-started;running=false;}}); reset.setOnClickListener(v->{elapsed=0;started=System.currentTimeMillis();}); h.post(tick); }
  TextView t(String s,int z){TextView v=new TextView(this);v.setText(s);v.setTextColor(Color.WHITE);v.setTextSize(z);v.setGravity(Gravity.CENTER);v.setPadding(0,30,0,30);return v;} Button button(String s){Button b=new Button(this);b.setText(s);return b;}
  Runnable tick=new Runnable(){public void run(){clock.setText(new SimpleDateFormat("HH:mm:ss",Locale.JAPAN).format(new Date())); long e=running?System.currentTimeMillis()-started:elapsed;sw.setText(String.format(Locale.JAPAN,"%02d:%04.1f",e/60000,(e%60000)/1000.0));h.postDelayed(this,100);}};
}
