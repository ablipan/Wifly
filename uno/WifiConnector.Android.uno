using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.Threading;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Permissions;

[ForeignInclude(Language.Java, "com.foreign.ConnectionManager")]

[UXGlobalModule]
public extern(Android) class WifiConnector : NativeModule
{
    static readonly WifiConnector _instance;

    public WifiConnector()
    {
        if (_instance != null) return;
        _instance = this;
        Resource.SetGlobalKey(_instance, "WifiConnector");
        AddMember(new NativePromise<int, int>("connect", Connector));
        AddMember(new NativePromise<string, string>("authorize", Authorize));
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
    [Require("AndroidManifest.RootElement", "<uses-permission android:name=\"android.permission.ACCESS_COARSE_LOCATION\" />")]
    static extern(Android) int _connect(string ssid, string password)
    @{
        android.app.Activity context = com.fuse.Activity.getRootActivity();
        ConnectionManager connectionManager = new ConnectionManager(context);
        connectionManager.enableWifi();
        return connectionManager.requestWIFIConnection(ssid, password);
    @}

    static Promise<string> _authorizePromise;

    Future<string> Authorize (object[] args)
    {
        if (_authorizePromise == null)
        {
            _authorizePromise = new Promise<string>();
            /*PlatformPermission _permissions = {Permissions.Android.ACCESS_WIFI_STATE,
                Permissions.Android.CHANGE_WIFI_STATE,
                Permissions.Android.ACCESS_NETWORK_STATE
            };*/
            Permissions.Request(Permissions.Android.ACCESS_COARSE_LOCATION).Then(AuthorizeResolved, AuthorizeRejected);
        }
        return _authorizePromise;
    }
    private static void AuthorizeResolved(PlatformPermission permission)
    {
        _authorizePromise.Resolve("AuthorizationAuthorized");
    }

    private static void AuthorizeRejected(Exception reason)
    {
        _authorizePromise.Reject(reason);
    }
}