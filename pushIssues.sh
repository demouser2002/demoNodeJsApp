#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=""

hasNextPage="true"
while [ $hasNextPage = "true" ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -F since=$since -F after=$after -f query='
query issues ($owner: String!, $name: String!, $since: DateTime!, $after: String) {
		repository(owner:$owner, name: $name) {
			issues(first: 2, filterBy: {since: $since}, states: [OPEN, CLOSED], after: $after, orderBy:{field: UPDATED_AT, direction: DESC}) {
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

 hasNextPage=`jq '.data.repository.issues.pageInfo.hasNextPage' issues.json`
 echo $hasNextPage
 after=`jq '.data.repository.issues.pageInfo.endCursor' issues.json | sed 's/"//g'`
 echo $after 
 echo `cat issues.json`
done

