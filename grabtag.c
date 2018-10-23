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

void show_tag (char * rname, char *oidstr, git_tag *tag)
{
  char tidstr [GIT_OID_HEXSZ + 1];
  git_oid_tostr (tidstr, sizeof(tidstr), git_tag_target_id(tag));
  printf ("repo;%s;%s;%s\n", rname, git_tag_name(tag), oidstr); 
  printf("object %s\n", tidstr);
  printf("type %s\n", git_object_type2string(git_tag_target_type(tag)));
  printf("tag %s\n", git_tag_name(tag));
  print_signature("tagger", git_tag_tagger(tag));  
  if (git_tag_message(tag))
    printf("\n%s", git_tag_message(tag));
  printf ("repo;%s;%s;%s\n", rname, git_tag_name(tag), oidstr); 
}

  
int main(int argc, char *argv[])
{
  git_repository *repo;
  git_object *obj = NULL;

  git_libgit2_init();
  if (check_lg2 (git_repository_open_bare(&repo, argv[1]),
		 "Could not open repository", NULL) != 0)
    exit (-1);
  
  size_t size = 0;
  char *l0 = NULL;
  while (getline(&l0, &size, stdin)>=0){
    char* l1 = strdup (l0);
    l1 [strlen(l1)-1] = 0;
    if (obj != NULL) git_object_free(obj);
    if (check_lg2(git_revparse_single(&obj, repo, l1),
		  "Could not resolve", l1) != 0){
    }else{
      if (git_object_type (obj) == GIT_OBJ_TAG){
	git_tag *tag = (git_tag*)obj;
	show_tag (argv[1], l1, tag);
      }
    }
    free (l1);
  }
  
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
