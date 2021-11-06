# Python (black)
black --check . 2>&1 | grep "would reformat" | awk '{print $3}' > tmp
black $(tr '\n' ' ' < tmp)

# Cleanup
rm tmp
