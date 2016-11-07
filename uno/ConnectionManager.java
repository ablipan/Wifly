package com.foreign;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.nfc.Tag;
import android.text.TextUtils;
import android.util.Log;

import java.util.List;

/**
 * ConnectionManager
 *
 * How to use:
 * ConnectionManager connectionManager=new ConnectionManager(context);
 * connectionManager.enableWifi();
 * connectionManager.requestWIFIConnection("ssid", "key");
 *
 */
public class ConnectionManager {
    private Context context;
    private static final String WPA = "WPA";
    private static final String WEP = "WEP";
    private static final String OPEN = "Open";
    private final static String TAG = "WiFiConnector";


    public ConnectionManager(Context context) {
        this.context = context;
    }

    public void enableWifi() {
        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        if (!wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(true);
            Log.i(TAG, "Wifi Turned On");
        }
    }

    public int requestWIFIConnection(String networkSSID, String networkPass) {
        try {
            WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
            //Check ssid exists
            if (scanWifi(wifiManager, networkSSID)) {
                if (getCurrentSSID(wifiManager) != null && getCurrentSSID(wifiManager).equals("\"" + networkSSID + "\"")) {
                    Log.i(TAG, "Already Connected With " + networkSSID);
                    return 1001;
                }
                //Security type detection
                String SECURE_TYPE = checkSecurity(wifiManager, networkSSID);
                if (SECURE_TYPE == null) {
                    Log.e(TAG, "Unable to find Security type for " + networkSSID);
                    return 1002;
                }
                // low the priority of the other Wifi
//                List<WifiConfiguration> configuredNetworks = wifiManager.getConfiguredNetworks();
//                for (WifiConfiguration config : configuredNetworks) {
//                    Log.d(TAG, "Wifi priority "+ config.SSID + " : " + config.priority);
//                    if (config.priority >= 0xBADBAD) {
//                        config.priority = 0xBADBAD - 1;
//                    }
//                }
                switch (SECURE_TYPE) {
                    case WPA:
                        WPA(networkSSID, networkPass, wifiManager);
                        break;
                    case WEP:
                        WEP(networkSSID, networkPass);
                        break;
                    default:
                        OPEN(wifiManager, networkSSID);
                        break;
                }
                return 0;
            }
            /*connectME();*/
        } catch (Exception e) {
            Log.e(TAG, "Error Connecting WIFI " + e);
        }
        return 4;
    }

    private void WPA(String networkSSID, String networkPass, WifiManager wifiManager) {
        WifiConfiguration wc = new WifiConfiguration();
        wc.SSID = "\"" + networkSSID + "\"";
        wc.preSharedKey = "\"" + networkPass + "\"";
        wc.status = WifiConfiguration.Status.ENABLED;
        wc.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
        wc.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
        wc.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
        wc.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
        wc.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
        wc.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
        // connect it first
        wc.priority = 0xBADBAD;
        int id = wifiManager.addNetwork(wc);
        wifiManager.disconnect();
        wifiManager.enableNetwork(id, true);
        wifiManager.reconnect();
    }

    private void WEP(String networkSSID, String networkPass) {
    }

    private void OPEN(WifiManager wifiManager, String networkSSID) {
        WifiConfiguration wc = new WifiConfiguration();
        wc.SSID = "\"" + networkSSID + "\"";
        wc.hiddenSSID = true;
        wc.priority = 0xBADBAD;
        wc.status = WifiConfiguration.Status.ENABLED;
        wc.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        int id = wifiManager.addNetwork(wc);
        wifiManager.disconnect();
        wifiManager.enableNetwork(id, true);
        wifiManager.reconnect();
    }

    private boolean scanWifi(WifiManager wifiManager, String networkSSID) {
        Log.e(TAG, "scanWifi starts");
        List<ScanResult> scanList = wifiManager.getScanResults();
        for (ScanResult i : scanList) {
            if (i.SSID != null) {
                Log.e(TAG, "SSID: " + i.SSID);
            }

            if (i.SSID != null && i.SSID.equals(networkSSID)) {
                Log.e(TAG, "Found SSID: " + i.SSID);
                return true;
            }
        }
        Log.e(TAG, "SSID " + networkSSID + " Not Found");
        return false;
    }

    private String getCurrentSSID(WifiManager wifiManager) {
        String ssid = null;
        ConnectivityManager connManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (networkInfo.isConnected()) {
            final WifiInfo connectionInfo = wifiManager.getConnectionInfo();
            if (connectionInfo != null && !TextUtils.isEmpty(connectionInfo.getSSID())) {
                ssid = connectionInfo.getSSID();
            }
        }
        return ssid;
    }

    private String checkSecurity(WifiManager wifiManager, String ssid) {
        List<ScanResult> networkList = wifiManager.getScanResults();
        for (ScanResult network : networkList) {
            if (network.SSID.equals(ssid)) {
                String Capabilities = network.capabilities;
                if (Capabilities.contains("WPA")) {
                    return WPA;
                } else if (Capabilities.contains("WEP")) {
                    return WEP;
                } else {
                    return OPEN;
                }

            }
        }
        return null;
    }
}