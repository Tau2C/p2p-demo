{ nixpkgs ? <nixpkgs> } : 

let
  pkgs = import nixpkgs {
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;
    };
  };
  buildToolsVersion = "34.0.0";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion "33.0.1" "28.0.3" ];
    platformVersions = [ "34" "33" "28" ];
    abiVersions = [ "arm64-v8a" ];
    includeNDK = true;
    ndkVersions = ["23.1.7779620"];
  };
  androidSdk = androidComposition.androidsdk;
  flutter_rust_bridge_codegen = pkgs.rustPlatform.buildRustPackage rec {
    pname = "flutter_rust_bridge_codegen";
    version = "v2.8.0";

    buildInputs = with pkgs; [ openssl ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    doInstallCheck = false;
    doCheck = false; 

    src = pkgs.fetchFromGitHub {
      owner = "fzyzcjy";
      repo = "flutter_rust_bridge";
      rev = version;
      hash = "sha256-zOs5FXiEQr6Mo+8VsG5AhopAAVqz0A6EeyGXY0Qud2U=";
    };

    cargoHash = "sha256-GqswaSqlqxEMOIS74+NSytcV+kN+G0K7t093NNwVqbo=";
  };
in
{
  devShell =
    with pkgs; mkShell rec {
      ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
      nativeBuildInputs = [
        pkg-config
      ];
      buildInputs = [
        flutter
        androidSdk
        jdk17
        cmake
        rustup
        cargo-expand
        rustc
        cargo
        # rust-analyzer
        zlib
        openssl
        openssl.dev
        vscode-extensions.rust-lang.rust-analyzer
        flutter_rust_bridge_codegen
        gtk3
        libsecret
        # libsysprof-capture
      ];
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };
}
