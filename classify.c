#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"

int main(int argc, char *argv[])
{
  git_repository *repo;
  git_object *obj = NULL;

  git_libgit2_init();
  if (check_lg2 (git_repository_open_bare(&repo, argv[1]),
		 "Could not open repository", argv[1]) != 0)
    exit (-1);

  size_t size = 0;
  char *l0 = NULL;

  while (getline(&l0, &size, stdin)>=0){
    char* l1 = strdup (l0);
    l1 [strlen(l1)-1] = 0;
	 strtok(l1, " ");
	 char * l2 = strtok(NULL, " ");
    if (obj != NULL) git_object_free (obj);
    if (check_lg2 (git_revparse_single(&obj, repo, l1),
		   "Could not resolve", l1) != 0) continue;
	 if (l2)
    	printf ("%s;%s;%s;%s\n", argv[1], git_object_type2string(git_object_type (obj)), l1, l2);
	 else
	   printf ("%s;%s;%s\n", argv[1], git_object_type2string(git_object_type (obj)), l1);
    free (l1);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
