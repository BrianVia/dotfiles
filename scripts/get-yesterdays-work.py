import os
import subprocess
import argparse
from datetime import datetime, timedelta
# import anthropic

def run_command(command):
    """Run a shell command and return its output."""
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
    return result.stdout.strip()

# def summarize_commits(commits):
#     """Send commits to Claude for summarization."""
#     client = anthropic.Anthropic(
#         # Make sure to set ANTHROPIC_API_KEY in your environment variables
#         api_key="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"
#     )

#     message = client.messages.create(
#         model="claude-3-opus-20240229",
#         max_tokens=1000,
#         temperature=0,
#         messages=[
#             {
#                 "role": "user",
#                 "content": [
#                     {
#                         "type": "text",
#                         "text": f"Take this list of git commits from the past 24 hours and summarize what I did in a numbered list. I don't need additional commentary. \n\n\n```\n{commits}```"
#                     }
#                 ]
#             }
#         ]
#     )
#     return message.content

def main(directory, author, days):
    # Change to the specified directory
    os.chdir(os.path.expanduser(directory))

    # Get the date X days ago in ISO 8601 format
    date_x_days_ago = (datetime.now() - timedelta(days=days)).isoformat()

    output = ""

    # Loop through all directories
    for dir_name in os.listdir('.'):
        if os.path.isdir(dir_name) and os.path.isdir(os.path.join(dir_name, '.git')):
            # Change to the directory
            os.chdir(dir_name)

            # Run git log command for commits in the last X days
            commits = run_command(f'git log --author="{author}" --since="{date_x_days_ago}" --oneline')

            # If there are commits, add them to the output
            if commits:
                output += f"Commits in {dir_name} in the last {days} days:\n"
                output += commits
                output += "\n\n"

            # Change back to the parent directory
            os.chdir('..')

    # Print the raw commit output
    if output:
        print("Raw commit information:")
        print(output)
        
        # Summarize commits using Claude
        # print("\nSummarized commit information:")
        # summary = summarize_commits(output)
        # print(summary)
    else:
        print(f"No commits by {author} in the last {days} days in any project.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check and summarize recent Git commits in multiple repositories.")
    parser.add_argument("directory", help="The directory containing Git repositories")
    parser.add_argument("--author", default="Brian Via", help="The author name to filter commits (default: Brian Via)")
    parser.add_argument("--days", type=int, default=1, help="Number of days to look back (default: 1)")
    
    args = parser.parse_args()
    
    main(args.directory, args.author, args.days)