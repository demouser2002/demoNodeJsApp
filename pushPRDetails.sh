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
timelinesPushed=0
commitsPushed=0
issueBatchSize=100
timelineBatchSize=50
commitBatchSize=100
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
 timelinesCount=`jq -r '.data.search.nodes[0].timelineItems.totalCount' prs.json`
 commitsCount=`jq -r '.data.search.nodes[0].commits.totalCount' prs.json`
 
# Push issues in batches of 100
if [ $issuesPushed -lt $issuesCount ]; then
    # Calculate the remaining issues
    remainingIssues=$((issuesCount - issuesPushed))
    
    # Determine the number of issues to push in this iteration
    if [ $remainingIssues -lt $batchSize ]; then
        batchSize=$remainingIssues
    fi

    # Simulate pushing issues (replace this with actual push logic if needed)
    echo "Pushing $batchSize issues..."

    # Update the number of issues pushed
    issuesPushed=$((issuesPushed + batchSize))

    # Print progress
    echo "Pushed $issuesPushed out of $issuesCount issues."
 fi 
 if [ $timelinesPushed -lt $timelinesCount]; then
    # Calculate the remaining timelines
    remainingTimelines=$((timelinesCount - timelinesPushed))
    
    # Determine the number of timelines to push in this iteration
    if [ $remainingTimelines -lt $timelineBatchSize ]; then
        timelineBatchSize=$remainingTimelines
    fi

    # Simulate pushing timelines (replace this with actual push logic if needed)
    echo "Pushing $timelineBatchSize timelines..."

    # Update the number of timelines pushed
    timelinesPushed=$((timelinesCount + timelineBatchSize))

    # Print progress
    echo "Pushed $timelinesCount out of $timelinesCount timelines."
 fi 
 if [ $commitsPushed -lt $commitsCount ]; then
    # Calculate the remaining issues
    remainingCommits=$((commitsCount - commitsPushed))
    
    # Determine the number of issues to push in this iteration
    if [ $remainingCommits -lt $commitBatchSize ]; then
        commitBatchSize=$remainingCommits
    fi

    # Simulate pushing issues (replace this with actual push logic if needed)
    echo "Pushing $commitBatchSize commits..."

    # Update the number of issues pushed
    commitsPushed=$((commitsPushed + commitBatchSize))

    # Print progress
    echo "Pushed $commitsPushed out of $commitsCount issues."
 fi 
done
