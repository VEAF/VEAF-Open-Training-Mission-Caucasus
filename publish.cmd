rem @echo off
echo -
echo ------------------------------
echo publishing scripts package
echo ------------------------------

pushd src\scripts\veaf
call npm publish
popd
