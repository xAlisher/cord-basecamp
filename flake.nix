{
  description = "cord-basecamp — social layer: subscribe to Beacon channels";

  inputs = {
    logos-module-builder.url = "github:logos-co/logos-module-builder";
  };

  outputs = inputs@{ self, logos-module-builder }:
    logos-module-builder.lib.mkLogosModule {
      src = ./.;
      configFile = ./metadata.json;
      flakeInputs = inputs;
    };
}
