#include <git2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv)
{
  git_remote *remote = NULL;
  git_repository *repo;
  char * l0 = NULL;
  size_t size = 0;

  git_libgit2_init();

  char template[] = "/tmp/githead.XXXXXX";
  char *tmp_dirname = mkdtemp (template);

  if(!tmp_dirname)
    exit (-1);

  if (git_repository_init (&repo, tmp_dirname, 1) < 0){
    fprintf(stderr, "no repo\n");
    exit (-1);
  }

  while (getline (&l0, &size, stdin)>=0){
    strtok(l0, "\n");
    if (git_remote_create (&remote, repo, "origin", l0) < 0){
      fprintf (stderr, "can not add remote %s\n", l0);
      exit (-1);
    }
    //fprintf(stderr, "%s\n", l0);
 
    char * out, *l2 = NULL;
    if (git_get_last (remote, &out) < 0){
      fprintf (stdout , "%s;could not connect\n", l0);
    }else{	  
      fprintf(stdout, "%s;%s\n", l0, out);
      if (out) free (out);
    }
    git_remote_free(remote);
    git_remote_delete(repo, "origin");
  }
  char rm_command[56];
  strncpy (rm_command, "rm -rf ", 7 + 1);
  strncat (rm_command, tmp_dirname, strlen (tmp_dirname) + 1);
  system (rm_command);
  git_libgit2_shutdown();
  return 0;
}
