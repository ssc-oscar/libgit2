#include <git2.h>
#include <stdio.h>
#include "common.h"

static void print_blob (const git_blob *blob, char *rname, char * hex, char * fname)
{
  //fprintf (stderr, "%s;%s;%d\n", oidstr, f, isBin);
  if (!git_blob_is_binary (blob)){
    size_t bsize = git_blob_rawsize(blob);
    printf ("%s;%s;%s;%ld\n", hex, rname, fname, bsize);
    fwrite (git_blob_rawcontent(blob), bsize, 1, stdout);
    printf ("\n%s;%s;%s;%lu\n", hex, rname, fname, bsize);
  }
}

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
    strtok(l1, ";");
    char * l2 = strtok(NULL, ";");
    if (obj != NULL) git_object_free(obj);
    if (check_lg2(git_revparse_single(&obj, repo, l1),
		  "Could not resolve", l1) != 0){
    }else{
      if (git_object_type (obj) == GIT_OBJ_BLOB) {
	git_blob *blob = (git_blob*)obj;
	print_blob (blob, argv[1], l1, l2);
      }
    }
    free (l1);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}



