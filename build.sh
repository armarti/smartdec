#!/usr/bin/env bash
set -e

THIS_DIR="$(dirname "${BASH_SOURCE[0]}")"
cd "$THIS_DIR"

make distclean

rm -rf "$THIS_DIR/build" "$THIS_DIR/dist"

ctags --c++-kinds=+p \
      --fields=+iaS \
      --extra=+q \
      -R "$THIS_DIR/src"

cmake -DNC_QT5=ON \
      -DCMAKE_PREFIX_PATH=/usr/local/opt/qt \
      -DQt5Core_DIR=/usr/local/opt/qt \
      -DBoost_ROOT=/usr/local/opt/boost \
      -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
      -DCMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX:-$THIS_DIR/dist}" \
      -G Ninja \
      -S "$THIS_DIR/src" \
      -B "$THIS_DIR/build"

cmake --build "$THIS_DIR/build"


git submodule update --init --force

doxygen & ./tests/configure.py --decompiler ./build/nocode/nocode build/tests

ninja -C build/tests -k 1 || echo "failed 1 test"

%+

cmake --build "$THIS_DIR/build" --target install

echo "Done."
exit 0
