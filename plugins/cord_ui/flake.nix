{
  description = "Cord UI — QML plugin for the Cord module";

  inputs = {
    logos-module-builder.url = "github:logos-co/logos-module-builder/0.2.0";
    # universal dep: cord_ui's QtRO backend reaches the Qt-free zone_sequencer via
    # modules().zone_sequencer.* (codegen). Pinned to the released v0.2.0 tag.
    zone_sequencer.url = "git+file:///home/alisher/basecamp/modules/logos-zone-sequencer-module?ref=v0.2.0";
  };

  outputs = inputs@{ logos-module-builder, ... }:
    logos-module-builder.lib.mkLogosQmlModule {
      src = ./.;
      configFile = ./metadata.json;
      flakeInputs = inputs;
    };
}
