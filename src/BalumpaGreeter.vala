public class BalumpaGreeter: Gtk.Window {
  Greeter greeter;  
  ISession session;

  public BalumpaGreeter() {
    greeter = new Greeter();
    add(greeter);
    show_all();

    session = new BalumpaLightDM();
    session.authenticated.connect(() => {
      session.start();
    });

    var l = new Login(session);
    session.login(l, false);
  }
}

public static int main(string[] args) {
  GLib.Unix.signal_add(GLib.ProcessSignal.TERM, () => {
    stdout.printf("Receiving TERM signal. Exiting.\n");
    Gtk.main_quit();
    return true;
  });

  Gtk.init(ref args);
  new BalumpaGreeter();
  Gtk.main();
  return Posix.EXIT_SUCCESS;
}
