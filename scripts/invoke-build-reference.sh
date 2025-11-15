#!/bin/bash

# Script to invoke Metadata-events-build-reference Lambda function
# Usage: ./invoke-build-reference.sh

REGION="us-east-1"
FUNCTION_NAME="Metadata-events-build-reference"
PAYLOAD='{"Records":[]}'

echo "Invoking function: $FUNCTION_NAME"
echo "Payload: $PAYLOAD"
echo ""

# Invoke the function
aws lambda invoke \
    --region $REGION \
    --function-name "$FUNCTION_NAME" \
    --payload "$PAYLOAD" \
    --cli-binary-format raw-in-base64-out \
    response.json > /dev/null 2>&1

# Show the response
echo ""
echo "Response:"
cat response.json 2>/dev/null || echo "No response file generated"
echo ""

# Clean up
rm -f response.json
