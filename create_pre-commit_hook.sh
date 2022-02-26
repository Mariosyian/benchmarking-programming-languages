#!/bin/bash
CWD=$(pwd)
# Append to an existing pre-commit hook. else create it.
if [ -f "$CWD/.git/hooks/pre-commit" ]
then
    echo -e "\n" >> "$CWD/.git/hooks/pre-commit"
else
    echo -e "#!/bin/bash" >> "$CWD/.git/hooks/pre-commit"
fi
echo "$CWD/format.sh" >> "$CWD/.git/hooks/pre-commit"

# Make it executable (bad convention but oh well)
chmod +x "$CWD/.git/hooks/pre-commit"
