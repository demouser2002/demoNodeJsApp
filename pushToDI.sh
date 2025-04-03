
#!/usr/bash

# Function to display usage
usage() {
    echo "Usage: $0 days=<days> start_date=<start_date> end_date=<end_date> push=<all|issues=true,commits=true,pullrequests=true>"
    echo "Parameters:"
    echo "  days: Number of days (optional if start_date and end_date are provided)"
    echo "  start_date: Start date in YYYY-MM-DD format (optional if days is provided)"
    echo "  end_date: End date in YYYY-MM-DD format (optional if days is provided)"
    echo "  push: Specify 'all' or individual push types (issues=true, commits=true, pullrequests=true). Default is all."
    exit 1
}

# Parse input parameters
for param in "$@"; do
            key=${param%%=*}
            value=${param#*=}
            case "$key" in
                days) days=$value ;;
                start_date) start_date=$value ;;
                end_date) end_date=$value ;;
                issues) issues=$value ;;
                commits) commits=$value ;;
                pullrequests) pullrequests=$value ;;
                push) push=$value ;;
                *) echo "Unknown parameter: $param"; usage ;;
            esac
done

if [ "$push" = "all" ]; then
   issues=true
   commits=true
   pullrequests=true
fi   

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
        since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
else
        echo "Error: Insufficient parameters provided. Please provide at least 'days' or 'start_date' with 'end_date' or 'days'."
        exit 1
fi

echo "********Pushing data to DevOps Intelligence from "$since" to "$until" ************"


if [ "$issues" = "true" ]; then
     if  sh pushIssues.sh $since ; then
        echo "*************Issues successfully pushed to DevOps Intelligence**************"
    else
        echo "*********Error: Failed to push issues to DevOps Intelligence****************"
        exit 1
    fi    
fi

if [ "$commits" = "true" ]; then
     if sh pushCommits.sh $since $until ; then
        echo "*************Commits successfully pushed to DevOps Intelligence*************"
    else
        echo "*********Error: Failed to push commits to DevOps Intelligence***************"
        exit 1
    fi    
fi

if [ "$pullrequests" = "true" ]; then
     if  sh pushPRDetails.sh ; then
        echo "********Pull Requests Details successfully pushed to DevOps Intelligence*****"
    else
        echo "*****Error: Failed to push pull requests details to DevOps Intelligence******"
        exit 1
    fi    
fi

