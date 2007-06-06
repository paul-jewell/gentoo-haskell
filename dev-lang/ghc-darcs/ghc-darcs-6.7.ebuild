# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ghc/ghc-6.4.ebuild,v 1.1 2005/03/11 16:30:24 kosmikus Exp $

# THIS IS AN UNOFFICIAL EBUILD. PLEASE CONTACT kosmikus@gentoo.org DIRECTLY
# IF YOU EXPERIENCE PROBLEMS. PLEASE DO NOT WRITE TO GENTOO-MAILING LISTS
# AND DON'T FILE ANY BUGS IN BUGZILLA ABOUT THIS BUILD.

# Brief explanation of the bootstrap logic:
#
# ghc requires ghc-bin to bootstrap.
# Therefore, 
# (1) both ghc-bin and ghc provide virtual/ghc
# (2) virtual/ghc *must* default to ghc-bin
# (3) ghc depends on virtual/ghc
#
# This solution has the advantage that the binary distribution
# can be removed once an forall after the first succesful install
# of ghc.

GHC_REPOSITORY="http://darcs.haskell.org"
EDARCS_REPOSITORY="${GHC_REPOSITORY}/ghc"
EDARCS_GET_CMD="get --partial"

inherit base eutils flag-o-matic autotools darcs ghc-package check-reqs

DESCRIPTION="The Glasgow Haskell Compiler"
HOMEPAGE="http://www.haskell.org/ghc/"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

# We don't provide virtual/ghc, although we could ...
# PROVIDE="virtual/ghc"

RDEPEND="
	>=sys-devel/gcc-2.95.3
	>=dev-lang/perl-5.6.1
	>=dev-libs/gmp-4.1
	>=sys-libs/readline-4.2"

# ghc cannot usually be bootstrapped using later versions ...
DEPEND="${RDEPEND}
	<virtual/ghc-6.8
	!>=virtual/ghc-6.8
	>=dev-haskell/happy-1.15
	>=dev-haskell/alex-2.0
	doc? (  ~app-text/docbook-xml-dtd-4.2
			app-text/docbook-xsl-stylesheets
			>=dev-libs/libxslt-1.1.2
			>=dev-haskell/haddock-0.8 )"

# The following function fetches each of the sub-repositories that
# ghc requires.
fetch_pkg() {
	local EDARCS_REPOSITORY EDARCS_LOCALREPO
	EDARCS_REPOSITORY="${GHC_REPOSITORY}/packages/$1"
	EDARCS_LOCALREPO="ghc/libraries/$1"
	darcs_fetch
}

append-ghc-cflags() {
	local flag compile assemble link
	for flag in $*; do
		case ${flag} in
			compile)	compile="yes";;
			assemble)	assemble="yes";;
			link)		link="yes";;
			*)
				[[ ${compile}  ]] && GHC_CFLAGS="${GHC_CFLAGS} -optc${flag}"
				[[ ${assemble} ]] && GHC_CFLAGS="${GHC_CFLAGS} -opta${flag}"
				[[ ${link}     ]] && GHC_CFLAGS="${GHC_CFLAGS} -optl${flag}";;
		esac
	done
}

ghc_setup_cflags() {
	# We need to be very careful with the CFLAGS we ask ghc to pass through to
	# gcc. There are plenty of flags which will make gcc produce output that
	# breaks ghc in various ways. The main ones we want to pass through are
	# -mcpu / -march flags. These are important for arches like alpha & sparc.
	# We also use these CFLAGS for building the C parts of ghc, ie the rts.
	strip-flags
	strip-unsupported-flags
	filter-flags -fPIC

	GHC_CFLAGS=""
	for flag in ${CFLAGS}; do
		case ${flag} in

			# Ignore extra optimisation (ghc passes -O to gcc anyway)
			# -O2 and above break on too many systems
			-O*) ;;

			# Arch and ABI flags are what we're really after
			-m*) append-ghc-cflags compile assemble ${flag};;

			# Debugging flags don't help either. You can't debug Haskell code
			# at the C source level and the mangler discards the debug info.
			-g*) ;;

			# Ignore all other flags, including all -f* flags
		esac
	done

	# hardened-gcc needs to be disabled, because the mangler doesn't accept
	# its output.
	gcc-specs-pie && append-ghc-cflags compile link	-nopie
	gcc-specs-ssp && append-ghc-cflags compile		-fno-stack-protector

	# We also add -Wa,--noexecstack to get ghc to generate .o files with
	# non-exectable stack. This it a hack until ghc does it itself properly.
	append-ghc-cflags assemble		"-Wa,--noexecstack"
}

src_unpack() {
	# get main GHC darcs repo
	darcs_fetch
	for pkg in $(cat "${EDARCS_TOP_DIR}/${EDARCS_LOCALREPO}/libraries/core-packages"); do
		fetch_pkg "${pkg}"
	done
	# copy everything
	darcs_src_unpack
	ghc_setup_cflags

	# Modify the ghc driver script to use GHC_CFLAGS
	echo "SCRIPT_SUBST_VARS += GHC_CFLAGS" >> "${S}/driver/ghc/Makefile"
	echo "GHC_CFLAGS = ${GHC_CFLAGS}"      >> "${S}/driver/ghc/Makefile"
	sed -i -e 's|$TOPDIROPT|$TOPDIROPT $GHC_CFLAGS|' "${S}/driver/ghc/ghc.sh"
}

src_compile() {
	# darcs checkout requires to run this
	sh boot

	# initialize build.mk
	echo '# Gentoo changes' > mk/build.mk

	# We also need to use the GHC_CFLAGS flags when building ghc itself
	echo "SRC_HC_OPTS+=${GHC_CFLAGS}" >> mk/build.mk
	echo "SRC_CC_OPTS+=${CFLAGS} -Wa,--noexecstack" >> mk/build.mk

	# If you need to do a quick build then enable this bit and add debug to IUSE
	#if use debug; then
	#	echo "SRC_HC_OPTS     = -H32m -O -fasm" >> mk/build.mk
	#	echo "GhcLibHcOpts    =" >> mk/build.mk
	#	echo "GhcLibWays      =" >> mk/build.mk
	#	echo "SplitObjs       = NO" >> mk/build.mk
	#fi

	# determine what to do with documentation
	if use doc; then
		echo XMLDocWays="html" >> mk/build.mk
	else
		echo XMLDocWays="" >> mk/build.mk
		# needed to prevent haddock from being called
		echo NO_HADDOCK_DOCS=YES >> mk/build.mk
	fi

	# circumvent a very strange bug that seems related with ghc producing too much
	# output while being filtered through tee (e.g. due to portage logging)
	# reported as bug #111183
	echo "SRC_HC_OPTS+=-fno-warn-deprecations" >> mk/build.mk

	# force the config variable ArSupportsInput to be unset;
	# ar in binutils >= 2.14.90.0.8-r1 seems to be classified
	# incorrectly by the configure script
	echo "ArSupportsInput:=" >> mk/build.mk

	# Some arches do support some ghc features even though they're off by default
	use ia64 && echo "GhcWithInterpreter=YES" >> mk/build.mk

	# The SplitObjs feature makes 'ar'/'ranlib' take loads of RAM:
	CHECKREQS_MEMORY="200"
	if ! check_reqs_conditional; then
		elog "Turning off ghc's 'Split Objs' feature because this machine"
		elog "does not have enough RAM for it. This will have the effect"
		elog "of making binaries produced by ghc considerably larger."
		echo "SplitObjs=NO" >> mk/build.mk
	fi

	# We're building from darcs so we need to autoreconf
	eautoreconf

	econf || die "econf failed"

	emake all datadir="/usr/share/doc/${PF}" || die "make failed"
	# the explicit datadir is required to make the haddock entries
	# in the package.conf file point to the right place ...

}

src_install () {
	local insttarget

	insttarget="install"
	use doc && insttarget="${insttarget} install-docs"

	# the libdir0 setting is needed for amd64, and does not
	# harm for other arches
	emake -j1 ${insttarget} \
		prefix="${D}/usr" \
		datadir="${D}/usr/share/doc/${PF}" \
		infodir="${D}/usr/share/info" \
		mandir="${D}/usr/share/man" \
		libdir0="${D}/usr/$(get_libdir)" \
		|| die "make ${insttarget} failed"

	#need to remove ${D} from ghcprof script
	cd "${D}/usr/bin"
	mv ghcprof ghcprof-orig
	sed -e 's:$FPTOOLS_TOP_ABS:#$FPTOOLS_TOP_ABS:' ghcprof-orig > ghcprof
	chmod a+x ghcprof
	rm -f ghcprof-orig

	#rename non-version-specific files
	nonvers=$(find -path "./*" -and -not -path "*${PV}*")
	nondef=""
	for f in ${nonvers}; do
		f=$(basename ${f})
		mv ${f} ${f}-darcs
		if test -e /usr/bin/${f}; then
			if test -L /usr/bin/${f} -a -e /usr/bin/${f}-darcs; then
				if diff -q "/usr/bin/${f}" "/usr/bin/${f}-darcs" > /dev/null; then
					# link seems to be okay, recreate to keep
					einfo "recreating link /usr/bin/${f} -> /usr/bin/${f}-darcs"
					dosym /usr/bin/${f}-darcs /usr/bin/{f}
					continue
				fi
			fi
			einfo "did not touch existing file /usr/bin/${f}"
			# presumably not our file, will not be unmerged
			nondef="${nondef} /usr/bin/${f}"
		else
			# interestingly, the file in question does not yet exist ...
			einfo "creating new link /usr/bin/${f} -> /usr/bin/${f}-darcs"
			dosym /usr/bin/${f}-darcs /usr/bin/${f}
		fi
	done
	if test -n "${nondef}"; then
		elog "If you want to make the Darcs version of GHC the default version,"
		elog "you should create the following symbolic links:"
		for f in ${nondef}; do
			einfo "   ln -s ${f}-darcs /usr/bin/${f}"
		done
		elog "Note that this is optional."
	fi

	cd "${S}"
	dodoc README ANNOUNCE LICENSE VERSION
}

