#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"

static void print_tree (git_tree *tree)
{
  size_t i, max_i = (int) git_tree_entrycount(tree);
  char tidstr[GIT_OID_HEXSZ + 1];
  char c = 0;
  git_oid_tostr (tidstr, sizeof(tidstr), git_tree_id (tree));
  printf("tree;%s;%ld;-----\n", tidstr,  max_i);
  for (i = 0; i < max_i; ++i) {
    const git_tree_entry * te = git_tree_entry_byindex (tree, i);
    const char * name = git_tree_entry_name (te);
    git_filemode_t mode = git_tree_entry_filemode_raw (te);
    git_otype type = git_tree_entry_type (te);
    const git_oid * id = git_tree_entry_id (te);
    char buf [10000];
    sprintf (buf, "%o %s", mode, name);
    fwrite (buf, 1, strlen (buf)+1, stdout);
    fwrite (id, 1, 20, stdout);
  }
  printf("\ntree;%s;%ld;-----\n", tidstr, max_i);
}

// Entry point for this command
int main(int argc, char *argv[])
{
  git_repository *repo;
  git_object *obj = NULL;

  git_libgit2_init();
  if (check_lg2 (git_repository_open_bare(&repo, argv[1]),
		 "Could not open repository", NULL) != 0)
    exit (-1);

  char *l0 = NULL;
  size_t size = 0;

  while (getline (&l0, &size, stdin)>=0){
    char* l1 = strdup (l0);
    l1 [strlen(l1)-1] = 0;
    git_tree * tree;
    if (obj != NULL) git_object_free(obj);
    if (check_lg2 (git_revparse_single(&obj, repo, l1),
		    "Could not resolve", l1) != 0) continue;    
    if (git_object_type (obj) == GIT_OBJ_TREE) {
      git_tree * tree = (git_tree*)obj;
      print_tree (tree);
    }
    free (l1);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
