# QMK Vendor Repository Workflow

This setup uses one local QMK repository to work with:

- My GitHub fork of standard QMK
- Massdrop’s QMK fork
- Keychron’s QMK fork

A second clone is not required.

## Repository location

```bash
cd ~/src/qmk/qmk_firmware
```

## Remotes

A remote is a saved address for a GitHub repository.

```text
origin     My GitHub fork
massdrop   Massdrop’s QMK fork
keychron   Keychron’s QMK fork
```

View the configured remotes:

```bash
git remote -v
```

Expected addresses:

```text
origin     https://github.com/justin-friel/qmk_firmware.git
massdrop   https://github.com/Massdrop/qmk_firmware.git
keychron   https://github.com/Keychron/qmk_firmware.git
```

## Initial setup

The repository was originally cloned from my GitHub fork:

```bash
git clone https://github.com/justin-friel/qmk_firmware.git
cd qmk_firmware
```

The vendor repositories were then added as remotes:

```bash
git remote add massdrop https://github.com/Massdrop/qmk_firmware.git
git remote add keychron https://github.com/Keychron/qmk_firmware.git
```

Adding a remote only saves its address. It does not download anything or change the current files.

## Fetching vendor code

Fetch Massdrop:

```bash
git fetch massdrop
```

Fetch Keychron:

```bash
git fetch keychron
```

Fetching downloads commits and updates remote-tracking branches. It does not merge anything or change the checked-out files.

Use `fetch`, not `pull`, when retrieving vendor code. `pull` also tries to merge the retrieved code into the current branch.

To remove references to branches that the vendor has deleted:

```bash
git fetch massdrop --prune
git fetch keychron --prune
```

## Viewing branches

List local branches:

```bash
git branch
```

List Massdrop’s fetched branches:

```bash
git branch -r --list 'massdrop/*'
```

List Keychron’s fetched branches:

```bash
git branch -r --list 'keychron/*'
```

Find a remote’s default branch:

```bash
git remote show massdrop
git remote show keychron
```

Look for the `HEAD branch` line.

## Local branches

The current local branches are:

```text
master                 Standard QMK from my original fork
massdrop-master        Massdrop ALT and CTRL
keychron-k2-he         Keychron K2 HE
keychron-k10-pro       Keychron K10 Pro
```

Their vendor starting points are:

```text
massdrop-master        massdrop/master
keychron-k2-he         keychron/2025q3
keychron-k10-pro       keychron/wls_2025q1
```

They were created with:

```bash
git checkout -b massdrop-master massdrop/master
git checkout -b keychron-2025q3 keychron/2025q3
git checkout -b keychron-wls-2025q1 keychron/wls_2025q1
```

The Keychron branches were then renamed:

```bash
git branch -m keychron-2025q3 keychron-k2-he
git branch -m keychron-wls-2025q1 keychron-k10-pro
```

## Switching branches

Switch to standard QMK:

```bash
git checkout master
```

Switch to Massdrop:

```bash
git checkout massdrop-master
```

Switch to the Keychron K2 HE:

```bash
git checkout keychron-k2-he
```

Switch to the Keychron K10 Pro:

```bash
git checkout keychron-k10-pro
```

Switching branches changes the working files to the version stored on that branch.

Before switching, check for uncommitted changes:

```bash
git status
```

## Saving changes locally

Check the current branch:

```bash
git branch --show-current
```

Review changes:

```bash
git status
git diff
```

Stage and commit the intended files:

```bash
git add <files>
git commit -m "Describe the change"
```

A commit saves changes in the local repository. It does not automatically send them to GitHub.

## First push to my GitHub fork

Vendor branches may initially track branches in the vendor repositories. Do not try to push changes to Massdrop or Keychron.

Push each local branch explicitly to `origin`, which is my GitHub fork:

```bash
git push -u origin massdrop-master
git push -u origin keychron-k2-he
git push -u origin keychron-k10-pro
```

The `-u` option makes the new branch on `origin` the local branch’s upstream tracking branch.

After the first push, verify the tracking relationships:

```bash
git branch -vv
```

The branches should show `origin/...`, not `massdrop/...` or `keychron/...`.

## Later pushes

After a branch has been pushed with `-u origin`, switch to it and use:

```bash
git push
```

Example:

```bash
git checkout keychron-k2-he
git push
```

## Fetching later vendor updates

Fetching updates the vendor reference but does not alter the local working branch:

```bash
git fetch massdrop --prune
git fetch keychron --prune
```

For example:

```text
massdrop/master
keychron/2025q3
keychron/wls_2025q1
```

Updating a working branch from a newer vendor branch is a separate operation. Review the differences before merging or rebasing:

```bash
git log --oneline HEAD..massdrop/master
git diff HEAD..massdrop/master
```

Do not merge vendor updates blindly, especially after adding shared keymaps or other customizations.

## Important distinction

The remotes have different purposes:

```text
origin      Push my work here
massdrop    Fetch Massdrop code from here
keychron    Fetch Keychron code from here
```

Normal workflow:

```text
Fetch vendor code → work on a local branch → commit → push to origin
```

Do not push custom work to `massdrop` or `keychron`.