using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.UX;
using Uno;
using Uno.Compiler.ExportTargetInterop;

[UXGlobalModule]
public class Clipboard : NativeModule
{
    static readonly Clipboard _instance;

    public Clipboard()
    {
        if (_instance != null) return;
        _instance = this;
        Resource.SetGlobalKey(_instance, "Clipboard");
        AddMember(new NativePromise<bool, bool>("copy", Copy));
    }

    static bool Copy(object[] args)
    {
        if (args.Length != 1) {
            throw new Exception("copy() requires exactly 1 parameter.");
        }
        string text = args[0] as string;
        if defined(iOS) {
            CopyText(text);
        } else if defined(ANDROID) {
            CopyText(text);
        } else {
            debug_log "Not supported!";
        }
        return true;
    }

    [Foreign(Language.ObjC)]
    static extern(iOS) void CopyText(string message)
    @{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message;
        /*NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }*/
    @}

    [Foreign(Language.Java)]
    static extern(Android) void CopyText(string message)
    @{
        if (android.os.Looper.myLooper() == null)
        {
            android.os.Looper.prepare();
        }
        android.app.Activity context = com.fuse.Activity.getRootActivity();
        try {
            int sdk = android.os.Build.VERSION.SDK_INT;
            if (sdk < android.os.Build.VERSION_CODES.HONEYCOMB) {
                android.text.ClipboardManager clipboard = (android.text.ClipboardManager) context
                        .getSystemService(context.CLIPBOARD_SERVICE);
                clipboard.setText(message);
            } else {
                android.content.ClipboardManager clipboard = (android.content.ClipboardManager) context
                        .getSystemService(context.CLIPBOARD_SERVICE);
                android.content.ClipData clip = android.content.ClipData
                        .newPlainText("", message);
                clipboard.setPrimaryClip(clip);
            }
        } catch (Exception e) {
            android.util.Log.d("Copy failed", e.toString());
        }
    @}

    static extern(!Mobile) void CopyText()
    {
        debug_log("Not supported!");
    }
}