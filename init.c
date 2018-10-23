int main(int argc, char *argv[]){
  git_repository *repo = NULL;
  struct opts o = { 1, 0, 0, 0, GIT_REPOSITORY_INIT_SHARED_UMASK, 0, 0, 0 };

  git_threads_init();
  parse_opts(&o, argc, argv);
  if (o.no_options) {
    check_lg2(git_repository_init(&repo, o.dir, 0),
    "Could not initialize repository", NULL);
  }else{
    git_repository_init_options initopts = GIT_REPOSITORY_INIT_OPTIONS_INIT;
    initopts.flags = GIT_REPOSITORY_INIT_MKPATH;
    if (o.bare)
      initopts.flags |= GIT_REPOSITORY_INIT_BARE;
    if (o.template) {
      initopts.flags |= GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE;
      initopts.template_path = o.template;
    }
    if (o.gitdir) {
      initopts.workdir_path = o.dir;
      o.dir = o.gitdir;
    }
    if (o.shared != 0)
      initopts.mode = o.shared;
      check_lg2(git_repository_init_ext(&repo, o.dir, &initopts),
	"Could not initialize repository", NULL);
    }
  }
  if (!o.quiet) {
    if (o.bare || o.gitdir)
      o.dir = git_repository_path(repo);
    else
      o.dir = git_repository_workdir(repo);
    printf("Initialized empty Git repository in %s\n", o.dir);
  }
  if (o.initial_commit) {
    create_initial_commit(repo);
    printf("Created empty initial commit\n");
  }
  git_repository_free(repo);
  git_threads_shutdown();

  return 0;
}

static void create_initial_commit(git_repository *repo){
  git_signature *sig;
  git_index *index;
  git_oid tree_id, commit_id;
  git_tree *tree;
  if (git_signature_default(&sig, repo) < 0)
    fatal("Unable to create a commit signature.",
      "Perhaps 'user.name' and 'user.email' are not set");
  if (git_repository_index(&index, repo) < 0)
    fatal("Could not open repository index", NULL);

  if (git_index_write_tree(&tree_id, index) < 0)
    fatal("Unable to write initial tree from index", NULL);

  git_index_free(index);if (git_tree_lookup(&tree, repo, &tree_id) < 0)
  fatal("Could not look up initial tree", NULL);
  if (git_commit_create_v(&commit_id, repo, "HEAD", sig, sig,
			NULL, "Initial commit", tree, 0) < 0)
    fatal("Could not create the initial commit", NULL);git_tree_free(tree);
  git_signature_free(sig);
}

