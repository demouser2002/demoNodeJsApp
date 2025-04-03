#!/bin/bash

#if [ -z "$1" ]; then
#    echo "Usage: $0 <number_of_days>"
#    exit 1
#fi

set -e

# Function to check the exit status of the last command
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Command failed. Exiting."
        exit 1
    fi
}

#days=$1
#since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
since=$1
until=$2
after=""
issuesPushed=0
batchSize=100
hasNextPage="true"


echo '************* Pushing Issues ***************************************'

while [ $hasNextPage = "true"  ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F since=$since -F until=$until -F after=$after -f query='
query issues ($owner: String!, $name: String!, $since: DateTime!,$until: DateTime!, $after: String) {
		repository(owner:$owner, name: $name) {
			issues(first: 100, filterBy: {since: $since}, {until: $until}, states: [OPEN, CLOSED], after: $after, orderBy:{field: UPDATED_AT, direction: DESC}) {
                                totalCount
				nodes {
					id
					assignees(first: 25) {
						totalCount
						nodes {
							email
							id
							login
							name
						}
					}
					author {
						... on User {
							id
							name
							login
							email
						}
					}
					body
					closedAt
					createdAt
					number
					state
					title
					updatedAt
					url
					repository {
						url
						databaseId
					}
                	authorAssociation
					labels(first: 25) {
						totalCount
						nodes {
							name
							id
							color
							isDefault
							url
						}
					}
					locked
					databaseId
            	}
				pageInfo {
					endCursor
					hasNextPage
				}
			} 
		}
	}'> issues.json

hasNextPage=`jq -r '.data.repository.issues.pageInfo.hasNextPage' issues.json`
after=`jq -r '.data.repository.issues.pageInfo.endCursor' issues.json`

issuesCount=`jq -r '.data.repository.issues.totalCount' issues.json`


# Push issues in batches of 100
if [ $issuesPushed -lt $issuesCount ]; then
    # Calculate the remaining issues
    remainingIssues=$((issuesCount - issuesPushed))
    
    # Determine the number of issues to push in this iteration
    if [ $remainingIssues -lt $batchSize ]; then
        batchSize=$remainingIssues
    fi

    # Simulate pushing issues (replace this with actual push logic if needed)
    echo "Pushing $batchSize issues to DevOps Intelligence..."

    # Update the number of issues pushed
    issuesPushed=$((issuesPushed + batchSize))

    # Print progress
    echo "Pushed $issuesPushed out of $issuesCount issues to DevOps Intelligence."
 fi    
done

