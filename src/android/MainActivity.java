// MainActivity.java

package com.Society.example;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.view.Window;
import com.imactivate.example.R;


import com.moodstocks.phonegap.plugin.easyScannerplugin;


public class MainActivity extends Activity {


  private boolean compatible = false;
  private Scanner scanner;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    compatible = Scanner.isCompatible();
    if (compatible) {
      try {
        scanner = Scanner.get();
        String path = Scanner.pathFromFilesDir(this, "scanner.db");
        scanner.open(path, API_KEY, API_SECRET);
      } catch (MoodstocksError e) {
        e.printStackTrace();
      }
    }
  }

  public void openScanner (String bundleName , String api_key, String api_secret)
  {

    // Moodstocks API key/secret pair 
    String API_KEY = api_key;
    String API_SECRET = api_secret;

        // Create the scanner object and start syncing
    compatible = Scanner.isCompatible();
    if (compatible) {
      try {
        scanner = Scanner.get();
        String path = Scanner.pathFromFilesDir(this, "scanner.db");
        scanner.open(path, API_KEY, API_SECRET);
        if (bundleName != null) {
          loadBundle(bundleName,API_KEY);
        }
        else {
          // scanner opened, no bundle loaded.
          easyScannerplugin.openFinished(false);
        }
        scanner.setSyncListener(this);
      } catch (MoodstocksError e) {
        Log.d("MainActivity", "Moodstocks Error on scanner open");
        e.printStackTrace();
      }
    }

  }

  public void synchroScanner ()
  {
      scanner.sync();
  }

  public void loadBundle (String bundleName , String api_key,)
  {
    SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
    if (!prefs.getBoolean("firstTime", false)) {
      try {
        Log.d("mainActivity", "Loading Bundle. This should happen on first run only");
        scanner.importBundle(this, api_key, bundleName);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean("bundleLoaded", true);
        editor.commit();
      } catch (IOException e) {
        e.printStackTrace();
      } catch (MoodstocksError e) {
        e.printStackTrace();
      }
      SharedPreferences.Editor editor = prefs.edit();
      editor.putBoolean("firstTime", true);
      editor.commit();
    }

    // test if bundle has ever been loaded
    if (!prefs.getBoolean("bundleLoaded", false)) {
      // scanner opened, bundle loaded.
      MS4Plugin.openFinished(true);
    } else {
      // scanner opened, no bundle loaded.
      MS4Plugin.openFinished(false);
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    if (compatible) {
      try {
        scanner.close();
        scanner.destroy();
        scanner = null;
      } catch (MoodstocksError e) {
        e.printStackTrace();
      }
    }
  }

  @Override
    public void onSyncStart() {
        Log.d("Moodstocks SDK", "Sync will start.");
    }

    @Override
    public void onSyncComplete() {
        try {
            Log.d("Moodstocks SDK", "Sync succeeded (" + scanner.count() + " images)");
            easyScannerplugin.syncFinished(scanner.count());
        } catch (MoodstocksError e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onSyncFailed(MoodstocksError e) {
        Log.d("Moodstocks SDK", "Sync error #" + e.getErrorCode() + ": " + e.getMessage());
        easyScannerplugin.syncFailed();
    }

    @Override
    public void onSyncProgress(int total, int current) {
        int percent = (int) ((float) current / (float) total * 100);
        Log.d("Moodstocks SDK", "Sync progressing: " + percent + "%");
        
    }

  /* 
   * methods called from easyScannerplugin.java 
   * */

    private FragmentManager fragmentManager = getFragmentManager();
    
    public void startAutoScan() {         
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        scanFragment = new AutoScanFragment();
        fragmentTransaction.add(R.id.scanFragmentHolder, scanFragment);
        //fragmentTransaction.addToBackStack(scanFragment.toString());
        fragmentTransaction.commit(); 
  }
    
    public void startManScan() {
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        scanFragment = new ManualScanFragment();     
        fragmentTransaction.add(R.id.scanFragmentHolder, scanFragment);
        //fragmentTransaction.addToBackStack(scanFragment.toString());
        fragmentTransaction.commit(); 
    }
    
    public void stopScan() {
        //fragmentManager.popBackStack();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.remove(scanFragment);
        fragmentTransaction.commit();
    }

  public void pauseScan() {
    if(scanFragment.getClass().toString().contains("ManualScanFragment")){
        Log.d(this.toString(), "Manual Scans are paused until tapped -- pause request ignored");  
      }
      else if (scanFragment.getClass().toString().contains("AutoScanFragment")) {       
        ((AutoScanFragment) scanFragment).pauseScan();
      }
      else {

      }
  }

  public void resumeScan() {      
    if(scanFragment.getClass().toString().contains("ManualScanFragment")){
      Log.d(this.toString(), "Manual Scans are paused until tapped -- use tapToScan() to resume scanning on a Manual Scanner session"); 
      }
      else if (scanFragment.getClass().toString().contains("AutoScanFragment")) {
        ((AutoScanFragment) scanFragment).resumeScan();
      }
      else {

      }
  }
    
  // For manual scans / tap-to-scan
  public void tapToScan() {
      if(scanFragment.getClass().toString().contains("ManualScanFragment")){
        ((ManualScanFragment) scanFragment).snap(); 
      }
      else {
        Log.d("MainActivity", "TapToScan only works with a manual scanning session");
        // do nothing for now
        // but maybe implement tap to refocus in future
      }   
  }
}