---
name: git-workflow
description: Automate git branching, staging, committing, and pushing for code changes. Use this skill whenever you finish implementing a feature, fix, or set of changes and need to commit them. Also use when the user asks to commit, push, create a branch, or stage changes. This skill ensures every set of changes gets a dedicated feature branch, logically grouped commits with conventional commit messages, and is pushed to the remote.
---

# Git Workflow

When committing changes after completing work, follow this process every time.

## 1. Create a feature branch

Branch from the current HEAD with a descriptive name:

```
git checkout -b <type>/<short-description>
```

Branch name conventions:
- `feature/` — new functionality (e.g. `feature/calendar-day-view`)
- `fix/` — bug fixes (e.g. `fix/dateformat-locale`)
- `chore/` — maintenance, config, deps (e.g. `chore/gitignore-env`)
- `docs/` — documentation only (e.g. `docs/status-update`)

Keep names lowercase, hyphen-separated, concise.

## 2. Group changes into logical commits

Review all unstaged/staged changes and group them by concern. Each commit should represent one logical unit of work. Common groupings:

- **Dependencies** — `pubspec.yaml`, lockfiles, `Podfile.lock`
- **Config/infra** — `.gitignore`, build config, CI
- **Data/schema** — database migrations, ARB/l10n files, generated code
- **Feature code** — the actual implementation files
- **Docs** — `README.md`, `STATUS.md`, comments

Stage and commit each group separately, in dependency order (foundations first, features last).

## 3. Write conventional commit messages

Follow the conventional commits format:

```
<type>(<scope>): <concise imperative description>

<optional body — explain what and why, not how>

Co-Authored-By: Oz <oz-agent@warp.dev>
```

Types: `feat`, `fix`, `chore`, `docs`, `deps`, `refactor`, `test`, `style`

The subject line should be:
- Imperative mood ("add", not "added" or "adds")
- Lowercase after the colon
- No period at the end
- Under 72 characters

The body (if needed) should explain **why** the change was made, not repeat what the diff shows. Wrap at 72 characters.

Always include the `Co-Authored-By: Oz <oz-agent@warp.dev>` line at the end.

## 4. Push and report

Push the branch to the remote:

```
git push -u origin <branch-name>
```

After pushing, briefly summarize what was committed (number of commits, branch name).

## 5. Rebuild before committing (when applicable)

If changes include code that runs in a simulator or dev server, rebuild and launch the app **before** creating the branch and committing, so the user can verify the changes work. Only proceed with branching/committing after the build succeeds or the user confirms.

## Example flow

```
# 1. Verify build works
flutter run -d <device>

# 2. Branch
git checkout -b feature/calendar-views

# 3. Commit in groups
git add lib/l10n/app_en.arb lib/l10n/app_ja.arb lib/l10n/app_localizations*.dart
git commit -m "feat(l10n): add calendar view localization keys

Add month, week, day, allDay, and noTime keys for en/ja.
Regenerate localization classes.

Co-Authored-By: Oz <oz-agent@warp.dev>"

git add lib/features/calendar/calendar_screen.dart
git commit -m "feat(calendar): add month, week, and day view switcher

Add SegmentedButton to toggle between month, week, and day views.
Day view shows a navigable date header with detailed event timeline.
Week view uses table_calendar in week format. All DateFormat calls
pass the active locale.

Co-Authored-By: Oz <oz-agent@warp.dev>"

# 4. Push
git push -u origin feature/calendar-views
```
