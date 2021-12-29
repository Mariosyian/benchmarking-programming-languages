echo "========== FORMAT CHECK =========="
# Python (black)
echo "Formatting python files using black"
black .
# Go (gofmt)
echo "Formatting go files using gofmt"
gofmt -w .
echo "=================================="
