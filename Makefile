
prefix=/usr/local
bindir=$(prefix)/bin
datadir=$(prefix)/share
docdir=$(datadir)/doc
sysconfdir=$(prefix)/etc

DESTDIR=

INSTALL=install
INSTALL_DATA=install -m 644
INSTALL_DIR=install -d
LN_S=ln -sf
SED=sed

UNINSTALL=rm
UNINSTALL_DIR=rm -r

pkg_datadir=$(datadir)/jjigw
pkg_docdir=$(docdir)/jjigw

VERSION=0.2.1
SNAPSHOT=

PY_DIRS=jjigw
DOCS=ChangeLog INSTALL README TODO jjigw.xml.example

EXTRA_DIST=jjigw.py jjigw.dtd spidentd.py catalog.xml jjigw.init jjigw.sysconfig jjigw.spec startjjigw

.PHONY: all version dist ChangeLog cosmetics

all: version jjigw.py.inst catalog.xml.inst ChangeLog

version:
	if test -d ".git" ; then \
		echo "version='$(VERSION)+git'" > jjigw/version.py ; \
	fi
	sed -i "s/VERSION_STR/$(VERSION)/g" jjigw.spec
	git-log |grep -v ^commit|sed 's/ *-/-/g'|sed 's/^  */- /g'| awk '/Author/ {a=$$0;gsub("Author:","",a);next} /Date/ {d=$$2" "$$3" "$$4" "$$6; print "\n* "d,a;next} /^-/ {print} '|sed 1d >>jjigw.spec

jjigw.py.inst: jjigw.py
	$(SED) -e \
		"s#config_dir,data_dir=.*#config_dir,data_dir=\"$(sysconfdir)\",\"$(pkg_datadir)\"#" \
		jjigw.py > jjigw.py.inst

catalog.xml.inst: catalog.xml
	$(SED) -e \
		"s#rewritePrefix=\"./\"#rewritePrefix=\"file:///$(pkg_datadir)/\"#" \
		catalog.xml > catalog.xml.inst

ChangeLog: 
	test -d .git && make cl-stamp || :
	
cl-stamp: .git
	git log > ChangeLog
	touch cl-stamp

cosmetics:
	./aux/cosmetics.sh
	
clean:
	-rm -f jjigw.py.inst catalog.xml.inst
	-for d in $(PY_DIRS) ; do \
		rm -f $$d/*.pyc || : ; \
	done

install: all
	for d in $(PY_DIRS) ; do \
		$(INSTALL_DIR) $(DESTDIR)$(pkg_datadir)/$$d ; \
		$(INSTALL_DATA) $$d/*.py $(DESTDIR)$(pkg_datadir)/$$d ; \
	done
	python -c "import compileall; compileall.compile_dir('$(DESTDIR)$(pkg_datadir)')"
	$(INSTALL) jjigw.py.inst $(DESTDIR)$(pkg_datadir)/jjigw.py
	$(INSTALL_DATA) catalog.xml.inst $(DESTDIR)$(pkg_datadir)/catalog.xml
	$(INSTALL_DATA) jjigw.dtd $(DESTDIR)$(pkg_datadir)
	$(INSTALL_DIR) $(DESTDIR)$(pkg_docdir)
	$(INSTALL_DATA) $(DOCS) $(DESTDIR)$(pkg_docdir)
	$(INSTALL_DIR) $(DESTDIR)$(bindir)
	-rm -f $(DESTDIR)$(bindir)/jjigw
	$(LN_S) $(DESTDIR)$(pkg_datadir)/jjigw.py $(DESTDIR)$(bindir)/jjigw
	$(INSTALL) spidentd.py $(DESTDIR)$(bindir)/spidentd

uninstall:
	-for d in $(PY_DIRS) ; do \
		$(UNINSTALL_DIR) $(DESTDIR)$(pkg_datadir)/$$d || : ; \
	done
	-$(UNINSTALL_DIR) $(DESTDIR)$(pkg_datadir)
	-$(UNINSTALL_DIR) $(DESTDIR)$(pkg_docdir)
	-$(UNINSTALL) $(DESTDIR)$(bindir)/jjigw
	-$(UNINSTALL) $(DESTDIR)$(bindir)/spidentd

dist: all
	echo "version='$(VERSION)$(SNAPSHOT)'" > jjigw/version.py ; \
	version=`python -c "import jjigw.version; print jjigw.version.version"` ; \
	distname=jjigw-$$version ; \
	for d in $(PY_DIRS) ; do \
		$(INSTALL_DIR) $$distname/$$d || exit 1 ; \
		cp -a $$d/*.py $$distname/$$d || exit 1 ; \
	done || exit 1 ; \
	for f in $(DOCS) $(EXTRA_DIST) ; do \
		d=`dirname $$f` ; \
		$(INSTALL_DIR) $$distname/$$d || exit 1; \
		cp -a $$f $$distname/$$d || exit 1; \
	done ; \
	sed -e "s/^SNAPSHOT=.*/SNAPSHOT=$(SNAPSHOT)/" Makefile > $$distname/Makefile ; \
	mkdir -p dist ; \
	tar czf dist/$${distname}.tar.gz $$distname && \
	rm -r $$distname
