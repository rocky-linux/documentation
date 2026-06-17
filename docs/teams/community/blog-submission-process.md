# Rocky Linux Blog Submission Process

This document covers the end-to-end process for writing and publishing a blog post to the Rocky Linux website, from idea to promotion.

---

## Project board

All blog work is tracked on the [Rocky Linux Community project board](https://github.com/orgs/rocky-linux/projects/14/views/2). Every post should have an issue before writing begins.

### Column definitions

| Status | Meaning |
|--------|---------| 
| **To Do** | Topic identified, needed information collected and documented, assigned to a writer |
| **In Progress** | Actively being written |
| **Blocked** | Waiting on another party for information or input |
| **Review** | Draft complete, in the community feedback process |
| **Approved** | All revisions complete, awaiting publication |
| **Done** | Published |

---

## Step-by-step process

### 1. Come up with a topic

Topics can come from anywhere: community needs, security events, release milestones, contributor stories, or survey feedback. If you have an idea, bring it to `~Community` on [Mattermost](https://chat.rockylinux.org) before creating an issue, especially if you're unsure whether it's already in progress.

### 2. Create an issue

Open an issue on the [project board](https://github.com/orgs/rocky-linux/projects/14/views/2). The issue title should clearly describe the post (e.g., "Blog: Contributor Spotlight: Jane Doe"). Set the status to **To Do** and assign a writer if one is already identified.

### 3. Write the draft

Write in Google Docs or another collaborative platform that supports comments and suggestions. This makes it easy for others to leave feedback before the post moves to GitHub.

Follow the style conventions established for Rocky Linux blog posts:

- Professional, friendly, and direct tone
- Sentence case for titles, no em dashes
- Hook opening, no filler phrases or present participle leads
- Inline code formatting for package names, commands, and repo references
- No excessive bolding or bullet overuse; use prose where it flows naturally

### 4. Revise

Spell check and grammar check the draft. Read it aloud if you need to catch awkward phrasing. Make sure all technical details (package names, version strings, CVE numbers, commands) are accurate and have not been paraphrased.

### 5. Post to Mattermost for feedback

Share the draft link in `~Community` on [Mattermost](https://chat.rockylinux.org) and ask for feedback. Move the issue to **Review** on the project board. Give the community a reasonable window to respond before moving forward.

### 6. Revise based on feedback

Incorporate feedback from the community review. If the post is waiting on input from a specific person or team, move the issue to **Blocked** until that information arrives.

### 7. Prepare the markdown file

Convert the final draft to a `.md` file following this structure:

**Frontmatter** (required, fences must be present):

title: "Post title in sentence case"

date: "YYYY-MM-DD"

author: "Your Name"

**Filename convention:**

YYYY-MM-DD-short-descriptive-slug.md

Place the file in the `news/` directory of the content repo.

### 8. Submit via GitHub

The content repository is [rocky-linux/rockylinux.org-content](https://github.com/rocky-linux/rockylinux.org-content).

1. Sync your fork using GitHub's **Sync fork** button before creating any new branch
2. Create a new branch named `news/your-post-slug`
3. Add your `.md` file to the `news/` directory
4. Open a pull request targeting `main` on `rocky-linux/rockylinux.org-content`
5. Add a brief plain-text description of the post in the PR body
6. Request a review from the appropriate technical or community reviewer
7. Address any review feedback and update the branch as needed
8. Move the issue to **Approved** once the PR is approved and ready to merge

### 9. Post-publication promotion

Once the post is live, ask the Community team in `~Community` on Mattermost to promote it on social channels (LinkedIn, Bluesky, Mastodon). Provide the published URL and any suggested copy if you have it.

Move the issue to **Done**.

---

## Tips

- Do not submit directly to `main` on the upstream repo; always work from a branch on your fork
- Verify frontmatter fences (`---`) are present in the raw file before submitting; they are easy to lose when copying from a rich text editor
- Double hyphens (`--`) are not a substitute for punctuation and must not appear outside of code blocks
- The `news/` directory uses the filename date as the publication date; make sure the frontmatter date and filename date match
