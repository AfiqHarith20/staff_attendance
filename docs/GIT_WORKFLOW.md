# Mobile Team Git Workflow Guide

> Branching & release process for the mobile app — Version 1.0

---

## 1. Overview

Use a simple one-branch workflow (based on **GitHub Flow**). Easy to follow, easy to manage.

> **GOLDEN RULE**
> `main` always reflects what's currently live in production. Nobody commits to `main` directly — all changes come in through a Pull Request (PR).

---

## 2. Branch Structure

| Branch | Purpose | Example |
|--------|---------|---------|
| `main` | Production-ready code. Always deployable. | `main` |
| `feature/...` | New features | `feature/push-notification` |
| `fix/...` | Bug fixes | `fix/login-crash` |
| `chore/...` | Config, deps, refactors | `chore/update-gradle` |

---

## 3. Daily Workflow

### Step 1 — Start from `main`

Always branch off the latest `main`, never off another feature branch.

```bash
git checkout main
git pull origin main
git checkout -b feature/push-notification
```

### Step 2 — Do the work

Implement and commit as you go, with clear messages.

```bash
git add .
git commit -m "feat: add push notification permission flow"
```

**Commit prefix conventions:**

| Prefix | Use for |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `chore:` | Config, deps, cleanup |
| `docs:` | Documentation only |

### Step 3 — Push and open a PR

```bash
git push origin feature/push-notification
```

Then open a Pull Request on GitHub targeting `main`. Fill in:
- What changed
- How it was tested
- Screenshots (if UI change)

### Step 4 — Review

Since we don't have CI/CD yet, the reviewer is our safety net. The reviewer must:

- [ ] Pull the branch and **run it locally** — not just read the diff
- [ ] Confirm no merge conflicts with `main`
- [ ] Approve only once it runs correctly

### Step 5 — Merge

Use **Squash and Merge**. This keeps `main`'s history clean — one commit per feature/fix, easy to scan later.

> **TIP:** The squash merge commit message = your changelog entry.
> Write it like: `feat: add push notification permission flow (#23)`

### Step 6 — Clean up

Delete the feature branch after merging. GitHub shows a "Delete branch" button right after merge.

---

## 4. Building & Releasing (Manual)

Always build from `main`, never from a feature branch. This ensures what you build matches what's actually merged.

### Before merging a PR

- [ ] Reviewer pulled the branch and ran it locally
- [ ] No merge conflicts with `main`
- [ ] Dev confirms manual test passed

### Before building from `main`

- [ ] Smoke test core app flows (see below)
- [ ] Tag the commit with a version number

### Smoke Test Checklist

Run through these quickly after every build to confirm nothing is broken. This is **not** a full regression test.

- [ ] App launches without crashing
- [ ] Sign up works
- [ ] Login works
- [ ] Main/home screen loads correctly
- [ ] The new feature or fix just merged works as expected

### Tagging a release

After a successful build, tag it. This is your record of exactly what's in production.

```bash
git tag -a v1.4.2 -m "Release 1.4.2"
git push origin v1.4.2
```

---

## 5. Full Example Walkthrough

**Scenario:** Abu needs to fix a login crash bug.

```bash
# 1. Start from latest main
git checkout main
git pull origin main

# 2. Create fix branch
git checkout -b fix/login-crash

# 3. Make changes, commit
git add .
git commit -m "fix: handle null token on login screen"

# 4. Push branch
git push origin fix/login-crash

# 5. Open PR: fix/login-crash -> main
#    Teammate pulls branch, tests locally, approves

# 6. Squash merge PR into main via GitHub UI

# 7. Delete fix/login-crash branch

# 8. Build from main, tag release
git checkout main
git pull origin main
git tag -a v1.4.3 -m "Release 1.4.3 - fix login crash"
git push origin v1.4.3
```

---

## 6. Quick Reference Cheat Sheet

| Situation | What to do |
|-----------|-----------|
| Starting new work | Branch from latest `main` |
| Naming a branch | `feature/...`, `fix/...`, `chore/...` |
| Ready for review | Push branch, open PR to `main` |
| Reviewing a PR | Pull & run locally before approving |
| Merging a PR | **Squash and Merge** |
| After merge | Delete the branch |
| Building the app | Always build from `main` |
| After a successful build | Tag it + update `CHANGELOG.md` |
| Mid-release | Freeze merges to `main` until build is done |

---

*This is a living document and may be updated as our processes evolve. Suggestions, feedback, and questions are always welcome.*
