
#!/usr/bash

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
    sh pushIssues.sh
     echo "Issues pushed to DevOps Intelligence"
fi

if [ "$COMMITS" = "true" ]; then
    sh pushCommits.sh
     echo "Commits pushed to DevOps Intelligence"
fi

if [ "$PULLREQUESTS" = "true" ]; then
    sh pushPRDetails.sh
     echo "Issues pushed to DevOps Intelligence"
fi

