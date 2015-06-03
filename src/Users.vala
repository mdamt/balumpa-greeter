public class User {
  LightDM.User user;

  public User(LightDM.User user) {
    this.user = user;
  }

  public string to_json() {
    StringBuilder str = new StringBuilder();
    str.append("{"); 
    str.append_printf("\"%s\":\"%s\",", "displayName", user.display_name);
    str.append_printf("\"%s\":\"%s\",", "language", user.language);
    str.append_printf("\"%s\":\"%s\",", "layout", user.layout);
    str.append_printf("\"%s\":\"%s\",", "name", user.name);
    str.append_printf("\"%s\":\"%s\",", "realName", user.real_name);
    str.append_printf("\"%s\":\"%s\",", "homeDirectory", user.home_directory);
    str.append_printf("\"%s\":\"%s\",", "session", user.session);
    str.append_printf("\"%s\":\"%s\",", "background", user.background);
    str.append_printf("\"%s\":\"%s\",", "image", user.image);
    str.append_printf("\"%s\": %d,", "loggedIn", ((int)user.logged_in));
    str.append_printf("\"%s\": %d,", "uid", ((int)user.uid));
    str.append_printf("\"%s\": %d,", "hasMessages", ((int)user.has_messages));
    str.append_printf("\"%s\": [", "layouts");

    string[] layouts = user.get_layouts();
    for (var i = 0; i < layouts.length; i ++) {
      str.append_printf("\"%s\"", layouts[i]);
      if ((i + 1) < layouts.length) {
        str.append(",");
      }
    }
    str.append("]}"); 
    return str.str;
  }
}

public class UserList {
  LightDM.UserList list;
  public signal void user_added(User user);
  public signal void user_changed(User user);
  public signal void user_removed(User user);

  public UserList(LightDM.UserList list) {
    this.list = list;

    this.list.user_added.connect((u) => {
      user_added(new User(u));
    });

    this.list.user_changed.connect((u) => {
      user_changed(new User(u));
    });

    this.list.user_removed.connect((u) => {
      user_removed(new User(u));
    });
  }

  public string to_json() {
    var str = new StringBuilder();
    str.append("[");
    var i = 0;
    foreach (var user in list.users) {
      var u = new User(user);
      str.append(u.to_json());
      if ((++i) < list.users.length()) {
        str.append(",");
      }
    }
    str.append("]");
    return str.str;
  }
}
