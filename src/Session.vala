// Interface of session
public interface ISession: GLib.Object {
  // Whether users should be hidden in the UI
  public abstract bool hide_users { get; }
  // Whether the server has guest account
  public abstract bool has_guest_account { get; }
  // Whether the server is locked
  public abstract bool locked { get; }
  // The default session name
  public abstract string default_name { get; }

  // Start login process
  public abstract void login(ILogin login, bool guest);
  // Pass the respond to the server
  public abstract void respond(string message);
  // Start the session
  public abstract void start();

  // Emitted when user is successfully authenticated
  public signal void authenticated();
}

public class BalumpaLightDM: ISession, GLib.Object {
  ILogin? current_login { get; private set; default = null; }
  LightDM.Greeter greeter;

  bool had_prompt = false;
  bool awaiting_confirmation = false;
  bool awaiting_session = false;

  // Props are mirrored from lightdm
  public bool hide_users {
    get {
      return greeter.hide_users_hint;
    }
  }

  public bool has_guest_account {
    get {
      return greeter.has_guest_account_hint;
    }
  }

  public bool locked {
    get {
      return greeter.lock_hint;
    }
  }

  public string default_name {
    get {
      return greeter.default_session_hint;
    }
  }

  public BalumpaLightDM() {
    greeter = new LightDM.Greeter();

    try {
      message("Connecting to lightdm");
      greeter.connect_to_daemon_sync();
      message("Connected to lightdm");
    } catch (Error r) {
      stderr.printf("Couldn't connect to lightdm");
      Posix.exit (Posix.EXIT_FAILURE);
    }

    greeter.show_message.connect(this.show_message);
    greeter.show_prompt.connect(this.show_prompt);
    greeter.authentication_complete.connect(this.finalizing_authentication);
  }
  
  public void login(ILogin login, bool guest) {
    if (awaiting_session) {
      message("Login requested while waiting for a session");
      return;
    }

    message("Login");
    if (current_login != null) {
      // another login is requested, so abort the current one
      current_login.abort();
    }

    had_prompt = false;
    awaiting_confirmation = false;

    current_login = login;
    if (guest) {
      message("Logging in as guest (%s)", login.name);
      greeter.authenticate_as_guest();
    } else {
      message("Logging in as %s", login.name);
      greeter.authenticate(login.name);
    }
  }

  public void respond(string msg) {
    if (awaiting_session) {
      message("Respond requested while waiting for a session");
      return;
    }
    
    if (awaiting_confirmation) {
      awaiting_session = true;
      authenticated(); // emit authenticated signal
    } else {
      greeter.respond(msg);
    }
  }
  
  public void start() {
    if (!awaiting_session) {
    }

    try {
      greeter.start_session_sync(current_login.session);
    } catch (Error e) {
      error(e.message);
    }
  }

  void finalizing_authentication() {
    message("completing authentication");
    if (greeter.is_authenticated) {
      if (had_prompt) {
        message("Now let's wait for a session");
        awaiting_session = true;
        authenticated();
      } else {
        message("Now let's wait for a confirmation");
        awaiting_confirmation = true;
        current_login.show_prompt(PromptType.CONFIRM_LOGIN);
      }
    } else {
      message("auth is not completed");
      current_login.show_message(MessageType.WRONG_INPUT);
    }
  }

  void show_message(string text, LightDM.MessageType type) {
    current_login.show_message(MessageType.WRONG_INPUT);
  }

  void show_prompt(string text, LightDM.PromptType type) {
    had_prompt = true;
    if (text == "PASSWORD") {
      current_login.show_prompt(PromptType.PASSWORD);
    } else {
      current_login.show_prompt(PromptType.CONFIRM_LOGIN);
    }
  }
}
