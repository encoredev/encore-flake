{ stdenv, lib, fetchurl, autoPatchelfHook }:
let
  release = import ./release.nix;

  platform = {
    "x86_64-linux" = "linux_amd64";
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-linux" = "linux_arm64";
    "aarch64-darwin" = "darwin_arm64";
  }.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation rec
{
  pname = "encore";
  version = release.version;

  src = fetchurl {
    url = "https://d2f391esomvqpi.cloudfront.net/${pname}-${version}-${platform}.tar.gz";
    sha256 = release.checksums.${platform};
  };

  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  # The only file needing these is encore-go/src/debug/elf/testdata/libtiffxx.so_,
  # a Go stdlib test fixture. Ignoring them keeps libtiff and libstdc++ out of the
  # runtime closure instead of patching a test artifact against them.
  autoPatchelfIgnoreMissingDeps = [
    "libtiff.so.6"
    "libstdc++.so.6"
  ];

  unpackPhase = ''
    tar -C ./ -xzf ${src}
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/runtimes
    mkdir -p $out/encore-go

    cp -r ./bin/* $out/bin/
    cp -r ./runtimes/* $out/runtimes/
    cp -r ./encore-go/* $out/encore-go/
  '';

  meta = {
    description = "encore cli";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
