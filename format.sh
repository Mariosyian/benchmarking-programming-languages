#!/bin/bash
echo "========== FORMAT CHECK =========="
# Python (black)
echo "Formatting python files using black"
black .
# Rust (rustfmt)
echo "Formatting rust files using rustfmt"
rustfmt implementations/rust/**/*.rs
# Go (gofmt)
echo "Formatting go files using gofmt"
gofmt -w .
# Haxe (formatter)
echo "Formatting haxe files using formatter"
for file in $(ls implementations/haxe/**/*.hx)
do
    haxelib run formatter -s $file
done
echo "=================================="

