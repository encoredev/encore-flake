{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, channel
, release
}:
assert builtins.elem channel [ "alpha" "beta" "nightly" ];
let
  platform = {
    "x86_64-linux" = { checksum = "linux_amd64"; target = "x86_64-unknown-linux-gnu"; };
    "x86_64-darwin" = { checksum = "darwin_amd64"; target = "x86_64-apple-darwin"; };
    "aarch64-linux" = { checksum = "linux_arm64"; target = "aarch64-unknown-linux-gnu"; };
    "aarch64-darwin" = { checksum = "darwin_arm64"; target = "aarch64-apple-darwin"; };
  }.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation rec {
  pname = "encore-${channel}";
  version = release.version;

  src = fetchurl {
    url = "https://d2f391esomvqpi.cloudfront.net/v2/v${version}/encore-${platform.target}.tar.gz";
    sha256 = release.checksums.${platform.checksum};
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # Go stdlib ELF test fixtures contain dependencies that are not used at runtime.
  autoPatchelfIgnoreMissingDeps = [ "libtiff.so.6" "libstdc++.so.6" ];

  unpackPhase = ''
    runHook preUnpack
    mkdir distribution
    tar -C distribution -xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec" "$out/bin"
    cp -R distribution/. "$out/libexec/"
    # The CLI locates Go, CUE, and both SDK modules relative to its real binary.
    # Keep that layout private; expose only the channel command in a Nix profile.
    ln -s "$out/libexec/bin/encore" "$out/bin/${pname}"
    runHook postInstall
  '';

  postFixup = ''
    # Framework builds use cgo and therefore need a C compiler at runtime.
    wrapProgram "$out/libexec/bin/encore" \
      --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/${pname}" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Encore v2 CLI (${channel} channel)";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
    mainProgram = pname;
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
  };
}
