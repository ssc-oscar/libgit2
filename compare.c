/*
 *This file compare the latest commit(HEAD) with the corresponding HEAD in the Database,
 *to identify whether the corresponding repository is updated.Then get the new commits
 */
#include <git2.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>

// This is the output on which sha is calculated: prepending commit %n\0
static void show_commit_body (git_commit *commit)
{
  unsigned int i, max_i;
  char oidstr[GIT_OID_HEXSZ + 1];
  git_oid_tostr(oidstr, sizeof(oidstr), git_commit_tree_id(commit));
  max_i = (unsigned int)git_commit_parentcount(commit);
  for (i = 0; i < max_i; ++i) {
    git_oid_tostr(oidstr, sizeof(oidstr), git_commit_parent_id(commit, i));
  }
  printf("%s", git_commit_raw_header(commit));
  if (git_commit_message_raw(commit))
    printf("\n%s", git_commit_message_raw(commit));

}

/** Helper to print a commit object. */
static void print_commit(git_commit *commit)
{
    char buf[300*(GIT_OID_HEXSZ + 1)];  
    char tidstr[GIT_OID_HEXSZ + 1];
    char cidstr[GIT_OID_HEXSZ + 1];
    const git_signature *sig;
    const char *scan, *eol;
    
    git_oid_tostr(tidstr, sizeof(tidstr), git_commit_tree_id(commit));
    size_t i, max_i = (unsigned int)git_commit_parentcount(commit);
    if (max_i > 299){
        fprintf (stderr, "too many parents: %ld\n", max_i);
        max_i = 299;
    }
    buf[0]=0;
    buf[1]=0;
    for (i = 0; i < max_i; ++i) {
        char oidstr[GIT_OID_HEXSZ + 1];
        git_oid_tostr (oidstr, sizeof(oidstr), git_commit_parent_id(commit, i));
        sprintf(buf+i*(GIT_OID_HEXSZ + 1),",%s", oidstr);
    }
    
        
    git_oid_tostr(cidstr, sizeof(cidstr), git_commit_id(commit));
    //printf("%s;%s;%s;%ld\n", cidstr, tidstr, buf+1, git_commit_time(commit));
    show_commit_body (commit);
    //printf("%s;%s;%s;%ld\n", cidstr, tidstr, buf+1, git_commit_time(commit));
}

void get_commits(git_commit *commit, long old_time, char *old_head)
{
    print_commit(commit);
    size_t i, parent_count = git_commit_parentcount(commit);
    for (i = 0; i < parent_count; i++) {
        char oidstr[GIT_OID_HEXSZ + 1];
        git_oid_tostr (oidstr, sizeof(oidstr), git_commit_parent_id(commit, i));
        if(strcmp(oidstr, old_head) == 0) {
            return;
        }
        git_commit *parent = NULL;
        git_commit_parent(&parent, commit, 0);
        if(git_commit_time(parent) > old_time) {
            get_commits(parent, old_time, old_head);
        }
    }
    return;
}

/*
 *input: the path, the new HEAD(commits) and the old HEAD(commits) in the Database,They are in the same line
 *and are splited with ','
 *for example: /home/kgao/Desktop/libgit2,585ee84b93b56787410773502ed80b1c17d3536c,48a9a056622bbaa5722570217084c6497074c860
 *output: all the new commits
 */
int main(int argc, char **argv)
{
    char *l0 = NULL;
    char seps[] = ",\n";
    size_t size = 0;

    git_libgit2_init();
    
    git_repository *repo;

    while(getline(&l0, &size, stdin) >= 0) {
        /*parse input into path, new HEAD, old HEAD*/
        char *path = strtok(l0, seps);
        printf("path: %s\n", path);
        char* new_head = strtok(NULL, seps);
        printf("new head: %s\n", new_head);
        char* old_head = strtok(NULL, seps);
        printf("old head: %s\n", old_head);
        if (strcmp(new_head, old_head) == 0) {
            printf("no update!\n");
            continue;
        }
        /*open the respository and get corresponding commit objects*/
        git_repository_open(&repo, path);
        
        git_object *obj = NULL;
        git_oid out;
        git_oid_fromstr(&out, new_head);
        int error_code = git_object_lookup(&obj, repo, &out, GIT_OBJ_COMMIT);
        if(error_code != 0) {
            printf("error code for new git_object: %d\n", error_code);
            exit(-1);
        }
        git_commit *commit = (git_commit *)obj;
        git_object_free(obj);
        
        git_object *obj1 = NULL;
        git_oid_fromstr(&out, old_head);
        error_code = git_object_lookup(&obj1, repo, &out, GIT_OBJ_COMMIT);
        if(error_code != 0) {
            printf("error code for old git_object: %d\n", error_code);
            exit(-1);
        }
        git_commit *old_commit = (git_commit *)obj1;
        git_object_free(obj1);
        
        /*get new commits*/
        long old_time = git_commit_time(old_commit);
        /*using Depth First Searrch to get new commits*/
        get_commits(commit, old_time, old_head);
        /*
        while((git_commit_time(commit) >= old_time ) && git_commit_parentcount(commit)) {
            print_commit(commit);
            size_t i, parent_count = git_commit_parentcount(commit);
            int flag = 0;
            for (i = 0; i < parent_count; i++) {
                char oidstr[GIT_OID_HEXSZ + 1];
                git_oid_tostr (oidstr, sizeof(oidstr), git_commit_parent_id(commit, i));
                //printf("%s, len: %d\n", oidstr, strlen(oidstr));
                if(strcmp(oidstr, old_head) == 0) {
                    printf("get all new commits\n");
                    flag = 1;
                    break;
                }
            }
            if (flag == 1) {
                break;
            }
            git_commit *parent = NULL;
            git_commit_parent(&parent, commit, 0);
            commit = parent;
        }
        */
    }
    git_remote_delete(repo, "origin");
    git_repository_free (repo);
    git_libgit2_shutdown ();
    return 0;
}
/*example:
 *echo /home/kgao/Desktop/libgit2,585ee84b93b56787410773502ed80b1c17d3536c,48a9a056622bbaa5722570217084c6497074c860 | ./compare
 *path: /home/kgao/Desktop/libgit2
 *new head: 585ee84b93b56787410773502ed80b1c17d3536c
 *old head: 48a9a056622bbaa5722570217084c6497074c860
 *tree e8157db6ed43cf07cee16cfb87284cb80559b6bc
 *parent 49ea204b37e8656fc229182f02f09641d7023014
 *author Audris Mockus <audris@utk.edu> 1540317580 -0400
 *committer Audris Mockus <audris@utk.edu> 1540317580 -0400
 *
 *working towards prepopulating head commits
 *tree 1d92818177d2eec44664a33494ba6d26ec3495c8
 *parent bddb9616daf45b557c65d55bc6cfe070cf2e5bb6
 *author Audris Mockus <audris@utk.edu> 1540314452 -0400
 *committer Audris Mockus <audris@utk.edu> 1540314452 -0400

 *adding object extraction/classification scripts
 *tree f454d2a814d773f7a44e4a0fadef230d25caa599
 *parent f31354070087075ffb1e2783752faf59bdce6ae8
 *author Audris Mockus <audris@utk.edu> 1540310636 -0400
 *committer Audris Mockus <audris@utk.edu> 1540310636 -0400
 *
 *adding initialization
 *tree d508d7321fc2e95adbfb7f23796eebd434d2f7e4
 *parent ad514a4a099303196cfdd1b1006f44b30dbd3411
 *author Audris Mockus <audris@utk.edu> 1539703503 -0400
 *committer Audris Mockus <audris@utk.edu> 1539703503 -0400
 *
 *added description
 *tree 680c3ca59809acd90e9f9258e22b861cc7083e65
 *parent 48a9a056622bbaa5722570217084c6497074c860
 *author Audris Mockus <audris@utk.edu> 1539703093 -0400
 *committer Audris Mockus <audris@utk.edu> 1539703093 -0400
 *
 *added description
 *get all new commits
 */