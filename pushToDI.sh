
#!/usr/bash

# Parse input parameters
days=${1:-30}
echo $days
start_date=${2:-}
echo $start_date
end_date=${3:-}
echo $end_date

# Use start_date and end_date
if [ -n "$start_date" -a -n "$end_date" ]; then
# Use start_date and end_date
        since=$(date -d "$start_date" "+%Y-%m-%dT%H:%M:%S")
        until=$(date -d "$end_date" "+%Y-%m-%dT%H:%M:%S")
elif [ -n "$start_date" -a -n "$days" ]; then
        # Use start_date and days
        since=$(date -d "$start_date - $days days" "+%Y-%m-%dT%H:%M:%S")
        until=$(date -d "$start_date" "+%Y-%m-%dT%H:%M:%S")
elif [ -n "$days" ]; then
        # Use days and current date
        until=$(date "+%Y-%m-%dT%H:%M:%S")
        since=$(date -d "$until - $days days" "+%Y-%m-%dT%H:%M:%S")
else
        echo "Error: Insufficient parameters provided. Please provide at least 'days' or 'start_date' with 'end_date' or 'days'."
        exit 1
fi

echo "Since: $since"
echo "Until: $until"
        
echo "********Pushing data to DevOps Intelligence from "$since" to "$until" ************"

if [ $# = 0 ]; then
    ISSUES="true"
    COMMITS="true"
    PULLREQUESTS="true"
elif [ $# > 0 ]; then
    for type in "$@"
    do
        case "$type" in
            issues) ISSUES="true";;
            commits) COMMITS="true";;
            pullrequests) PULLREQUESTS="true";;
        esac
    done
fi

if [ "$ISSUES" = "true" ]; then
     if [ sh pushIssues.sh $since $until ]; then
        echo "*************Issues successfully pushed to DevOps Intelligence**************"
    else
        echo "*********Error: Failed to push issues to DevOps Intelligence****************"
        exit 1
    fi    
fi

if [ "$COMMITS" = "true" ]; then
     if [ sh pushCommits.sh $since $until ]; then
        echo "*************Commits successfully pushed to DevOps Intelligence*************"
    else
        echo "*********Error: Failed to push commits to DevOps Intelligence***************"
        exit 1
    fi    
fi

if [ "$PULLREQUESTS" = "true" ]; then
     if [ sh pushPRDetails.sh $since $until ]; then
        echo "********Pull Requests Details successfully pushed to DevOps Intelligence*****"
    else
        echo "*****Error: Failed to push pull requests details to DevOps Intelligence******"
        exit 1
    fi    
fi

