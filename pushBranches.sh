#!/bin/bash

hasNextPage="true"
while [ $hasNextPage = "true"  ]
do
gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
query branches ($owner: String!, $name: String!) {
		repository(owner:$owner, name: $name) {
			branchProtectionRules(first: 100) {
				nodes {
				    id
					pattern
					matchingRefs(first: 100) {
						nodes {
							name
							target {
								... on Commit {
									oid
									authoredDate
								}
							}
						}
						totalCount
						pageInfo {
							endCursor
							hasNextPage
						}
					}
				}
        	}
		}
	}'> branches.json

 hasNextPage=`jq -r '.data.repository.branchProtectionRules.pageInfo.hasNextPage' branches.json`
 echo $hasNextPage
 after=`jq -r '.data.repository.branchProtectionRules.pageInfo.endCursor' branches.json`
 echo $after 
done

