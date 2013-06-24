	if (!diff || !diff->repo)
		pi->oid_strlen = GIT_ABBREV_DEFAULT;
	else if (git_repository__cvar(
		&pi->oid_strlen, diff->repo, GIT_CVAR_ABBREV) < 0)
	else if (mode & 0100) /* -V536 */
	int (*strcomp)(const char *, const char *) =
		pi->diff ? pi->diff->strcomp : git__strcmp;
		strcomp(delta->old_file.path,delta->new_file.path) != 0)
	if (delta->old_file.path != delta->new_file.path)
	const char *oldpfx = pi->diff ? pi->diff->opts.old_prefix : NULL;
	const char *newpfx = pi->diff ? pi->diff->opts.new_prefix : NULL;
	uint32_t opts_flags = pi->diff ? pi->diff->opts.flags : GIT_DIFF_NORMAL;
		 (opts_flags & GIT_DIFF_INCLUDE_UNTRACKED_CONTENT) == 0))
	git_buf_printf(pi->buf, "diff --git %s%s %s%s\n",
		oldpfx, delta->old_file.path, newpfx, delta->new_file.path);