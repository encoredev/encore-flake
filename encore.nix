{ stdenv, lib, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec
{
  pname = "encore";
  version = "1.41.8";
  system = {
    "x86_64-linux" = "linux_amd64";
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-linux" = "linux_arm64";
    "aarch64-darwin" = "darwin_arm64";
  }.${stdenv.targetPlatform.system};

  src = fetchurl {
    url = "https://d2f391esomvqpi.cloudfront.net/${pname}-${version}-${system}.tar.gz";
    sha256 = "sha256-U5x9LPZxTEAUiRVbSIwWqdeMv/RbxTvpgJhtvXAmAeg=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ ];

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
