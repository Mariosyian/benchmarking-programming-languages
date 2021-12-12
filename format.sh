echo "========== FORMAT CHECK =========="
# Python (black)
echo "Formatting python files using black"
black .
# Rust (rustfmt)
echo "Formatting rust files using rustfmt"
rustfmt implementations/rust/**/*.rs

echo "=================================="
