#!/bin/bash
type lua >/dev/null 2>&1 || { apt-get install -y lua5.2 }
type lz4 >/dev/null 2>&1 || { apt-get install -y lz4 }
type luarocks >/dev/null 2>&1 || { apt-get install -y luarocks }

luarocks install json
luarocks install luafilesystem
mv filecrypt /usr/local/bin/
chmod 555 /usr/local/bin/filecrypt