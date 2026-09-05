#!/bin/bash
#
# Dotfiles deployment.
#
# Usage:
#   ./deploy.sh [OPTIONS] <MANIFEST>              deploy a manifest
#   ./deploy.sh --unlink [OPTIONS] <MANIFEST>     remove what a manifest deployed
#   ./deploy.sh --switch [OPTIONS] <OLD> <NEW>    unlink OLD, then deploy NEW
#
# Options:
#   -n, --dry-run   show what would be done, change nothing
#   -f, --force     replace existing targets (non-symlinks are backed up);
#                   on unlink, also remove unmodified copies
#   -u, --unlink    removal mode
#   -s, --switch    profile switch mode
#   -h, --help      show this help
#
# MANIFEST line format:
#
#   source|operation|target
#
#   source     path inside the repository
#   operation  symlink | copy | include
#   target     path relative to $HOME; if empty, defaults to <source>
#
# Because source and target are independent, several variants of the same
# config can live side by side in the repository and map onto the same
# location in $HOME. Example:
#
#   .config/nvim|symlink|                       # full config
#   profiles/min/nvim|symlink|.config/nvim      # simplified config
#
# The `include` operation pulls in another manifest, so profiles can share
# a common base:
#
#   MANIFEST.common|include|
#
# Lines starting with # and blank lines are ignored.
#
# Unlink never deletes anything it did not create: only symlinks that still
# point at the source recorded in the manifest are removed. Real files and
# foreign symlinks are reported and left alone.
#
# Switch is the clean way to change profiles: the old manifest is unlinked
# first, so no --force is needed and no .bak files are produced. Entries
# shared by both manifests are removed and recreated.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
FORCE=0
MODE=deploy
ERRORS=0
INCLUDE_STACK=()
# Paths a dry run pretends to have removed, so that the deploy phase of a
# dry-run switch does not report conflicts that would not happen for real.
VIRTUALLY_REMOVED=()

usage() {
    sed -n '3,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

log() {
    local level="$1"
    # in dry-run mode nothing is actually done, so say so
    case "$DRY_RUN$level" in
        1OK)      level="PLAN LINK" ;;
        1REMOVED) level="PLAN REMOVE" ;;
    esac
    printf '[%s] %s\n' "$level" "$2"
}

err()  { log ERROR "$1" >&2; ERRORS=$((ERRORS + 1)); }
run()  { if [ "$DRY_RUN" -eq 1 ]; then return 0; fi; "$@"; }

# isVirtuallyRemoved <path>
isVirtuallyRemoved() {
    local p
    for p in "${VIRTUALLY_REMOVED[@]+"${VIRTUALLY_REMOVED[@]}"}"; do
        [ "$p" = "$1" ] && return 0
    done
    return 1
}

# markRemoved <path>
markRemoved() {
    if [ "$DRY_RUN" -eq 1 ]; then
        VIRTUALLY_REMOVED+=("$1")
    fi
}

# pruneEmptyParent <path>
# Tidies up a directory left empty by a removal. Never touches $HOME itself
# and never complains if the directory is still in use.
pruneEmptyParent() {
    local dir
    dir="$(dirname "$1")"

    [ "$dir" = "$HOME" ] && return 0
    [ "$dir" = "/" ] && return 0

    if [ "$DRY_RUN" -eq 1 ]; then
        return 0
    fi

    rmdir "$dir" 2>/dev/null && log PRUNE "removed empty $dir"
    return 0
}

# backupTarget <path>
# Moves an existing non-symlink target aside instead of destroying it.
backupTarget() {
    local dst="$1"
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"

    log BACKUP "$dst -> $backup"
    run mv "$dst" "$backup"
}

# prepareTarget <destination> <expected-source>
# Returns 0 if the caller should proceed, 1 if it should skip the entry.
prepareTarget() {
    local dst="$1" src="$2"

    if isVirtuallyRemoved "$dst"; then
        return 0
    fi

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            log SKIP "$dst already points to $src"
            return 1
        fi

        if [ "$FORCE" -eq 0 ]; then
            err "$dst is a symlink to $(readlink "$dst"), expected $src (use --switch or --force)"
            return 1
        fi

        log REPLACE "$dst (was -> $(readlink "$dst"))"
        run rm -f "$dst"
        return 0
    fi

    if [ -e "$dst" ]; then
        if [ "$FORCE" -eq 0 ]; then
            err "$dst exists and is not a symlink (use --force to back it up and replace)"
            return 1
        fi

        backupTarget "$dst"
        return 0
    fi

    return 0
}

symlinkFile() {
    local src="$SCRIPT_DIR/$1"
    local dst="$HOME/$2"

    if [ ! -e "$src" ]; then
        err "source $src does not exist"
        return
    fi

    prepareTarget "$dst" "$src" || return

    run mkdir -p "$(dirname "$dst")"
    if run ln -s "$src" "$dst"; then
        log OK "$src -> $dst"
    else
        err "failed to symlink $src -> $dst"
    fi
}

copyFile() {
    local src="$SCRIPT_DIR/$1"
    local dst="$HOME/$2"

    if [ ! -e "$src" ]; then
        err "source $src does not exist"
        return
    fi

    if { [ -e "$dst" ] || [ -L "$dst" ]; } && ! isVirtuallyRemoved "$dst"; then
        if [ "$FORCE" -eq 0 ]; then
            err "$dst exists (use --force to back it up and overwrite)"
            return
        fi
        backupTarget "$dst"
    fi

    run mkdir -p "$(dirname "$dst")"
    if run cp -R "$src" "$dst"; then
        log OK "$src => $dst (copy)"
    else
        err "failed to copy $src => $dst"
    fi
}

unlinkSymlink() {
    local src="$SCRIPT_DIR/$1"
    local dst="$HOME/$2"

    if [ -L "$dst" ]; then
        local actual
        actual="$(readlink "$dst")"

        if [ "$actual" != "$src" ]; then
            log SKIP "$dst points to $actual, not managed by this manifest"
            return
        fi

        if run rm -f "$dst"; then
            log REMOVED "$dst (was -> $src)"
            markRemoved "$dst"
            pruneEmptyParent "$dst"
        else
            err "failed to remove $dst"
        fi
        return
    fi

    if [ ! -e "$dst" ]; then
        log SKIP "$dst is not deployed"
        return
    fi

    log WARNING "$dst is not a symlink, leaving it alone"
}

unlinkCopy() {
    local src="$SCRIPT_DIR/$1"
    local dst="$HOME/$2"

    if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
        log SKIP "$dst is not deployed"
        return
    fi

    if [ "$FORCE" -eq 0 ]; then
        log WARNING "$dst is a copy, leaving it alone (use --force to remove it)"
        return
    fi

    # A copy may have been edited in place; never discard local changes.
    if ! diff -r -q "$src" "$dst" >/dev/null 2>&1; then
        log WARNING "$dst differs from $src, leaving it alone"
        return
    fi

    if run rm -rf "$dst"; then
        log REMOVED "$dst (copy of $src)"
        markRemoved "$dst"
        pruneEmptyParent "$dst"
    else
        err "failed to remove $dst"
    fi
}

# walkManifest <manifest> <symlink-handler> <copy-handler>
walkManifest() {
    local manifest="$1" onSymlink="$2" onCopy="$3"
    local path="$SCRIPT_DIR/$manifest"
    local entry src op dst

    if [ ! -f "$path" ]; then
        err "manifest $path not found"
        return
    fi

    for entry in "${INCLUDE_STACK[@]+"${INCLUDE_STACK[@]}"}"; do
        if [ "$entry" = "$manifest" ]; then
            err "circular include detected: $manifest"
            return
        fi
    done
    INCLUDE_STACK+=("$manifest")

    log MANIFEST "$manifest"

    local -a lines=()
    mapfile -t lines < "$path"

    for entry in "${lines[@]+"${lines[@]}"}"; do
        entry="${entry%$'\r'}"

        # strip surrounding whitespace
        entry="${entry#"${entry%%[![:space:]]*}"}"
        entry="${entry%"${entry##*[![:space:]]}"}"

        [ -z "$entry" ] && continue
        [[ "$entry" == \#* ]] && continue

        IFS='|' read -r src op dst <<< "$entry"

        src="${src:-}"; op="${op:-}"; dst="${dst:-}"
        dst="${dst:-$src}"

        if [ -z "$src" ]; then
            err "malformed line in $manifest: $entry"
            continue
        fi

        case "$op" in
            symlink) "$onSymlink" "$src" "$dst" ;;
            copy)    "$onCopy" "$src" "$dst" ;;
            include) walkManifest "$src" "$onSymlink" "$onCopy" ;;
            "")      err "missing operation in $manifest: $entry" ;;
            *)       log WARNING "unknown operation '$op' in $manifest, skipping: $entry" ;;
        esac
    done

    unset 'INCLUDE_STACK[-1]'
}

deployManifest() { walkManifest "$1" symlinkFile copyFile; }
unlinkManifest() { walkManifest "$1" unlinkSymlink unlinkCopy; }

MANIFESTS=()

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1 ;;
        -f|--force)   FORCE=1 ;;
        -u|--unlink)  MODE=unlink ;;
        -s|--switch)  MODE=switch ;;
        -h|--help)    usage; exit 0 ;;
        --)           shift; MANIFESTS+=("$@"); break ;;
        -*)           echo "ERROR: unknown option $1" >&2; usage >&2; exit 2 ;;
        *)            MANIFESTS+=("$1") ;;
    esac
    shift
done

expected=1
[ "$MODE" = switch ] && expected=2

if [ "${#MANIFESTS[@]}" -ne "$expected" ]; then
    usage >&2
    if [ "$MODE" = switch ]; then
        echo "ERROR: --switch needs exactly two manifests: <OLD> <NEW>" >&2
    elif [ "${#MANIFESTS[@]}" -eq 0 ]; then
        echo "ERROR: no MANIFEST file is provided" >&2
    else
        echo "ERROR: expected one manifest, got ${#MANIFESTS[@]}" >&2
    fi
    exit 2
fi

if [ "$DRY_RUN" -eq 1 ]; then
    log INFO "dry run, no changes will be made"
fi

case "$MODE" in
    deploy)
        deployManifest "${MANIFESTS[0]}"
        ;;

    unlink)
        unlinkManifest "${MANIFESTS[0]}"
        ;;

    switch)
        if [ "${MANIFESTS[0]}" = "${MANIFESTS[1]}" ]; then
            echo "ERROR: refusing to switch ${MANIFESTS[0]} to itself" >&2
            exit 2
        fi

        log INFO "switching ${MANIFESTS[0]} -> ${MANIFESTS[1]}"

        unlinkManifest "${MANIFESTS[0]}"

        if [ "$ERRORS" -gt 0 ]; then
            log FAILED "$ERRORS error(s) while unlinking ${MANIFESTS[0]}, not deploying ${MANIFESTS[1]}"
            exit 1
        fi

        deployManifest "${MANIFESTS[1]}"
        ;;
esac

if [ "$ERRORS" -gt 0 ]; then
    log FAILED "$ERRORS error(s), see messages above"
    exit 1
fi

case "$MODE" in
    deploy) log DONE "manifest ${MANIFESTS[0]} deployed" ;;
    unlink) log DONE "manifest ${MANIFESTS[0]} unlinked" ;;
    switch) log DONE "switched ${MANIFESTS[0]} -> ${MANIFESTS[1]}" ;;
esac

