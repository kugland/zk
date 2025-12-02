{pkgs, ...}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "zsh-zk";
  version = "git";

  src = pkgs.lib.cleanSource ./..;

  dontPatch = true;
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/zsh/plugins/zk
    cp -r aliases prompt sanetty zle history completion gitstatus windowtitle $out/share/zsh/plugins/zk/
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "My Zsh configuration scripts";
    homepage = "https://github.com/kugland/zk";
    license = licenses.mit;
    maintainers = with maintainers; [kugland];
    platforms = platforms.all;
  };
}
