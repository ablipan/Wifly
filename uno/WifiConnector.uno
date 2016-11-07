using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;

[ForeignInclude(Language.Java, "com.foreign.ConnectionManager")]

[UXGlobalModule]
public class WifiConnector : NativeModule
{
    static readonly WifiConnector _instance;

    public WifiConnector()
    {
        if (_instance != null) return;
        _instance = this;
        Resource.SetGlobalKey(_instance, "WifiConnector");
        AddMember(new NativePromise<int, int>("connect", Connector));
    }

    static int Connector(object[] args)
    {
        if (args.Length != 2) {
            throw new Exception("copy() requires exactly 2 parameter.");
        }
        if defined(ANDROID) {
            string ssid = args[0] as string;
            string password = args[1] as string;
            return _connect(ssid, password);
        } else {
            debug_log "Not supported!";
            return 0;
        }
    }

    [Foreign(Language.Java)]
    [Require("AndroidManifest.RootElement", "<uses-permission android:name=\"android.permission.ACCESS_WIFI_STATE\" />")]
    [Require("AndroidManifest.RootElement", "<uses-permission android:name=\"android.permission.CHANGE_WIFI_STATE\" />")]
    [Require("AndroidManifest.RootElement", "<uses-permission android:name=\"android.permission.ACCESS_NETWORK_STATE\" />")]
    static extern(Android) int _connect(string ssid, string password)
    @{
        android.app.Activity context = com.fuse.Activity.getRootActivity();
        ConnectionManager connectionManager = new ConnectionManager(context);
        connectionManager.enableWifi();
        return connectionManager.requestWIFIConnection(ssid, password);
    @}
}