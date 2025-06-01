#!/bin/bash

# Terragrunt HCL Format Script for Pre-commit
# This script formats all .hcl files using terragrunt hcl format

set -e

echo "🎨 Running Terragrunt HCL format on all .hcl files..."

# Check if terragrunt is available
if ! command -v terragrunt &> /dev/null; then
    echo "❌ Error: terragrunt command not found. Please install terragrunt."
    exit 1
fi

# Find and format all .hcl files (excluding cache and temporary files)
formatted_files=0
error_files=0

while IFS= read -r -d '' file; do
    echo "  Formatting: $file"
    if terragrunt hcl format "$file"; then
        formatted_files=$((formatted_files + 1))
    else
        echo "❌ Error formatting: $file"
        error_files=$((error_files + 1))
    fi
done < <(find . -name "*.hcl" -type f \
    -not -path "*/.terragrunt-cache/*" \
    -not -path "*/.terraform/*" \
    -not -path "*/node_modules/*" \
    -not -name ".terraform.lock.hcl" \
    -print0)

echo "✅ Formatting complete!"
echo "   Files formatted: $formatted_files"

if [ $error_files -gt 0 ]; then
    echo "   Files with errors: $error_files"
    exit 1
fi

exit 0
