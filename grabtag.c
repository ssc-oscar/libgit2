#include <git2.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "common.h"

void show_tag (git_repository *repo, char * rname, char *oidstr, git_tag *tag)
{
  /* Emit the raw, canonical object bytes verbatim so the SHA-1 matches
     exactly.  Reconstructing the tag from parsed fields (git_tag_tagger,
     git_tag_message, ...) is lossy: libgit2 runs every signature name and
     email through extract_trimmed()/is_crud() (src/signature.c), which
     strips leading/trailing whitespace and any of  . , : ; < > " \ '  .
     A tagger such as "D.C.Y." comes back as "D.C.Y", yielding an object
     one byte short and a mismatched SHA-1.  Reading the raw object from the
     ODB sidesteps all libgit2 normalization. */
  printf ("repo;%s;%s;%s\n", rname, git_tag_name(tag), oidstr);

  git_odb *odb = NULL;
  git_odb_object *odbobj = NULL;
  if (git_repository_odb(&odb, repo) == 0 &&
      git_odb_read(&odbobj, odb, git_tag_id(tag)) == 0) {
    fwrite(git_odb_object_data(odbobj), 1, git_odb_object_size(odbobj), stdout);
    git_odb_object_free(odbobj);
  } else {
    fprintf(stderr, "could not read raw object for %s\n", oidstr);
  }
  if (odb)
    git_odb_free(odb);

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
	show_tag (repo, argv[1], l1, tag);
      }
    }
    free (l1);
  }
  
  git_repository_free (repo);
  git_libgit2_shutdown ();

  return 0;
}
