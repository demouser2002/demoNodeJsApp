#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_days>"
    exit 1
fi

days=$1
since=$(date --date="$days days ago" +"%Y-%m-%dT%H:%M:%S")
after=""
QUERY="repo:"$GITHUB_REPOSITORY" is:pr sort:updated-desc"
issuesPushed=0
issueBatchSize=100
hasNextPage="true"

while [ $hasNextPage = "true" ]
do
gh api graphql -F QUERY="$QUERY" -F after=$after -f query='
query prdetails($QUERY: String!, $after: String) {
	    search(
			first: 100
			query: $QUERY
			type: ISSUE
			after: $after
		) {
			issueCount
			nodes {
				... on PullRequest {
					number
					id
					title
					url
					createdAt
					updatedAt
					fullDatabaseId
					mergedAt
					body
					mergeCommit {
						oid
					}
					additions
					deletions
					changedFiles
					totalCommentsCount
					headRefName
					baseRefName
					state
					author {
						... on User {
							id
							email
							name
							login
						}
					}
					timelineItems(
						first: 50
						after: null
						itemTypes: [ISSUE_COMMENT, PULL_REQUEST_REVIEW, REVIEW_REQUESTED_EVENT]
					) {
						totalCount
						nodes {
							eventType: __typename
							... on ReviewRequestedEvent {
								createdAt
								id
								author: requestedReviewer {
									... on User {
										login
										email
										id
										name
									}
								}
							}
							... on PullRequestReview {
								createdAt
								id
								author {
									... on User {
										id
										login
										email
										name
									}
								}
								state
								body
								comments(
									first: 80
									after: null
								) {
									totalCount
									nodes {
										body
										createdAt
									}
									pageInfo {
										endCursor
										hasNextPage
									}
								}
							}
							... on IssueComment {
							    id
								author {
									... on User {
										id
										login
										email
										name
									}
								}
								body
								createdAt
							}
						}
						pageInfo {
							endCursor
							hasNextPage
						}
					}
					closedAt
					commits(first: 100, after: null) {
						totalCount
						nodes {
							commit {
								authoredDate
								changedFilesIfAvailable
								additions
								deletions
								id
								message
								oid
								pushedDate
								resourcePath
								commitUrl
								committedDate
								author {
									user {
										email
										id
										login
										name
									}
								}
							}
						}
						pageInfo {
							endCursor
							hasNextPage
						}
					}
				}
			}
			pageInfo {
				endCursor
				hasNextPage
			}
		}
	}'> prs.json

 hasNextPage=`jq -r '.data.search.pageInfo.hasNextPage' prs.json`
 echo 'Has NextPage:' $hasNextPage
 after=`jq -r '.data.search.pageInfo.endCursor' prs.json`
 echo 'End Cursor:' $after 
 issuesCount=`jq -r '.data.search.issueCount' prs.json`
 
# Push issues in batches of 100
if [ $issuesPushed -lt $issuesCount ]; then
    # Calculate the remaining issues
    remainingIssues=$((issuesCount - issuesPushed))
    
    # Determine the number of issues to push in this iteration
    if [ $remainingIssues -lt $issueBatchSize ]; then
        issueBatchSize=$remainingIssues
    fi

    # Simulate pushing issues (replace this with actual push logic if needed)
    echo "Pushing Pull Request Details of $issueBatchSize issues..."

    # Update the number of issues pushed
    issuesPushed=$((issuesPushed + issueBatchSize))

    # Print progress
    echo "Pushed Pull Request Details $issuesPushed out of $issuesCount issues."
 fi 
 
done
