{ stdenv, gcc, binutils, libusb1, patchelf, libudev, gmp, gmpxx, yarn, nodejs-9_x, python2, cacert, git, fetchFromGitHub }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "ledger-live-desktop";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "LedgerHQ";
    repo = "ledger-live-desktop";
    rev = "v${version}";
    sha256 = "1xscjjwl70jmhj9qaciizvhhnvcs6bd8d3v01jzgxwsscvkcd5vi";
  };

  buildInputs = [ cacert nodejs-9_x python2 yarn patchelf git gcc binutils gmp gmpxx ];
  phases = [ "buildPhase" ];

  buildPhase = ''
    cp -r $src/* .
    export HOME="."
    export CFLAGS="-I${libudev.dev}/include"
    export LDFLAGS="-L${libudev.lib}/lib \
                    -L${libudev.dev}/lib \
                    -L${libusb1}/lib \
                    -L${libusb1.dev}/lib \
                    -L${gmp}/lib \
                    -L${gmp.dev}/lib \
                    -L${gmpxx}/lib \
                    -L${gmpxx.dev}/lib \
                   "
    mkdir nodepath
    yarn config set prefix `pwd`/nodepath
    git init
    git config --local user.email "hello@example.com"
    git config --local user.name "John Doe"
    git commit -m "empty" --allow-empty
    yarn install --ignore-engines --ignore-scripts
    #node_modules/.bin/electron-builder install-app-deps
    patchelf node_modules/app-builder-bin/linux/x64/app-builder
    patchelf node_modules/7zip-bin/linux/x64/7za
    rm electron-builder.yml
    node_modules/.bin/electron-builder build --x64 --linux dir
  '';

  meta = {
    description = "Client software for Ledger Nano S / Blue";
    longDescription =
''Ledger Live is a new generation wallet desktop application providing a unique interface to maintain multiple cryptocurrencies for your Ledger Nano S / Blue. Manage your device, create accounts, receive and send cryptoassets, ...and many more.
'';
    homepage = https://www.ledgerwallet.com/live;
    maintainers = maintainers.sevcsik;
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
