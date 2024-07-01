################################################################################
DESTDIR ?= _install
PREFIX  ?= /usr/bin

BIN    := hello-world
SRC    := main.c
OBJDIR := .o/
OBJ    := $(patsubst %,$(OBJDIR)%.o,$(SRC))
DEP    := $(patsubst %,$(OBJDIR)%.d,$(SRC))

CFLAGS := -Wall -pedantic -O2
LDLIBS :=

all: $(BIN)

$(BIN): $(OBJ)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)
$(OBJ): $(OBJDIR)%.c.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

install:
	@install -m 755 -Dt $(DESTDIR)$(PREFIX)/ $(BIN)
clean:
	@$(RM) $(BIN) $(OBJ)

################################################################################
# must match debian/{control,changelog}
export PACKAGE ?= simple-package
export VERSION ?= 0.0.1
ORIG    ?= ../$(PACKAGE)_$(VERSION).tar.xz

export REPODIR ?= $(abspath out/pkg/$(VERSION))
export REPOURL ?= https://mpolitzer.github.io/ci.playground/pkg/$(VERSION)

repo.build: $(ORIG)
	@mkdir -p $(REPODIR)
	cp \
	  ../$(PACKAGE)-dbgsym_$(VERSION)_amd64.deb \
	  ../$(PACKAGE)_$(VERSION).dsc \
	  ../$(PACKAGE)_$(VERSION)_amd64.buildinfo \
	  ../$(PACKAGE)_$(VERSION)_amd64.changes \
	  ../$(PACKAGE)_$(VERSION)_amd64.deb \
	  ../$(PACKAGE)_$(VERSION).tar.xz \
	  $(REPODIR)
	@cd $(REPODIR) && ( \
	  dpkg-scanpackages . /dev/null | xz -c > Packages.xz; \
	  )
	@echo "********************************************************************************"
	@echo "To apt install this package, add:"
	@echo "> \"deb [trusted=yes] file:$(abspath $(REPODIR)) ./\""
	@echo "to /etc/apt/sources.list"
	@echo "********************************************************************************"

$(ORIG):
	make distclean
	# NOTE: Automatically update debian/changelog on new versions
	#echo | dch \
	#	--force-bad-version \
	#	--newversion $(VERSION) \
	#	--package $(PACKAGE) \
	#	"Release $(VERSION)"
	dpkg-buildpackage

################################################################################
export DOCDIR ?= $(abspath out/doc/$(VERSION)-$(shell git describe --always))

export MK_DOX_PROJECT_NUMBER=$(VERSION)
export MK_DOX_HTML_OUTPUT=$(DOCDIR)

doc/theme:
	@./fetch.sh https://github.com/jothepro/doxygen-awesome-css/archive/refs/tags/v2.3.3.tar.gz \
	  f7b5fbc15a850db06c522a2586407d0f643a72cb506849d529dbc6e33b2a22fd5e45e114e4f76d735b71ddac7af8d7030f5add65a04e807e45d22e0b746423c9 \
	  $@

doc.build: $(DOCDIR)
	@cp doc/index.html $(DOCDIR)/../..
$(DOCDIR): doc/theme | $(DOCDIR)/../version.js
	@mkdir -p $(@D)
	@doxygen -q doc/main.dox
$(DOCDIR)/../version.js: doc/gen-versions-js.sh
	@mkdir -p $(@D)
	@./$< $(DOCDIR)/.. > $@

################################################################################
DEBIMG := $(PACKAGE):debian
ENGINE := docker

# podman: already runs in the user namespace, so use root inside the container
# docker: change container user to UID:GID so that created files on mounted
# volumes have correct ownership.
ifeq ($(ENGINE),podman)
docker.run: .engine-stamp
	@$(ENGINE) run -v=$(PWD):$(PWD) -w=$(PWD) -u root $(DEBIMG) $(CMD)
else
docker.run: .engine-stamp
	@$(ENGINE) run --rm -it -v=$(PWD)/..:$(PWD)/.. -w=$(PWD) \
		--user $(shell id -u):$(shell id -g) \
		$(DEBIMG) $(CMD)
endif

.engine-stamp: debian.dockerfile
	$(ENGINE) build -t $(DEBIMG) -f $< .
	touch $@

################################################################################
distclean: clean
	@$(RM) -r $(DOCDIR)/../version.js $(REPODIR) $(DOCDIR)
	@$(RM) -r .engine-stamp

github-env:
	@echo UID=$(shell id -u)
	@echo GID=$(shell id -g)
	@echo DEBIMG=$(DEBIMG)
	@echo DOCDIR=$(DOCDIR)
	@echo PACKAGE=$(PACKAGE)
	@echo REPODIR=$(REPODIR)
	@echo VERSION=$(VERSION)

help:
	@echo "doc.build"
	@echo "repo.build"
	@echo "distclean"

.PHONY: $(DOCDIR)
