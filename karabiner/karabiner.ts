import { ifApp, map, modifierLayer, rule, writeToProfile } from "karabiner_ts";

const ifNotTerminal = ifApp(["ghostty"]).unless();

writeToProfile("Default profile", [
  // Aerospace
  rule("C-s to Meh").manipulators([map("s", "⌃").toMeh().toIfAlone("s", "⌃")]),
  rule("C-s + ?").manipulators([
    map("d", "⌥⌃⇧").to("[", "⌘"),
    map("v", "⌥⌃⇧").to("]", "⌘"),
    map("b", "⌥⌃⇧").to("[", "⌘⇧"),
    map("f", "⌥⌃⇧").to("]", "⌘⇧"),
    map("x", "⌥⌃⇧").to("w", "⌘"),
    map("x", "⌘⌥⌃⇧").to("t", "⌘⇧"),
  ]),

  // Notification control
  modifierLayer("⌃", "q", "C-q").manipulators([
    map("j").to$("/opt/homebrew/bin/notif expand"),
    map("k").to$("/opt/homebrew/bin/notif collapse"),
    map("h").to$("/opt/homebrew/bin/notif close"),
    map("l").to$("/opt/homebrew/bin/notif click"),
  ]),

  // Emacs-like key bindings
  rule("zukash key bindings").manipulators([
    map("d", "⌃", "⇧").to("delete_forward").condition(ifNotTerminal),
    map("h", "⌃", "⇧").to("delete_or_backspace"),
    map("b", "⌃", "⇧").to("left_arrow"),
    map("f", "⌃", "⇧").to("right_arrow"),
    map("n", "⌃", "⇧").to("down_arrow"),
    map("p", "⌃", "⇧").to("up_arrow"),
    map("n", "⌘⌃", "⇧").to("page_down"),
    map("p", "⌘⌃", "⇧").to("page_up"),
    map("[", "⌃").to("escape"),
  ]),

  // Command key to switch input source
  rule("⌘ → EN/JP").manipulators([
    map("l⌘", "?any").to("l⌘", [], { lazy: true }).toIfAlone("japanese_eisuu"),
    map("r⌘", "?any").to("r⌘", [], { lazy: true }).toIfAlone("japanese_kana"),
  ]),
]);
