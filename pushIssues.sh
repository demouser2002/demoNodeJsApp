#!/bin/bash

days=30
since="2025-01-03T00:00:00Z"
echo $(date +"%Y-%m-%dT%H:%M:%SZ")
echo $(date --help)
#since=$(date +"%Y-%m-%dT%H:%M:%SZ")
#since=`date -v-30d +"%Y-%m-%dT%H:%M:%S"`
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
done

