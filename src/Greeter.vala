using WebKit;
using JSCore;

public class JSBridge: GLib.Object {

  public static JSCore.Object js_constructor (Context ctx,
      JSCore.Object constructor, 
      JSCore.Value[] arguments, 
      out JSCore.Value exception) {

    var c = new Class (js_class);
    var o = new JSCore.Object (ctx, c, null);
    var s = new String.with_utf8_c_string ("respond");
    var f = new JSCore.Object.function_with_callback (ctx, s, js_respond);  
    o.set_property (ctx, s, f, 0, null);  

    var g_o = ctx.get_global_object ();
    s = new String.with_utf8_c_string ("BalumpaBackend");
    JSCore.Value v = g_o.get_property (ctx, s, null);
    JSCore.Object balumpa = v.to_object(ctx, null);

    // Get saved greeter from Balumpa object
    var greeter = balumpa.get_private(); 
    // Pass the greeter to the instance 
    o.set_private(greeter);
    return o;
  }

  public static JSCore.Value js_respond (Context ctx,
      JSCore.Object function,
      JSCore.Object thisObject,
      JSCore.Value[] arguments,
      out JSCore.Value exception) {

    exception = null;
    var result = false;
    if (arguments.length == 1) {
      var s = arguments [0].to_string_copy (ctx, null);
      char[] buffer = new char[s.get_length() + 1];
      s.get_utf8_c_string (buffer, buffer.length);
      var response = (string) buffer;
      // Get saved greeter from the object
      Greeter? g = (Greeter) thisObject.get_private(); 
      if (g != null) {
        g.respond(response);
        result = true;
      } else {
        warning("Greeter can't be found from JS");
      }
      buffer = null;
    }

    return new JSCore.Value.boolean (ctx, result);
  }

  static const JSCore.StaticFunction[] js_funcs = {
    { null, null, 0 }
  };

  static const ClassDefinition js_class = {
    0,
    ClassAttribute.None,
    "JSBridge",
    null,

    null,
    js_funcs,

    null,
    null,

    null,
    null,
    null,
    null,

    null,
    null,
    js_constructor,
    null,
    null
  };

  public static void setup_js_class (Greeter greeter, GlobalContext context) {
    var c = new Class (js_class);
    var o = new JSCore.Object (context, c, context);
    var g = context.get_global_object ();
    var s = new String.with_utf8_c_string ("BalumpaBackend");
    g.set_property (context, s, o, PropertyAttribute.None, null);
    // Keep greeter in the object assigned to Balumpa
    o.set_private(greeter);
  }

  public static bool show_prompt (Context context, PromptType type) {
    var type_str = ((int)type).to_string();
    var cmd = "window.BalumpaClient.show_prompt("+ type_str + ")";
    var s = new String.with_utf8_c_string (cmd);
    var r = context.evaluate_script (s, null, null, 0, null); 
    return r.to_boolean(context);
  }

  public static bool show_message (Context context, MessageType type) {
    var type_str = ((int)type).to_string();
    var cmd = "window.BalumpaClient.show_message("+ type_str + ")";
    var s = new String.with_utf8_c_string (cmd);
    var r = context.evaluate_script (s, null, null, 0, null); 
    return r.to_boolean(context);
  }

}

public class Greeter: WebView {
  public Greeter() {
    var settings = new WebSettings();
    settings.enable_file_access_from_file_uris = true;
    settings.enable_universal_access_from_file_uris = true;
    settings.enable_java_applet = false;
    set_settings(settings);

    context_menu.connect(() => {
      message("Right click menu is disabled");
      return true;
    });

    resource_request_starting.connect((frame, resource, request, response) => {
      var uri = translate_uri (resource.uri);
      request.set_uri(uri);
    });

    window_object_cleared.connect ((frame, context) => {
      JSBridge.setup_js_class (this, (JSCore.GlobalContext) context);
    });

    document_load_finished.connect((frame) => {
      show_prompt(PromptType.PASSWORD);
      show_message(MessageType.WRONG_INPUT);
    });

    load_uri("http://system/index.html");

  }

  unowned JSCore.GlobalContext? get_context() {
    unowned WebFrame? frame = get_main_frame();
    if (frame == null) {
      warning("Frame is null");
      return null;
    }
    unowned JSCore.GlobalContext? context = (JSCore.GlobalContext) frame.get_global_context();
    return context;
  }

  public bool show_prompt(PromptType type) {
    unowned JSCore.GlobalContext? context = get_context();
    if (context != null) {
      var r = JSBridge.show_prompt(context, type);
      return r;
    } else {
      warning("Context is not found");
    }
    return false;
  }

  public bool show_message(MessageType type) {
    unowned JSCore.GlobalContext? context = get_context();
    if (context != null) {
      var r = JSBridge.show_message(context, type);
      return r;
    } else {
      warning("Context is not found");
    }
    return false;
  }

  public void respond(string message) {
    warning("message %s received", message);
  }

  string translate_uri (string old) {
    var uri = old.replace("http://system", "file://" + Constants.HTML_DIR + "/");
    return uri;
  }

}
