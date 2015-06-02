public enum PromptType {
  PASSWORD,
  CONFIRM_LOGIN
}

public enum MessageType {
  WRONG_INPUT
}

// Interface of login
public interface ILogin: GLib.Object {
  // username
  public abstract string name { get; }
  // session name
  public abstract string session { get; }
  // pass a prompt to the user from the server
  public abstract void show_prompt(PromptType type);
  // pass a message to the user from the server
  public abstract void show_message(MessageType type);
  // clean up aborted login process
  public abstract void abort();
}

public class Login: ILogin, GLib.Object {
  ISession session_server;
  public string name {
    get {
      return "test"; 
    }
  }

  public string session {
    get {
      return "blankon";
    }
  }

  public Login(ISession session) {
    session_server = session;
  }

  public void show_prompt(PromptType type) {
    message("prompt %d", (int) type);
    if (type == PromptType.CONFIRM_LOGIN) {
      session_server.respond("123123123");
    } else {
      session_server.respond("123123123");
    }
  }

  public void show_message(MessageType type) {
    message("message %d", (int) type);
  }

  public void abort() {
  }
}
