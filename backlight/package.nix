{ pkgs }:
let
  scriptName = "backlight.sh";
  packageName = "backlight-manager";
  runtimeDeps = with pkgs; [
    bc
    gawk
  ];
  version = "0.1.0";
in
pkgs.stdenv.mkDerivation {
  pname = packageName;
  inherit version;

  src = ./.;

  buildInputs = with pkgs; [ ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    substitute ${scriptName} $out/bin/${packageName} \
      --replace "#!/usr/bin/env bash" "#!${pkgs.bash}/bin/bash"

    chmod +x $out/bin/${packageName}

    wrapProgram $out/bin/${packageName} \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
  '';

  meta = with pkgs.lib; {
    description = "intel_backlight controller";
    license = licenses.mit;
    maintainers = [ "Martin E. Zahnd" ];
  };
}
