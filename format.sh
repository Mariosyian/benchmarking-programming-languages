echo "========== FORMAT CHECK =========="
# Python (black)
echo "Formatting python files using black"
black .
isort .
# Rust (rustfmt)
echo "Formatting rust files using rustfmt"
rustfmt implementations/rust/**/*.rs
# Go (gofmt)
echo "Formatting go files using gofmt"
gofmt -w .
echo "=================================="
