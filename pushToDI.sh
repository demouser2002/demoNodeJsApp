
#!/usr/bash

DAYS=${DAYS:-30}
echo $DAYS

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
     if sh pushIssues.sh $DAYS; then
        echo "Issues pushed to DevOps Intelligence"
    else
        echo "Error: Failed to push issues to DevOps Intelligence"
        exit 1
    fi    
fi

if [ "$COMMITS" = "true" ]; then
     if sh pushCommits.sh $DAYS; then
        echo "Commits pushed to DevOps Intelligence"
    else
        echo "Error: Failed to push commits to DevOps Intelligence"
        exit 1
    fi    
fi

if [ "$PULLREQUESTS" = "true" ]; then
     if sh pushPRDetails.sh $DAYS; then
        echo "Pull Requests pushed to DevOps Intelligence"
    else
        echo "Error: Failed to push pull requests to DevOps Intelligence"
        exit 1
    fi    
fi

