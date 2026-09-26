{ lib
, buildGoModule
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, alsa-utils
, libx11
, libxext
, libxi
, libxinerama
, libxrender
, libxtst
, wl-clipboard
, wtype
, wayland
, xclip
, xprop
}:

buildGoModule rec {
  pname = "just-talk";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./cmd
      ./config
      ./engine
      ./hotkey
      ./internal
      ./plugins
      ./go.mod
      ./go.sum
      ./README.md
      ./README.en.md
      ./LICENSE
    ];
  };

  vendorHash = "sha256-g2BRTQej/SMNTnd9Q7uOBXa2iCancxyXszzl4V9s78Y=";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    wayland
    libx11
    libxext
    libxi
    libxinerama
    libxrender
    libxtst
  ];

  subPackages = [ "cmd/just-talk" ];

  ldflags = [
    "-s"
    "-w"
  ];

  runtimePath = lib.makeBinPath [
    alsa-utils
    wl-clipboard
    wtype
    xclip
    xprop
  ];

  postInstall = ''
    wrapProgram $out/bin/just-talk \
      --prefix PATH : "$runtimePath"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "just-talk";
      desktopName = "Just Talk";
      comment = "Desktop voice input tool";
      exec = "just-talk";
      terminal = true;
      categories = [ "Utility" "AudioVideo" ];
    })
  ];

  meta = {
    description = "Desktop voice input tool with global hotkeys and streaming ASR";
    homepage = "https://github.com/c/just-talk-go";
    license = lib.licenses.gpl3Only;
    mainProgram = "just-talk";
    platforms = lib.platforms.linux;
  };
}
