#!/bin/bash

# Terragrunt HCL Format Check Script for Pre-commit
# This script checks if all .hcl files are properly formatted

set -e

echo "🔍 Checking Terragrunt HCL format on all .hcl files..."

# Check if terragrunt is available
if ! command -v terragrunt &> /dev/null; then
    echo "❌ Error: terragrunt command not found. Please install terragrunt."
    exit 1
fi

# Find and check all .hcl files (excluding cache and temporary files)
checked_files=0
unformatted_files=()

while IFS= read -r -d '' file; do
    echo "  Checking: $file"
    if ! terragrunt hcl format --check --diff "$file"; then
        unformatted_files+=("$file")
    fi
    checked_files=$((checked_files + 1))
done < <(find . -name "*.hcl" -type f \
    -not -path "*/.terragrunt-cache/*" \
    -not -path "*/.terraform/*" \
    -not -path "*/node_modules/*" \
    -not -name ".terraform.lock.hcl" \
    -print0)

echo "📊 Format check complete!"
echo "   Files checked: $checked_files"

if [ ${#unformatted_files[@]} -gt 0 ]; then
    echo "❌ Files that need formatting: ${#unformatted_files[@]}"
    echo ""
    echo "The following files are not properly formatted:"
    for file in "${unformatted_files[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "🔧 To fix formatting issues, run:"
    echo "   terragrunt hcl format <file>"
    echo "   OR run the terragrunt-hcl-fmt pre-commit hook:"
    echo "   pre-commit run terragrunt-hcl-fmt --all-files"
    exit 1
fi

echo "✅ All files are properly formatted!"
exit 0
