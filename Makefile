CC=gcc
CFLAGS=-g -Wall -O2 -Wno-unused-function
GIT=git
RM=rm

all:seqtk

.PHONY: reversion
reversion: versionPrereqs
		[ ! -f version.h ] || $(RM) version.h;
		$(MAKE) version.h;

.PHONY: versionPrereqs
versionPrereqs:
		if [ -z "$$(which $(GIT))" -o ! -d ".git" ] ; then \
			echo "version.h can only be made in a clone of the seqtk git repo, with $(GIT) available"; \
			exit 1; \
		fi

version.h: versionPrereqs
		lastTag=$$($(GIT) describe --abbrev=0 --tags | sed 's/^v//'); \
		revCount=$$($(GIT) rev-list --all --count); \
		[ ! -z "$${lastTag}" -a ! -z "$${revCount}" ] || (echo "Failed to get version information" && exit 1); \
		$$(git diff-index --quiet HEAD --) && dirty="" || dirty="-dirty"; \
		echo "#define SEQTKVERSION \""$${lastTag}"-r"$${revCount}$${dirty}"\"" > $@

seqtk:seqtk.c khash.h kseq.h version.h
		$(CC) $(CFLAGS) seqtk.c -o $@ -lz -lm

clean:
		$(RM) -fr gmon.out *.o ext/*.o a.out seqtk trimadap *~ *.a *.dSYM session*
