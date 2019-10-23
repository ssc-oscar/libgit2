Fork of libgit2 to do advanced synchronization with remotes using custom backents
==================================

The problem that is addressed is how to get the latest data from remote git repositories on a large
scale?

Git cli allows cloning repos where all objects are retrieved, or
fetch operation where only objects not in the current repo are
retrieved from remote. Since clooning all public repos in short time
is rather slow and inefficient we try another approach:



1. Detecting updated repos
1. Detecting new repos
1. Cloning new repos and extracting objects from the cloned repos
1. Fetching new objects from updated repos

The figure depicting the process is below
![workflow](https://raw.githubusercontent.com/ssc-oscar/libgit2/master/UpdateWorkflow.png)

Many ways to detect updated repos. An approach that is forge
agnostic is to rely on git itself.

Forge specific ways to identify updated repos include usage of
github, gitlab, bitbucket, etc APIs to retrieve the data as noted in
the chart above.

Identifying new repos always requires use of forge-specific APIs. 

The code here can be run on an individual cloud machine or 
on the ACF cluster.

This is focused on getting objects  that are noy in WoC yet
and assumes that we have identified new/updated repositories 
using code in swsc/gather container

The script provided here:
* captureObjects.sh clones the repositories and lists objects in them  
  checks witch objects are missing, and then extracts them


Another approach to do the same but in a batch mode can be accomplished (on, e.g., ACF)

* doA.sh - clones all repos in a list.XX (keep it < 50K) into Q.XX folder
* run.pbs - lists all objects in these repos
* run1.pbs  - extracts objects in the list todo (obtained by filtering the extracted objects against the ones in WoC)






TODO
____

With over 1B commits already collected, the new activity represents
but a small part of the entire database. Hence cloning updated
(and new) repositories is inefficient and slow.
40M URLs can be checked in 24 hours using git_last running in
parallel on 60 servers. The time to clone these would require months
and three orders of magnitude more more network bandwith and
storage.


What needs to be done is, as in case of git_last, insert
additional logic to git fetch protocol in order to use
custum backend that comprises git objects from all repositiories
and not from a single repository as git fetch assumes.
git_last implememnts the first step in git fetch protocol which
obtains the heads of the remote. The next step (comparing remotes to
what is locally available and sending the latest commits
corresponding to each updated head is yet to be implemented.

The database backend will take a project as a parameter and return the list of
heads. These heads needed to be sent to the remote so that it can
calculate of set of commits (and related trees/blobs) to transfer back.
