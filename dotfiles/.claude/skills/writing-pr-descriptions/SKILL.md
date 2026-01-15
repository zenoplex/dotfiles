---
name: writing-pr-descriptions
description: Voice guide for writing PR descriptions. Use this skill for ALL PR creation and updates (via gh CLI or editing existing PRs). Contains your specific voice rules, anti-patterns, examples, and workflow. Never write PR descriptions without invoking this skill first.
---

# Writing PR Descriptions

## ⚡ QUICK START

1. Check for project PR template: `.github/PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template.md`
2. If user has provided a PR then gather information from the PR via `gh pr` or else ask user for base branch
3. Gather changes: `git log origin/<base>..HEAD --oneline` and `git diff origin/<base>...HEAD --stat` (where `<base>` is the PR target branch, usually `main`)
4. Ask user for: Jira URL, Slack thread, screen recording (if UI)
5. Draft using voice rules below
6. Always use `--body-file` option to create or edit pr body with `gh` command

---

## Voice Guide

### Spirit

1. **Respect reviewer time** - Get to the point, then stop
2. **User-centric framing** - What problem does this solve for users?
3. **Show, don't tell** - Screen recordings > paragraphs of text
4. **Practical validation** - Teach reviewers like a tutorial

### Conciseness Rules

- **What section**: Include every significant change - no cap. Could be 2 bullets, could be 8. Whatever fits the PR.
- **Why section**: 1-3 bullets (not a paragraph). Focus on user benefit.
- **Validation**: 10 steps MAX. Narrative "Expect to..." style.

### Structure Requirements

- Start with `> [!NOTE]` callout if PR depends on another PR
- Include 🍿 screen recording for ANY UI changes
- Mention deployment timing if backend/frontend coordination needed
- Link actual Jira/Slack (ask user if not provided)

### Language Rules

- Concrete examples over jargon: "item with `_` separator" not "multi-entity composite perturbation"
- Frame "Why" around USER benefit, not technical constraints
- Validation reads like a tutorial: "Expect to see X"

### What NOT to Do

❌ Technical jargon when plain language works
❌ Listing any file changed
❌ Business rule explanations (put in code comments)
❌ "Comprehensive" descriptions - less is more
❌ Placeholder links - ask for real URLs
❌ Listing included commits
❌ Display target and source branch information
❌ Never include your commit

### Scope Discipline

- Focus on the FEATURE users will see
- Omit implementation wiring (threading params, type updates)
- If it's not visible to users or reviewers, skip it

---

## Template Handling

1. **Project template first** - Use `.github/PULL_REQUEST_TEMPLATE.md` as base
2. **Respect conventions** - Match their emoji style (✅ not 💪)
3. **Enhance sparingly** - Add sections only if project template is minimal

---

## Example: Good PR Description

```markdown
> [!NOTE]
> Builds on #142 to leverage its frontend helpers

## ✅ What

- Adds an "Include archived items" toggle to filter archived entries in/out of all views
- Includes a tooltip explaining what "archived items" are
- Hides the toggle completely if the current dataset doesn't have archived items
- Since this toggle won't appear until datasets with archived items are in prod, it's safe to deploy backend and frontend together

### 🍿 Screen recording of validation steps below

[video]

## 🤔 Why

- This dataset is the first appearance of archived items in the app
- While users gain an understanding of how to interpret these items, we want them to have the ability to hide them

## 🔖 Related links

- [Jira task](https://jira.example.com/browse/PROJ-123)
- [Slack thread](https://workspace.slack.com/archives/C12345/p1234567890)
```

### Why This Works

✅ Dependency callout at top
✅ Screen recording before text
✅ Deployment timing mentioned
✅ User-centric Why
✅ Concrete language
✅ Narrative validation (10 steps)
✅ Real links (not placeholders)

---

## PR Creation Commands

```bash
# Check for related issues
gh issue list --state open

# Create draft PR
gh pr create --draft --title "Title" --body "$(cat <<'EOF'
[PR body here]
EOF
)"

# View PR
gh pr view --web
```

---

## Process Checklist

- [ ] Read project PR template if exists
- [ ] Review all commits: `git log origin/<base>..HEAD` (where `<base>` is PR target)
- [ ] Review file changes: `git diff origin/<base>...HEAD --stat`
- [ ] Ask user for Jira/Slack links
- [ ] Ask user for screen recording (if UI change)
- [ ] Draft description using voice rules
- [ ] Check: Is "Why" user-centric?
- [ ] Check: Validation ≤10 steps?
- [ ] Check: No implementation details?
- [ ] Create draft PR via `gh pr create --draft`
- [ ] Return PR URL to user
