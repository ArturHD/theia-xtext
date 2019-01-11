@echo off
pushd ..\app
yarn start --LSP_PORT=5007 --hostname 127.0.0.1 ../example-workspace
popd