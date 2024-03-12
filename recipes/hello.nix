_: {
  hello,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "my-hello";
  inherit (hello) version src;

  meta = {
    mainProgram = "hello";
  };
}
