final: prev: {
  # with structuredAttrs, makeWrapperArgs is an array and `$makeWrapperArgs`
  # only expands to its first element, breaking the makeWrapper call
  hplip = prev.hplip.overrideAttrs (old: {
    preFixup =
      builtins.replaceStrings
      ["$makeWrapperArgs"]
      [''"''${makeWrapperArgs[@]}"'']
      old.preFixup;
  });
}
