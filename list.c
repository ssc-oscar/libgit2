#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"
git_odb_foreach_cb cb(const git_oid *oid, void *repo) {
  char out [41];
  git_object *obj = NULL;
  out[40]=0;  
  git_oid_fmt(out, oid);
  int res = git_object_lookup (&obj, (git_repository *)repo, oid, GIT_OBJ_ANY);
  if (res){ 
     printf ("could not obj %s %d\n", out, res);
  }else{
     printf ("%s;%s\n", out, git_object_type2string(git_object_type(obj)));
     git_object_free (obj);
  }
  return 0;
}

int main(int argc, char *argv[])
{
  git_repository *repo;

  git_libgit2_init();
  if (check_lg2 (git_repository_open_bare(&repo, argv[1]),
		 "Could not open repository", argv[1]) != 0)
    exit (-1);

  git_odb *out;
  int res = git_repository_odb (&out, repo);
  if (res) printf ("could not odb %d\n", res);
  
  git_odb_foreach (out, &cb, repo);
  
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
