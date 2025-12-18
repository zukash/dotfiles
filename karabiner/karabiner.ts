import * as k from "karabiner_ts";

/** Hide the application by name */
function toHideApp(name: string) {
  return k.to$(
    `osascript -e 'tell application "System Events" to set visible of process "${name}" to false'`
  );
}

const ifNotTerminal = k.ifApp(["ghostty"]).unless();

k.writeToProfile("Default profile", [
  // Emacs-like key bindings
  k.rule("zukash key bindings").manipulators([
    // Control+d -> Delete forward (exclude Terminal apps)
    k
      .map({
        key_code: "d",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "delete_forward" })
      .condition(ifNotTerminal),
    // Control+h -> Backspace
    k
      .map({
        key_code: "h",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "delete_or_backspace" }),
    // Control+b -> Left arrow
    k
      .map({
        key_code: "b",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "left_arrow" }),
    // Control+f -> Right arrow
    k
      .map({
        key_code: "f",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "right_arrow" }),
    // Control+n -> Down arrow
    k
      .map({
        key_code: "n",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "down_arrow" }),
    // Control+p -> Up arrow
    k
      .map({
        key_code: "p",
        modifiers: {
          mandatory: ["control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "up_arrow" }),
    // Command+Control+p -> Page up
    k
      .map({
        key_code: "p",
        modifiers: {
          mandatory: ["command", "control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "page_up" }),
    // Command+Control+n -> Page down
    k
      .map({
        key_code: "n",
        modifiers: {
          mandatory: ["command", "control"],
          optional: ["shift"],
        },
      })
      .to({ key_code: "page_down" }),
    // Control+[ -> Escape
    k
      .map({
        key_code: "open_bracket",
        modifiers: {
          mandatory: ["control"],
        },
      })
      .to({ key_code: "escape" }),
  ]),

  k.rule("Tap CMD to toggle Kana/Eisuu").manipulators([
    k.withMapper({
      left_command: "japanese_eisuu",
      right_command: "japanese_kana",
    } as const)((cmd, lang) =>
      k
        .map({ key_code: cmd, modifiers: { optional: ["any"] } })
        .to({ key_code: cmd, lazy: true })
        .toIfAlone({ key_code: lang })
        .description(`Tap ${cmd} alone to switch to ${lang}`)
        .parameters({ "basic.to_if_held_down_threshold_milliseconds": 100 })
    ),
  ]),

  k
    .rule("C-s to Meh")
    .manipulators([k.map("s", "⌃").toMeh().toIfAlone("s", "⌃")]),

  k
    .rule("ctrl + s + ?")
    .manipulators([
      k.map("d", "⌥⌃⇧").to("[", "⌘"),
      k.map("v", "⌥⌃⇧").to("]", "⌘"),
      k.map("b", "⌥⌃⇧").to("[", "⌘⇧"),
      k.map("f", "⌥⌃⇧").to("]", "⌘⇧"),
      k.map("x", "⌥⌃⇧").to("w", "⌘"),
      k.map("x", "⌘⌥⌃⇧").to("t", "⌘⇧"),
    ]),
]);
