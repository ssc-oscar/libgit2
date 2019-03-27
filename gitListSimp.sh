#!/bin/bash
dir=$1
{
    git --git-dir=$dir rev-list --objects --all
}  

