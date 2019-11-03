#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"

char * path;

git_odb_foreach_cb cb(const git_oid *oid, void *repo) {
  char out [41];
  git_object *obj = NULL;
  out[40]=0;  
  git_oid_fmt(out, oid);
  int res = git_object_lookup (&obj, (git_repository *)repo, oid, GIT_OBJ_ANY);
  if (res){ 
     fprintf (stderr, "could not obj %s %s %d\n", path, out, res);
  }else{
     printf ("%s;%s;%s\n", path, git_object_type2string(git_object_type(obj)), out);
     git_object_free (obj);
  }
  return 0;
}

int main(int argc, char *argv[])
{
  git_repository *repo;

  git_libgit2_init();

  path = argv[1];
  if (check_lg2 (git_repository_open_bare(&repo, argv[1]),
		 "Could not open repository", argv[1]) != 0)
    exit (-1);

  git_odb *out;
  int res = git_repository_odb (&out, repo);
  if (res){
    fprintf (stderr, "could not odb %s %d\n", path, res);
  }else{  
    git_odb_foreach (out, &cb, repo);
    git_odb_free (out);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
