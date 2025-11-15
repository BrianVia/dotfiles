#!/bin/bash

# Function to get ISO8601 formatted date
get_iso8601_date() {
    if date -u -I &> /dev/null; then
        # GNU date
        date -u -I'seconds'
    else
        # BSD date (macOS)
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    fi
}

# Get current time and 30 days ago in ISO8601 format
end_time=$(get_iso8601_date)
start_time=$(date -u -v-30d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "30 days ago" +"%Y-%m-%dT%H:%M:%SZ")

# List all Lambda functions and their last modified dates
aws lambda list-functions --query 'Functions[*].[FunctionName,LastModified]' --output text | while read -r function_name last_modified; do
    # Get the last invocation time for each function
    last_invoked=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/Lambda \
        --metric-name Invocations \
        --start-time "$start_time" \
        --end-time "$end_time" \
        --period 2592000 \
        --statistics Sum \
        --unit Count \
        --dimensions Name=FunctionName,Value=$function_name \
        --query 'Datapoints[0].Timestamp' \
        --output text)

    # If the function was never invoked, use "Never" as the last invocation time
    if [ "$last_invoked" == "None" ]; then
        last_invoked="Never"
    fi

    # Output the function name and last invocation time
    echo -e "$last_invoked\t$function_name"
done | sort -r