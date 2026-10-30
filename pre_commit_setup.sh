#!/bin/bash

# Setup script to create Git pre-commit hook
# This script creates a pre-commit hook that runs the aeb pre-commit target.

echo "Setting up Git pre-commit hook..."

# Create the .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create the pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Run the pre-commit target
aeb .pre-commit.ae

# If the script fails, prevent the commit
if [ $? -ne 0 ]; then
    echo "Pre-commit checks failed. Commit aborted."
    exit 1
fi

echo "Pre-commit checks passed. Proceeding with commit."
EOF

# Make the pre-commit hook executable
chmod +x .git/hooks/pre-commit

echo "Pre-commit hook has been set up successfully."
echo "The hook will now run aeb .pre-commit.ae before each commit."
echo "If the script fails, the commit will be aborted."
