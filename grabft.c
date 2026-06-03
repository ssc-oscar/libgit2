#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"

static void print_tree (git_repository *repo, git_tree *tree)
{
  size_t max_i = git_tree_entrycount(tree);
  char tidstr[GIT_OID_HEXSZ + 1];
  git_oid_tostr (tidstr, sizeof(tidstr), git_tree_id (tree));
  printf("tree;%s;%ld;-----\n", tidstr,  max_i);

  /* Emit the raw, canonical object bytes verbatim so the SHA-1 matches
     exactly.  Reconstructing entries from parsed fields is lossy: the entry
     mode is recovered as an integer (git_tree_entry_filemode_raw) and
     reprinted with %o, so non-canonical stored mode text (e.g. a directory
     written as "040000" with a leading zero instead of "40000") cannot be
     reproduced, yielding a byte-different object and a mismatched SHA-1.
     Reading the raw object from the ODB sidesteps all such normalization. */
  git_odb *odb = NULL;
  git_odb_object *odbobj = NULL;
  if (git_repository_odb(&odb, repo) == 0 &&
      git_odb_read(&odbobj, odb, git_tree_id(tree)) == 0) {
    fwrite(git_odb_object_data(odbobj), 1, git_odb_object_size(odbobj), stdout);
    git_odb_object_free(odbobj);
  } else {
    fprintf(stderr, "could not read raw object for %s\n", tidstr);
  }
  if (odb)
    git_odb_free(odb);

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
      print_tree (repo, tree);
    }
    free (l1);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
