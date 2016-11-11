using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.Threading;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
public extern(!Android) class WifiConnector : NativeModule
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
        new Exception("WifiConnector not available on current platform");
        return 0;
    }

    Future<string> Authorize (object[] args)
    {
        var p = new Promise<string>();
        p.Reject(new Exception("WifiConnector not available on current platform"));
        return p;
    }
}