#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"


static void print_signature(const char *header, const git_signature *sig)
{
  char sign;
  int offset, hours, minutes;

  if (!sig)
    return;

  offset = sig->when.offset;
  if (offset < 0) {
    sign = '-';
    offset = -offset;
  } else {
    sign = '+';
  }

  hours   = offset / 60;
  minutes = offset % 60;

  printf("%s %s <%s> %ld %c%02d%02d\n",
       header, sig->name, sig->email, (long)sig->when.time,
       sign, hours, minutes);
}


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
  printf("%s;%s;%s;%ld\n", cidstr, tidstr, buf+1, git_commit_time(commit));
  show_commit_body (commit);
  printf("%s;%s;%s;%ld\n", cidstr, tidstr, buf+1, git_commit_time(commit));
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
    if (obj != NULL) git_object_free(obj);
    if (check_lg2(git_revparse_single(&obj, repo, l1), "Could not resolve", l1) != 0){
    }else{
      if (git_object_type (obj) == GIT_OBJ_COMMIT) {
        git_commit *commit = (git_commit*)obj;
        print_commit (commit);
      }
    }
    free (l1);
  }
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
