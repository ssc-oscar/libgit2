#include <git2.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/stat.h>

int main(int argc, char **argv)
{
    char *l0 = NULL;
    char seps[] = ",\n";
    size_t size = 0;
    const char *cmsg;

    git_libgit2_init();
    
    git_repository *repo;
    git_remote *remote;
    git_fetch_options fetch_opts = GIT_FETCH_OPTIONS_INIT;
    const git_transfer_progress *stats;

    while(getline(&l0, &size, stdin) >= 0) {
        
        /*parse input into path, url, new HEAD, old HEAD*/
        char *path = strtok(l0, seps);
        printf("path: %s\n", path);
        char *url = strtok(NULL, seps);
        printf("url: %s\n", url);
        char* new_head = strtok(NULL, seps);
        printf("new head: %s\n", new_head);
        char* old_head = strtok(NULL, seps);
        printf("old head: %s\n", old_head);
        if (strcmp(new_head, old_head) == 0) {
            printf("no update!\n");
            continue;
        }
        
        /*open the respository and remote*/
        int error = 0;
        error = access(path, F_OK);
        /*if the dir doesn't exist, then create the dir and init the repository, add remote*/
        if(error < 0) {
            printf("can not open repository, create the dir: %s\n", path);
            error = mkdir(path, 0755);
            error = git_repository_init(&repo, path, 0);
            if (error < 0) {
                printf("init repository error!\n");
            }
            error = git_remote_create(&remote, repo, "origin", url);
            if(error < 0) {
                printf("add remote error!\n");
            }
            
        }
        /*if the dir exist, open the repository, add remote*/
        else {
            error = git_repository_open(&repo, path);
            if(error < 0) {
                error = git_repository_init(&repo, path, 0);
                if (error < 0) {
                    printf("init repository error!\n");
                }
                error = git_remote_create(&remote, repo, "origin", url);
                if(error < 0) {
                    printf("add remote error!\n");
                }
            }
            else {
                error = git_remote_lookup(&remote, repo, "origin");
                if(error < 0) {
                    printf("find remote error!\n");
                }
            }
        }

        //fetch from the remote
        error = git_remote_fetch(remote, NULL, &fetch_opts, NULL);
        if(error < 0) {
            printf("fetch error!\n");
        }
        //const git_transfer_progress *stats;
        stats = git_remote_stats(remote);
        printf("received bytes: %lu\n", stats->received_bytes);
        if (stats->local_objects > 0) {
            printf("\rReceived %d/%d objects in %lu bytes (used %d local objects)\n",
                stats->indexed_objects, stats->total_objects, stats->received_bytes, stats->local_objects);
        } else{
            printf("\rReceived %d/%d objects in %lu bytes\n",
            stats->indexed_objects, stats->total_objects, stats->received_bytes);
        }
        //get new commits
        git_oid new_oid, old_oid, oid;
        git_oid_fromstr(&new_oid, new_head);
        git_oid_fromstr(&old_oid, old_head);
        git_revwalk *walk;
        git_revwalk_new(&walk, repo);
        git_revwalk_sorting(walk, GIT_SORT_TOPOLOGICAL);
        git_revwalk_push(walk, &new_oid);
        git_revwalk_hide(walk, &old_oid);
        git_commit *wcommit;
        while((git_revwalk_next(&oid, walk)) == 0) {
            error = git_commit_lookup(&wcommit, repo, &oid);
            cmsg  = git_commit_message(wcommit);
            char name[GIT_OID_HEXSZ+1];
            git_oid_tostr(name, GIT_OID_HEXSZ+1, &oid);
            printf("%s: %s\n", name, cmsg);
            git_commit_free(wcommit);
        }
        git_revwalk_free(walk);
        git_repository_free(repo);
        git_remote_free(remote);   
    }

    
    git_libgit2_shutdown ();
    
    return 0;
}
/*
to test, I designed a example.First, I created a repository on GitHub, and wrote a README, 
then, I called the get_last to get a HEAD; Then I wrote some files directly on GitHub, and 
called the get_last to get another HEAD.
Then I input line 115, and get new commits(line 142-146);
*/
/*
The following is an example, line 115-135 is produced by libgit2:
kgao@ubuntu:~/Desktop/libgit2$ echo /home/kgao/Desktop/test,https://github.com/KayGau/test,85fe3383da23b8413eee3115cbaa847a5e3d45c4,f28c1efee11607f6d2dab8ed810a484e32fbe577 | ./get_new_commits
path: /home/kgao/Desktop/test
url: https://github.com/KayGau/test
new head: 85fe3383da23b8413eee3115cbaa847a5e3d45c4
old head: f28c1efee11607f6d2dab8ed810a484e32fbe577
can not open repository, create the dir: /home/kgao/Desktop/test
remote_download /home/kgao/Desktop/libgit2/src/remote.c:859
remote_download assert 1 /home/kgao/Desktop/libgit2/src/remote.c:863
remote_download opts /home/kgao/Desktop/libgit2/src/remote.c:869
remote_download opts 1 /home/kgao/Desktop/libgit2/src/remote.c:872
remote_download connected /home/kgao/Desktop/libgit2/src/remote.c:879
remote_download ls /home/kgao/Desktop/libgit2/src/remote.c:883
remote_download init /home/kgao/Desktop/libgit2/src/remote.c:887
remote_download refspecs (nil) 1 /home/kgao/Desktop/libgit2/src/remote.c:904
remote_download dwim 1 /home/kgao/Desktop/libgit2/src/remote.c:908
remote_download active refspecs 1 1 /home/kgao/Desktop/libgit2/src/remote.c:911
remote_download negotiate /home/kgao/Desktop/libgit2/src/remote.c:925
git_fetch_negotiate /home/kgao/Desktop/libgit2/src/fetch.c:163
filter_wants /home/kgao/Desktop/libgit2/src/fetch.c:103
filter_wants /home/kgao/Desktop/libgit2/src/fetch.c:128
filter_wants heads=2 /home/kgao/Desktop/libgit2/src/fetch.c:136
filter_wants head=0 local=0 id=85fe3383da23b8413eee3115cbaa847a5e3d45c4 name=HEAD /home/kgao/Desktop/libgit2/src/fetch.c:141
filter_wants head=1 local=0 id=85fe3383da23b8413eee3115cbaa847a5e3d45c4 name=refs/heads/master /home/kgao/Desktop/libgit2/src/fetch.c:141
git_fetch_negotiate need 1 /home/kgao/Desktop/libgit2/src/fetch.c:177
remote_download git_fetch_download_pack /home/kgao/Desktop/libgit2/src/remote.c:928
git_fetch_download_pack /home/kgao/Desktop/libgit2/src/fetch.c:211
git_fetch_download_pack need /home/kgao/Desktop/libgit2/src/fetch.c:215
85fe3383da23b8413eee3115cbaa847a5e3d45c4: Update README.md
388cf00b21f23f321509347df369db662dd68b41: Create raw4
bd5cb845e25ec967486175475caad097287c7033: Create raw 3
715f3afc76f9b17837410f4f12b4d19645c6eb1c: Create raw test 2
d22070fe80f293ffe43c51869eff702f6518d6ae: Create raw test
*/