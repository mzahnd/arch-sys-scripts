{ pkgs }:
let
  scriptName = "xss-lock.sh";
  packageName = "lockmyscreen";

  xsecurelockWithMpv = pkgs.xsecurelock.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.mpv ];

    postInstall = oldAttrs.postInstall + ''
      wrapProgram $out/libexec/xsecurelock/saver_mpv --prefix PATH : ${pkgs.coreutils}/bin
    '';
  });
  runtimeDeps = with pkgs; [
    # Lockscreen
    xsecurelockWithMpv
    xss-lock
    mpv
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
    mkdir -p $out/"${packageName}.d"

    substitute ${scriptName} $out/bin/${packageName} \
      --replace-fail "#!/usr/bin/env bash" "#!${pkgs.bash}/bin/bash" \
      --replace-fail "/usr/lib/xsecurelock/dimmer" "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"

    cp "lock-xsecurelock.sh" $out/"${packageName}.d"/lock-xsecurelock
    substitute "lock-xsecurelock.sh" $out/"${packageName}.d"/lock-xsecurelock \
      --replace-fail "#!/usr/bin/env bash" "#!${pkgs.bash}/bin/bash" \

    chmod +x $out/bin/${packageName}

    wrapProgram $out/bin/${packageName} \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
        --set TRANSFER_SCRIPT_PATH "$out/${packageName}.d/lock-xsecurelock"
  '';

  meta = with pkgs.lib; {
    description = "screenlock";
    license = licenses.mit;
    maintainers = [ "Martin E. Zahnd" ];
  };
}
