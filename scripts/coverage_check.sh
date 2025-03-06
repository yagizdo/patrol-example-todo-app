#!/bin/bash

# Navigate to the root directory where the "test" folder is located
cd "$(dirname "$0")/.." || { echo "Failed to navigate to the project root directory"; exit 1; }

# Create a temporary LCOV file for filtered results
FILTERED_LCOV="coverage/lcov.filtered.info"

# Run tests and generate the coverage report
echo "Running Flutter tests with coverage..."
flutter test --fail-fast --coverage

if [ $? -ne 0 ]; then
  echo "Failed to run tests. Please check for errors."
  exit 1
fi

# Filter the coverage data
echo "Filtering coverage data..."
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/ui/**' \
  '**/widget/**' \
  '**/widgets/**' \
  '**/view/**' \
  '**/views/**' \
  '**/page/**' \
  '**/pages/**' \
  '**/screen/**' \
  '**/screens/**' \
  -o "$FILTERED_LCOV"

# Keep only specific patterns
lcov --extract "$FILTERED_LCOV" \
  '**/*_store.dart' \
  '**/*_model.dart' \
  '**/*_cubit.dart' \
  '**/*_state.dart' \
  '**/store/**' \
  '**/model/**' \
  '**/state/**' \
  '**/extension/**' \
  '**/extensions/**' \
  '**/*_extensions.dart' \
  -o "$FILTERED_LCOV"

# Generate the HTML coverage report
echo "Generating HTML coverage report..."
genhtml "$FILTERED_LCOV" -o coverage/html

# Check if the HTML report generation was successful
if [ $? -eq 0 ]; then
  echo "HTML report generated successfully in coverage/html"

  if [ "$1" == "--no-open" ]; then 
    echo "Skipping opening the HTML report..."
    exit 0
  else 
    echo "Opening the HTML report..."
    # Open the index.html file in the default browser
    echo "Opening index.html..."
    xdg-open coverage/html/index.html || open coverage/html/index.html || start coverage/html/index.html
  fi
else
  echo "Failed to generate HTML report. Please check for errors."
  exit 1
fi
