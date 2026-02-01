{
  description = "Erlang, Elixir, Flyctl, Node.js, and PostgreSQL Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; }; # or your system
  in
  {
    devShells.default = pkgs.mkShell {
      name = "erlang-elixir-dev";
      packages = with pkgs; [
        erlangR24
        elixir_1_14
        flyctl
        nodejs-18_x # Or your preferred Node.js version
        postgresql_14 # Or your preferred PostgreSQL version
      ];

      shellHook = ''
        echo "Erlang R24, Elixir 1.14, flyctl, Node.js, and PostgreSQL ready!"
      '';
    };
  };
}
