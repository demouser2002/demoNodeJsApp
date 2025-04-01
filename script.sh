
#!/bin/bash

#listing all prs

gh pr list

#listing all issues

gh issue list

start_date="2025-01-01T01:01:00Z"
end_date="2025-03-01T01:01:00Z"
since="2025-01-01T01:01:00Z"
after=""

echo "Current date is " $date

hasNextPage = true
while [ $hasNextPage == true ]
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
	}'

done

gh api graphql -F owner='{owner}' -F name='{repo}' -F start_date=$start_date -f query='
  query($name: String!, $owner: String!,$start_date: GitTimestamp!){
    repository(owner:$owner, name:$name) {
            defaultBranchRef {
                target {
                    ... on Commit {
                        history(since: $start_date, first: 100) {
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
 
