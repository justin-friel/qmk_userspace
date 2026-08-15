# Pi Git Workflow Cheat Sheet

## Remotes

Development machines:

```text
origin    Raspberry Pi
github    GitHub
```

For `qmk_firmware`, vendor remotes remain separate:

```text
origin      Raspberry Pi
github      Personal GitHub fork
massdrop    Massdrop upstream
keychron    Keychron upstream
```

Check:

```bash
git remote -v
```

## Branches

```text
main
    Baseline. Leave untouched.

justin-userspace-dev
    Development branch.
    Small commits.
    Push frequently to Pi.

justin-userspace
    Curated branch.
    Squashed history.
    Push to Pi, then GitHub.
```

## Normal Development

Work on the development branch:

```bash
git checkout justin-userspace-dev
```

Commit and push to the Pi:

```bash
git add <files> && git commit -m "Describe change" && git push
```

`git push` goes to the Pi because the branch tracks `origin/justin-userspace-dev`.

Check tracking:

```bash
git branch -vv
```

## Create a Curated Branch

### Before Committing the Curated Branch

**IMPORTANT:** The Pi Git workflow cheat sheet is private and must not be included in the public `justin-userspace` branch.

After `git merge --squash justin-userspace-dev`, remove it from the curated branch before committing:

```bash
git restore --staged docs/PI-GIT-WORKFLOW.md && git restore docs/PI-GIT-WORKFLOW.md
```

Then verify it is not included:

```bash
git status
```

Only after verifying that the private file is gone should the curated commit be created:

```bash
git commit -m "Describe completed work"
```

Start from `main`:

```bash
git checkout main && git checkout -b justin-userspace
```

Squash all development changes into the curated branch:

```bash
git merge --squash justin-userspace-dev
```

Review what will be committed:

```bash
git status && git diff --cached
```

Create the curated commit:

```bash
git commit -m "Describe completed work"
```

The result is:

```text
                    A--B--C--D--E
                   /              \
main -------------                  justin-userspace-dev
    \
     S
      \
       justin-userspace
```

`A-E` are the detailed development commits.

`S` is the single curated commit.

## Push Development Branch to Pi

First push:

```bash
git push -u origin justin-userspace-dev
```

Later pushes:

```bash
git push
```

## Push Curated Branch to Pi

```bash
git checkout justin-userspace && git push -u origin justin-userspace
```

The Pi now contains:

```text
justin-userspace-dev    detailed history
justin-userspace        curated history
```

## Push from Pi to GitHub

SSH to the Pi:

```bash
ssh rpi5-srv
```

For `qmk_userspace`:

```bash
git -C /srv/git/qmk_userspace.git push github justin-userspace
```

For `qmk_firmware`:

```bash
git -C /srv/git/qmk_firmware.git push github <branch>
```

Only the branch named in the command is pushed.

## Push Directly from Development Machine to GitHub

The Pi is the normal path, but it is not mandatory.

From the development machine:

```bash
git push github justin-userspace
```

This pushes the curated branch directly to GitHub.

## New Development Branch

Create it:

```bash
git checkout -b new-feature-dev
```

Publish it to `origin` (the Pi):

```bash
git push -u origin new-feature-dev
```

After that:

```bash
git push
```

goes to the Pi.

In VS Code, choose `origin` when **Publish Branch** asks for a remote.

## Rename a Development Branch

Rename locally:

```bash
git branch -m old-name new-name
```

Publish the new name to the Pi:

```bash
git push -u origin new-name
```

Delete the obsolete Pi branch after verifying the new one:

```bash
git push origin --delete old-name
```

## Replacing an Old Pi Branch with Squashed History

If the Pi already has a branch containing the detailed history and you intentionally want to replace that branch with the curated history, first make sure the detailed history is preserved under its `-dev` branch:

```bash
git push -u origin justin-userspace-dev
```

Then replace the old branch:

```bash
git push --force-with-lease -u origin justin-userspace
```

Do not `git pull` the old detailed history into the curated branch.

## Inspect Branches

```bash
git branch -vv
```

## Inspect the History

```bash
git log --oneline --graph --decorate --all --max-count=20
```

Expected structure:

```text
* S (justin-userspace)
| * E (justin-userspace-dev)
| * D
| * C
| * B
| * A
|/
* main
```

## Mental Model

```text
Development machine
        |
        | git push
        v
       Pi
      /  \
     /    \
-dev       curated
history    history
             |
             | explicit push
             v
           GitHub
```

Normal development:

```text
-dev branch -> origin -> Pi
```

Curated publication:

```text
-dev branch
    -> git merge --squash
    -> curated branch
    -> Pi
    -> GitHub
```

Remote names:

```text
origin = Pi
github = GitHub
```

Nothing automatically pushes to GitHub.