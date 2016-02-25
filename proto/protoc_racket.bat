@ECHO OFF

set SRC_DIR=.
set DST_DIR=.

protoc -I=%SRC_DIR% --racket_out=%DST_DIR% %SRC_DIR%/sample.proto

pause