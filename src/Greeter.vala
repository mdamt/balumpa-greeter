using WebKit;
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

  }
}
