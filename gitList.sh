#!/bin/bash
dir=$1
{
    git --git-dir=$dir rev-list --objects --all
    git --git-dir=$dir rev-list --objects -g --no-walk --all
    git --git-dir=$dir rev-list --objects \
        $(git --git-dir=$dir fsck --unreachable |
          grep -E '^(unreachable|dangling) commit' |
          cut -d' ' -f3)
} |  LC_ALL=C LANG=C sort -T. -S 5G -u 
