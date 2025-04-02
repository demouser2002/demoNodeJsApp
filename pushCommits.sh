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
  query commits ($owner: String!, $name: String!, $since: GitTimestamp!, $after: String) {
		repository(owner:$owner, name: $name) {
			defaultBranchRef {
				target {
					... on Commit {
						history(since: $since, first: 2, after: $after) {
							totalCount
							nodes {
								additions
								deletions
								author {
									email
									user {
										login
										id
										name
									}
								}
								id
								message
								oid
								parents(first: 100) {
									nodes {
										oid
									}
								}
								authoredDate
								changedFilesIfAvailable
								commitUrl
							}
							pageInfo {
								endCursor
								hasNextPage
							}
						}
					}
				}
			}
		}
	}' > commits.json

 hasNextPage=`jq '.data.repository.defaultBranchRef.target.history.pageInfo.hasNextPage' commits.json`
 echo $hasNextPage
 after=`jq '.data.repository.defaultBranchRef.target.history.pageInfo.endCursor' commits.json | sed 's/"//g'`
 echo $after 
done
