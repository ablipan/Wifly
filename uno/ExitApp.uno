using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
public class ExitApp : NativeModule
{
    static readonly ExitApp _instance;

    public ExitApp()
    {
        if (_instance != null) return;
        _instance = this;
        Resource.SetGlobalKey(_instance, "ExitApp");
        AddMember(new NativePromise<bool, bool>("exit", Exit));
    }

    static bool Exit(object[] args)
    {
        if defined(iOS) {
            debug_log "Not supported!";
        } else if defined(ANDROID) {
            _exit();
        } else {
            debug_log "Not supported!";
        }
        return true;
    }

    [Foreign(Language.Java)]
    static extern(Android) void _exit()
    @{
        android.app.Activity context = com.fuse.Activity.getRootActivity();
        context.finish();
    @}

    static extern(!Android) void _exit()
    {
        debug_log("Not supported!");
    }
}