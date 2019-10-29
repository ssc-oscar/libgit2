##drupal.com_ -> dr_ ? sf_7-zip-homepage -> git.code.sf.net_p/7-zip-homepage/code?; double check gl_ folders as gh; _ are wrong in some existing gl projects: gl_BackslashSoft_Framework_Modules_Resolver; android.googlesource.com_device[_/]; kde.org_->anongit.kde.org_; bioc_packages_vsn > git.bioconductor.org_admin/manifest; sf_sauron git.code.sf.net_p/berbox/code; git.eclipse.org_r_actf/org.eclipse.actf.examples.git/ git.eclipse.org_r/actf/org.eclipse.actf.examples.git/


while (<STDIN>){
	chop();
	($p, @rest) = split(/;/, $_, -1);
	$p =~ s/^drupal.com_/dr_/;
	$p =~ s|^git.code.sf.net_p/(.*)/code$|sf_$1|;
#git.code.sf.net_
	$p =~ s|^git.code.sf.net_p/(.*)/git$|sf_$1|;
	$p =~ s|^anongit.kde.org_|kde.org_|;
	$p =~ s|^git.bioconductor.org_|bioc_|;
	$p =~ s|^git.kernel.org_pub/scm/|git.kernel.org_|;
	$p =~ s|^git.postgresql.org_git|git.postgresql.org|;
	$p =~ s|^git.savannah.gnu.org_git(.*)\.git/|git.savannah.gnu.org$1.git_|;#also change existing ps git.savannah.gnu.org_3dldf.git_ by removing .git_
	$p =~ s|/$||;
	$p =~ s|/|_|;
	$p =~ s|\.git$||;
	$p .= ";". (join ';', @rest) if $#rest >= 0;
	print "$p\n";
}
