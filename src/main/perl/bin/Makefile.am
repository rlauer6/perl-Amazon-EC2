SUBDIRScd = .

perlrun = @PERL@

# you should be using perl5libdir as the base target of your perl
# modules, not as simply part of your PERLINCLUDE
perl5libdir = @perl5libdir@
ax_perl5_extra_includes_opt = @ax_perl5_extra_includes_opt@

# this is where we will install perl scripts
libexecdir = @libexecdir@
spooldir = @localstatedir@/spool

PERLSCRIPTS = \
    ec2-example.pl.in

GPERLSCRIPTS = $(PERLSCRIPTS:.pl.in=.pl)

# libexec_SCRIPTS = $(GPERLSCRIPTS)
dist_noinst_DATA = $(PERLSCRIPTS)

@do_subst_command@


if USING_PERL5_EXTRA_INCLUDES
PERL5_EXTRA_INCLUDES = $(ax_perl5_extra_includes_opt)
else
endif

PERLINCLUDE = \
    -I $(builddir) \
    -I ../$(builddir)/lib \
    $(PERL5_EXTRA_INCLUDES) \
    -I $(perl5libdir)

$(GPERLSCRIPTS): % : %.in
	test -d "$$(dirname "$@")" || $(INSTALL) -d "$$(dirname "$@")"
	$(do_subst) $< > $@
	perl -wc $(PERLINCLUDE)  $@ || { rm $@ && exit 1; }

all:

example: $(GPERLSCRIPTS)


CLEANFILES = $(GPERLSCRIPTS)
