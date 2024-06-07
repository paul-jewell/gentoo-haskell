# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# to make make a crosscompiler use crossdev and symlink ghc tree into
# cross overlay. result would look like 'cross-sparc-unknown-linux-gnu/ghc'
export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

PYTHON_COMPAT=( python3_{9..12} )
inherit python-any-r1
inherit autotools bash-completion-r1 flag-o-matic ghc-package
inherit toolchain-funcs prefix check-reqs llvm unpacker haskell-cabal

DESCRIPTION="The Glasgow Haskell Compiler"
HOMEPAGE="https://www.haskell.org/ghc/"

GHC_BINARY_PV="9.6.2"
SRC_URI="
	https://downloads.haskell.org/~ghc/${PV}/${P}-src.tar.xz
	!ghcbootstrap? (
		https://downloads.haskell.org/~ghc/9.8.2/hadrian-bootstrap-sources/hadrian-bootstrap-sources-${GHC_BINARY_PV}.tar.gz
		amd64? ( https://downloads.haskell.org/~ghc/${GHC_BINARY_PV}/ghc-${GHC_BINARY_PV}-x86_64-alpine3_12-linux-static-int_native.tar.xz )
	)
"

yet_binary() {
	case ${ARCH} in
		amd64)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

# We are using the upstream static Alpine Linux binaries to bootstrap some
# archs. These binaries have different properties than the ones we build
# ourselves, so we need a way to check to see if they are in use.
upstream_binary() {
	case ${ARCH} in
		amd64)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

# The location of the unpacked Alpine Linux tarball
ghc_bin_path() {
	local ghc_bin_triple
	case ${ARCH} in
		amd64)
			ghc_bin_triple="x86_64-unknown-linux"
			;;
		*)
			die "Unknown ghc binary triple. The list here should match yet_binary."
			;;
	esac

	echo "${WORKDIR}/ghc-${GHC_BINARY_PV}-${ghc_bin_triple}"
}

GHC_PV=${PV}
#GHC_PV=8.10.0.20200123 # uncomment only for -alpha, -beta, -rc ebuilds
GHC_P=${PN}-${GHC_PV} # using ${P} is almost never correct

S="${WORKDIR}"/${GHC_P}

BUMP_LIBRARIES=(
	# "hackage-name          hackage-version"
)

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="big-endian doc elfutils ghcbootstrap ghcmakebinary +gmp llvm numa profile test unregisterised"
RESTRICT="!test? ( test )"

LLVM_MAX_SLOT="16"
RDEPEND="
	>=dev-lang/perl-5.6.1
	dev-libs/gmp:0=
	sys-libs/ncurses:=[unicode(+)]
	elfutils? ( dev-libs/elfutils )
	!ghcmakebinary? ( dev-libs/libffi:= )
	numa? ( sys-process/numactl )
	llvm? (
		<sys-devel/llvm-$((${LLVM_MAX_SLOT} + 1)):=
		|| (
			sys-devel/llvm:15
			sys-devel/llvm:16
		)
	)
"

DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.2
		app-text/docbook-xml-dtd:4.5
		app-text/docbook-xsl-stylesheets
		dev-python/sphinx
		dev-python/sphinx-rtd-theme
		>=dev-libs/libxslt-1.1.2
	)
	ghcbootstrap? (
		ghcmakebinary? ( dev-haskell/hadrian[static] )
		~dev-haskell/hadrian-${PV}
	)
	test? ( ${PYTHON_DEPS} )
"

needs_python() {
	# test driver is written in python
	use test && return 0
	return 1
}

# we build binaries without profiling support
REQUIRED_USE="
	?? ( llvm unregisterised )
"

# haskell libraries built with cabal in configure mode, #515354
QA_CONFIGURE_OPTIONS+=" --with-compiler --with-gcc"

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

is_native() {
	[[ ${CHOST} == ${CBUILD} ]] && [[ ${CHOST} == ${CTARGET} ]]
}

if ! is_crosscompile; then
	PDEPEND="!ghcbootstrap? ( >=app-admin/haskell-updater-1.2 )"
fi

# returns tool prefix for crosscompiler.
# Example:
#  CTARGET=armv7a-unknown-linux-gnueabi
#  CHOST=x86_64-pc-linux-gnu
#    "armv7a-unknown-linux-gnueabi-"
#  CTARGET=${CHOST}
#    ""
# Used in tools and library prefix:
#    "${ED}"/usr/bin/$(cross)haddock
#    "${ED}/usr/$(get_libdir)/$(cross)${GHC_P}/package.conf.d"

cross() {
	if is_crosscompile; then
		echo "${CTARGET}-"
	else
		echo ""
	fi
}

append-ghc-cflags() {
	local persistent compile assemble link
	local flag ghcflag

	for flag in $*; do
		case ${flag} in
			persistent)	persistent="yes";;
			compile)	compile="yes";;
			assemble)	assemble="yes";;
			link)		link="yes";;
			*)
				[[ ${compile}  ]] && ghcflag="-optc${flag}"  CFLAGS+=" ${flag}" && GHC_FLAGS+=" ${ghcflag}" &&
					[[ ${persistent} ]] && GHC_PERSISTENT_FLAGS+=" ${ghcflag}"
				[[ ${assemble} ]] && ghcflag="-opta${flag}"  CFLAGS+=" ${flag}" && GHC_FLAGS+=" ${ghcflag}" &&
					[[ ${persistent} ]] && GHC_PERSISTENT_FLAGS+=" ${ghcflag}"
				[[ ${link}     ]] && ghcflag="-optl${flag}" LDFLAGS+=" ${flag}" && GHC_FLAGS+=" ${ghcflag}" &&
					[[ ${persistent} ]] && GHC_PERSISTENT_FLAGS+=" ${ghcflag}"
				;;
		esac
	done
}

# $1 - subdirectory (under libraries/)
# $2 - lib name (under libraries/)
# $3 - lib version
# example: bump_lib "transformers" "0.4.2.0"
bump_lib() {
	local subdir="$1" pn=$2 pv=$3
	local p=${pn}-${pv}
	local f

	einfo "Bumping ${pn} up to ${pv}"

	mv libraries/"${subdir}"/"${pn}" "${WORKDIR}"/"${pn}".old || die
	mv "${WORKDIR}"/"${p}" libraries/"${subdir}"/"${pn}" || die
}

update_SRC_URI() {
	local p pn pv
	for p in "${BUMP_LIBRARIES[@]}"; do
		set -- $p
		pn=$1 pv=$2

		SRC_URI+=" https://hackage.haskell.org/package/${pn}-${pv}/${pn}-${pv}.tar.gz"
	done
}

update_SRC_URI

bump_libs() {
	local p pn pv subdir
	for p in "${BUMP_LIBRARIES[@]}"; do
		set -- $p
		pn=$1 pv=$2

		if [[ "$pn" == "Cabal-syntax" ]] || [[ "$pn" == "Cabal" ]]; then
			subdir="Cabal"
		else
			subdir=""
		fi

		bump_lib "${subdir}" "${pn}" "${pv}"
	done
}

ghc_setup_cflags() {
	# TODO: plumb CFLAGS and BUILD_CFLAGS to respective CONF_CC_OPTS_STAGE<N>
	if ! is_native; then
		export CFLAGS=${GHC_CFLAGS-"-O2 -pipe"}
		export LDFLAGS=${GHC_LDFLAGS-"-Wl,-O1"}
		einfo "Crosscompiling mode:"
		einfo "   CHOST:   ${CHOST}"
		einfo "   CTARGET: ${CTARGET}"
		einfo "   CFLAGS:  ${CFLAGS}"
		einfo "   LDFLAGS: ${LDFLAGS}"
		einfo "   prefix: $(cross)"
		return
	fi
	# We need to be very careful with the CFLAGS we ask ghc to pass through to
	# gcc. There are plenty of flags which will make gcc produce output that
	# breaks ghc in various ways. The main ones we want to pass through are
	# -mcpu / -march flags. These are important for arches like alpha & sparc.
	# We also use these CFLAGS for building the C parts of ghc, ie the rts.
	strip-flags
	strip-unsupported-flags

	# Cmm can't parse line numbers #482086
	replace-flags -ggdb[3-9] -ggdb2

	GHC_FLAGS=""
	GHC_PERSISTENT_FLAGS=""
	for flag in ${CFLAGS}; do
		case ${flag} in

			# Ignore extra optimisation (ghc passes -O to gcc anyway)
			# -O2 and above break on too many systems
			-O*) ;;

			# Arch and ABI flags are what we're really after
			-m*) append-ghc-cflags compile assemble ${flag};;

			# Sometimes it's handy to see backtrace of RTS
			# to get an idea what happens there
			-g*) append-ghc-cflags compile ${flag};;

			# Ignore all other flags, including all -f* flags
		esac
	done

	for flag in ${LDFLAGS}; do
		append-ghc-cflags link ${flag}
	done
}

# substitutes string $1 to $2 in files $3 $4 ...
relocate_path() {
	local from=$1
	local   to=$2
	shift 2
	local file=
	for file in "$@"
	do
		sed -i -e "s|$from|$to|g" \
			"$file" || die "path relocation failed for '$file'"
	done
}

# changes hardcoded ghc paths and updates package index
# $1 - new absolute root path
relocate_ghc() {
	local to=$1 ghc_v=${BIN_PV}

	# libdir for prebuilt binary and for current system may mismatch
	# It does for prefix installation for example: bug #476998
	local bin_ghc_prefix=${WORKDIR}/usr
	local bin_libpath=$(echo "${bin_ghc_prefix}"/lib*)
	local bin_libdir=${bin_libpath#${bin_ghc_prefix}/}

	# backup original script to use it later after relocation
	local gp_back="${T}/ghc-pkg-${ghc_v}-orig"
	cp "${WORKDIR}/usr/bin/ghc-pkg-${ghc_v}" "$gp_back" || die "unable to backup ghc-pkg wrapper"

	if [[ ${bin_libdir} != $(get_libdir) ]]; then
		einfo "Relocating '${bin_libdir}' to '$(get_libdir)' (bug #476998)"
		# moving the dir itself is not strictly needed
		# but then USE=binary would result in installing
		# in '${bin_libdir}'
		mv "${bin_ghc_prefix}/${bin_libdir}" "${bin_ghc_prefix}/$(get_libdir)" || die

		relocate_path "/usr/${bin_libdir}" "/usr/$(get_libdir)" \
			"${WORKDIR}/usr/bin/ghc-${ghc_v}" \
			"${WORKDIR}/usr/bin/ghci-${ghc_v}" \
			"${WORKDIR}/usr/bin/ghc-pkg-${ghc_v}" \
			"${WORKDIR}/usr/bin/hsc2hs" \
			"${WORKDIR}/usr/bin/runghc-${ghc_v}" \
			"$gp_back" \
			"${WORKDIR}/usr/$(get_libdir)/${PN}-${ghc_v}/lib/package.conf.d/"*
	fi

	# Relocate from /usr to ${EPREFIX}/usr
	relocate_path "/usr" "${to}/usr" \
		"${WORKDIR}/usr/bin/ghc-${ghc_v}" \
		"${WORKDIR}/usr/bin/ghci-${ghc_v}" \
		"${WORKDIR}/usr/bin/ghc-pkg-${ghc_v}" \
		"${WORKDIR}/usr/bin/haddock-ghc-${ghc_v}" \
		"${WORKDIR}/usr/bin/hp2ps" \
		"${WORKDIR}/usr/bin/hpc" \
		"${WORKDIR}/usr/bin/hsc2hs" \
		"${WORKDIR}/usr/bin/runghc-${ghc_v}" \
		"${WORKDIR}/usr/$(get_libdir)/${PN}-${ghc_v}/lib/package.conf.d/"*

	# this one we will use to regenerate cache
	# so it should point to current tree location
	relocate_path "/usr" "${WORKDIR}/usr" "$gp_back"

	if use prefix; then
		hprefixify "${bin_libpath}"/${PN}*/settings
	fi

	# regenerate the binary package cache
	"$gp_back" recache || die "failed to update cache after relocation"
	rm "$gp_back"
}

ghc-check-reqs() {
	# These are pessimistic values (slightly bigger than worst-case)
	# Worst case is UNREG USE=profile ia64. See bug #611866 for some
	# numbers on various arches.
	CHECKREQS_DISK_BUILD=8G
	CHECKREQS_DISK_USR=2G

	"$@"
}

llvmize() {
	einfo "Running llvmize"
	[[ -z "${1}" ]] && return
	( find "${1}" -type f \
		| file -if- \
		| grep "text/x-shellscript" \
		| awk -F: '{print $1}' \
		| xargs sed -i "s#^exec #PATH=\"$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin:\${PATH}\" exec #") || die
}

ghc-check-bootstrap-version () {
	local diemsg version
	ebegin "Checking for appropriate installed GHC version for bootstrapping"
	if version=$(ghc-version); then
		if ver_test "${version}" -gt "9.0.0"; then
			eend 0
			return 0
		else
			diemsg="Inappropriate GHC version for bootstrapping: ${version}"
		fi
	else
		diemsg="Could not find installed GHC for bootstrapping"
	fi

	eend 1
	eerror "USE=ghcbootstrap _requires_ an existing GHC already installed on the system."
	eerror "Furthermore, the hadrian build system requires that the existing ghc be"
	eerror "version 9.0 or higher."
	die "$diemsg"
}

ghc-check-bootstrap-mismatch () {
	local diemsg ghc_version cabal_version
	ebegin "Checking for mismatched GHC and Cabal versions for bootstrapping"
	if ver_test "$(ghc-version)" -lt "9.4" && ver_test "$(cabal-version)" -gt "3.8"; then
		eend 1
		eerror "There have been issues bootstrapping ghc-9.4 with <ghc-9.4 and >Cabal-3.8"
		eerror "Please install dev-haskell/cabal-3.6.* instead first."
		die "Mismatched GHC and Cabal versions for bootstrapping"
	else
		eend 0
	fi
}

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]] && use ghcbootstrap; then
		ghc-check-bootstrap-version
		ghc-check-bootstrap-mismatch
	fi
	ghc-check-reqs check-reqs_pkg_pretend
}

pkg_setup() {
	ghc-check-reqs check-reqs_pkg_setup

	[[ ${MERGE_TYPE} == binary ]] && return

	if use ghcbootstrap; then
		ewarn "You requested ghc bootstrapping, this is usually only used"
		ewarn "by Gentoo developers to make binary .tbz2 packages."

		[[ -z $(type -P ghc) ]] && \
			die "Could not find a ghc to bootstrap with."
	else
		if ! yet_binary; then
			eerror "Please try emerging with USE=ghcbootstrap and report build"
			eerror "success or failure to the haskell team (haskell@gentoo.org)"
			die "No binary available for '${ARCH}' arch yet, USE=ghcbootstrap"
		fi
	fi

	if needs_python; then
		python-any-r1_pkg_setup
	fi

	use llvm && llvm_pkg_setup
}

src_unpack() {
	# the Solaris and Darwin binaries from ghc (maeder) need to be
	# unpacked separately, so prevent them from being unpacked
	local ONLYA=${A}
	case ${CHOST} in
		*-darwin* | *-solaris*)  ONLYA=${GHC_P}-src.tar.xz  ;;
	esac
	unpacker ${ONLYA}
}

src_prepare() {
	# Force the use of C.utf8 locale
	# <https://github.com/gentoo-haskell/gentoo-haskell/issues/1287>
	# <https://github.com/gentoo-haskell/gentoo-haskell/issues/1289>
	export LC_ALL=C.utf8

	ghc_setup_cflags

	if ! use ghcbootstrap && ! upstream_binary; then
		# Make GHC's settings file comply with user's settings
		GHC_SETTINGS="${WORKDIR}/usr/$(get_libdir)/${PN}-${BIN_PV}/lib/settings"
		sed -i "s/,(\"C compiler command\", \".*\")/,(\"C compiler command\", \"$(tc-getCC)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"C++ compiler command\", \".*\")/,(\"C++ compiler command\", \"$(tc-getCXX)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"Haskell CPP command\", \".*\")/,(\"Haskell CPP command\", \"$(tc-getCC)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"ld command\", \".*\")/,(\"ld command\", \"$(tc-getLD)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"Merge objects command\", \".*\")/,(\"Merge objects command\", \"$(tc-getLD)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"ar command\", \".*\")/,(\"ar command\", \"$(tc-getAR)\")/" "${GHC_SETTINGS}" || die
		sed -i "s/,(\"ranlib command\", \".*\")/,(\"ranlib command\", \"$(tc-getRANLIB)\")/" "${GHC_SETTINGS}" || die
	fi
	use llvm && ! use ghcbootstrap && llvmize "$(ghc_bin_path)"

	# binpkg may have been built with FEATURES=splitdebug
	if [[ -d "${WORKDIR}/usr/lib/debug" ]] ; then
		rm -rf "${WORKDIR}/usr/lib/debug" || die
	fi
	find "${WORKDIR}/usr/lib" -type d -empty -delete 2>/dev/null # do not die on failure here

	# ffi headers don't get included in the binpkg for some reason
	for f in "${WORKDIR}/usr/$(get_libdir)/${PN}-${BIN_PV}/include/"{ffi.h,ffitarget.h}
	do
		mkdir -p "$(dirname "${f}")"
		[[ -e "${f}" ]] || ln -sf "$($(tc-getPKG_CONFIG) --cflags-only-I libffi | sed "s/-I//g" | tr -d " ")/$(basename "${f}")" "${f}" || die
	done

	if ! use ghcbootstrap && ! upstream_binary; then
		relocate_ghc "${WORKDIR}"
	fi

	sed -i -e "s|\"\$topdir\"|\"\$topdir\" ${GHC_PERSISTENT_FLAGS}|" \
		"${S}/ghc/ghc.wrapper"

	cd "${S}" # otherwise eapply will break

	#eapply "${FILESDIR}"/${PN}-9.0.2-CHOST-prefix.patch
	#eapply "${FILESDIR}"/${PN}-9.0.2-darwin.patch

	# ModUnusable pretty-printing should include the reason
	# broken in 9.6.4
	#eapply "${FILESDIR}/${PN}-9.0.2-verbose-modunusable.patch"

	# Needed for testing with python-3.10
	#use test && eapply "${FILESDIR}/${PN}-9.0.2-fix-tests-python310.patch"

	#needs a port?
	#eapply "${FILESDIR}"/${PN}-8.8.1-revert-CPP.patch
	eapply "${FILESDIR}"/${PN}-8.10.1-allow-cross-bootstrap.patch
	#eapply "${FILESDIR}"/${PN}-8.10.3-C99-typo-ac270.patch
	#eapply "${FILESDIR}"/${PN}-9.0.2-disable-unboxed-arrays.patch
	#eapply "${FILESDIR}"/${PN}-9.0.2-llvm-13.patch
	#eapply "${FILESDIR}"/${PN}-9.0.2-llvm-14.patch

		# https://gitlab.haskell.org/ghc/ghc/-/issues/22954
		# https://gitlab.haskell.org/ghc/ghc/-/issues/21936
		eapply "${FILESDIR}"/${PN}-9.6.4-llvm-16.patch

	# Fix issue caused by non-standard "musleabi" target in
	# https://gitlab.haskell.org/ghc/ghc/-/blob/ghc-9.4.5-release/m4/ghc_llvm_target.m4#L39
	eapply "${FILESDIR}"/${PN}-9.4.5-musl-target.patch

	# a bunch of crosscompiler patches
	# needs newer version:
	#eapply "${FILESDIR}"/${PN}-8.2.1_rc1-hp2ps-cross.patch

	# FIXME: A hack that allows dev-python/sphinx-7 to build the docs
	#
	# GHC has updated the bundled version here:
	# <https://gitlab.haskell.org/ghc/ghc/-/commit/70526f5bd8886126f49833ef20604a2c6477780a>
	# However, the patch is difficult to apply and our versions of GHC don't
	# have the update, so we symlink to the system version instead.
	if use doc; then
		local python_str="import sphinx_rtd_theme; print(sphinx_rtd_theme.__file__)"
		local rtd_theme_dir="$(dirname $("${EPYTHON}" -c "$python_str"))"
		local orig_rtd_theme_dir="${S}/docs/users_guide/rtd-theme"

		einfo "Replacing bundled rtd-theme with dev-python/sphinx-rtd-theme"
		rm -r "${orig_rtd_theme_dir}" || die
		ln -s "${rtd_theme_dir}" "${orig_rtd_theme_dir}" || die
	fi

	# mingw32 target
	pushd "${S}/libraries/Win32"
		eapply "${FILESDIR}"/${PN}-8.2.1_rc1-win32-cross-2-hack.patch # bad workaround
	popd

	eapply "${FILESDIR}"/${PN}-9.8.2-force-merge-objects-when-building-dynamic-objects.patch

	bump_libs

	eapply_user
	# as we have changed the build system
	eautoreconf
}

src_configure() {
	if ! use ghcbootstrap; then
		einfo "Installing bootstrap GHC"

		( cd "$(ghc_bin_path)" || die
			./configure \
				--prefix="" \
				--libdir="/$(get_libdir)" || die
			emake DESTDIR="${WORKDIR}/ghc-bin" install
		)

		einfo "Bootstrapping hadrian"
		( cd "${S}/hadrian/bootstrap" || die
			./bootstrap.py \
				-w "${WORKDIR}/ghc-bin/$(get_libdir)/ghc-${GHC_BINARY_PV}/bin/ghc" \
				-s "${DISTDIR}/hadrian-bootstrap-sources-${GHC_BINARY_PV}.tar.gz" || die "Hadrian bootstrap failed"
		)
	fi

	# prepare hadrian build settings files
	mkdir _build
	touch _build/hadrian.settings

	# We also need to use the GHC_FLAGS flags when building ghc itself
	#echo "SRC_HC_OPTS+=${HCFLAGS} ${GHC_FLAGS}" >> mk/build.mk
	echo "*.*.ghc.hs.opts += ${GHC_FLAGS}" >> _build/hadrian.settings
	#echo "SRC_CC_OPTS+=${CFLAGS}" >> mk/build.mk
	# ghc with hadrian is unhappy with these c.opts
	echo "*.*.ghc.c.opts += ${GHC_FLAGS}" >> _build/hadrian.settings
	#echo "SRC_LD_OPTS+=${LDFLAGS}" >> mk/build.mk
#	echo "*.*.ghc.link.opts += ${LDFLAGS}" >> _build/hadrian.settings
	# Speed up initial Cabal bootstrap
	#echo "utils/ghc-cabal_dist_EXTRA_HC_OPTS+=$(ghc-make-args)" >> mk/build.mk

#	# not used outside of ghc's test
#	if [[ -n ${GHC_BUILD_DPH} ]]; then
#			echo "BUILD_DPH = YES" >> mk/build.mk
#		else
#			echo "BUILD_DPH = NO" >> mk/build.mk
#	fi

#	if is_crosscompile; then
#		# Install ghc-stage1 crosscompiler instead of
#		# ghc-stage2 cross-built compiler.
#		#echo "Stage1Only=YES" >> mk/build.mk
#		sed -i -e 's/finalStage = Stage2/finalStage = Stage1/' \
#			hadrian/UserSettings.hs
#	fi

	# Get ghc from the binary
	# except when bootstrapping we just pick ghc up off the path
	if ! use ghcbootstrap; then
		export PATH="${WORKDIR}/ghc-bin/$(get_libdir)/ghc-${GHC_BINARY_PV}/bin:${PATH}"
	fi

	# Allow the user to select their bignum backend (default to gmp):
	# use gmp || sed -i -e 's/userFlavour = defaultFlavour { name = \"user\"/userFlavour = defaultFlavour { name = \"user\", bignumBackend = \"native\"/'
	#echo "BIGNUM_BACKEND = $(usex gmp gmp native)" >> mk/build.mk

	# don't strip anything. Very useful when stage2 SIGSEGVs on you
	#echo "STRIP_CMD = :" >> mk/build.mk

	local econf_args=()

	# GHC embeds toolchain it was built by and uses it later.
	# Don't allow things like ccache or versioned binary slip.
	# We use stable thing across gcc upgrades.
	# User can use EXTRA_ECONF=CC=... to override this default.
	econf_args+=(
		AR=${CTARGET}-ar
		CC=${CTARGET}-gcc
		# these should be inferred by GHC but ghc defaults
		# to using bundled tools on windows.
		Windres=${CTARGET}-windres
		DllWrap=${CTARGET}-dllwrap
		# we set the linker explicitly below
		--disable-ld-override

		# Put docs into the right place, ie /usr/share/doc/ghc-${GHC_PV}
		--docdir="${EPREFIX}/usr/share/doc/$(cross)${PF}"
	)
	case ${CTARGET} in
		arm*)
			# ld.bfd-2.28 does not work for ghc. Force ld.gold
			# instead. This should be removed once gentoo gets
			# a fix for R_ARM_COPY bug: https://sourceware.org/PR16177
			econf_args+=(LD=${CTARGET}-ld.gold)
		;;
		sparc*)
			# ld.gold-2.28 does not work for ghc. Force ld.bfd
			# instead. This should be removed once gentoo gets
			# a fix for missing --no-relax support bug:
			# https://sourceware.org/ml/binutils/2017-07/msg00183.html
			econf_args+=(LD=${CTARGET}-ld.bfd)
		;;
		*)
			econf_args+=(LD=${CTARGET}-ld)
	esac

	if [[ ${CBUILD} != ${CHOST} ]]; then
		# GHC bug: ghc claims not to support cross-building.
		# It does, but does not distinct --host= value
		# for stage1 and stage2 compiler.
		econf_args+=(--host=${CBUILD})
	fi

	if use ghcmakebinary; then
		# When building booting libary we are trying to
		# bundle or restrict most of external depends
		# with unstable ABI:
		#  - embed libffi (default GHC behaviour)
		#  - disable ncurses support for ghci (via haskeline)
		#    https://bugs.gentoo.org/557478
		#  - disable ncurses support for ghc-pkg
		#echo "libraries/haskeline_CONFIGURE_OPTS *. += --flag=-terminfo" >> mk/build.mk
		echo "*.haskeline.cabal.configure.opts += --flag=-terminfo" >> _build/hadrian.settings
		#echo "utils/ghc-pkg_HC_OPTS += -DBOOTSTRAPPING" >> mk/build.mk
		echo "*.ghc-pkg.cabal.configure.opts += --flag=-terminfo" >> _build/hadrian.settings
	elif is_native; then
		# using ${GTARGET}'s libffi is not supported yet:
		# GHC embeds full path for ffi includes without /usr/${CTARGET} account.
		econf_args+=(--with-system-libffi)
		econf_args+=(--with-ffi-includes=$($(tc-getPKG_CONFIG) libffi --cflags-only-I | sed -e 's@^-I@@'))
	fi

	einfo "Final _build/hadrian.settings:"
	#cat mk/build.mk || die
	cat _build/hadrian.settings || die

#		--enable-bootstrap-with-devel-snapshot \
	econf ${econf_args[@]} \
		$(use_enable elfutils dwarf-unwind) \
		$(use_enable numa) \
		$(use_enable unregisterised)

	if [[ ${PV} == *9999* ]]; then
		GHC_PV="$(grep 'S\[\"PACKAGE_VERSION\"\]' config.status | sed -e 's@^.*=\"\(.*\)\"@\1@')"
		GHC_P=${PN}-${GHC_PV}
	fi
}

src_compile() {
	# create an array of CLI flags to be passed to hadrian build:
	local hadrian_vars=()

	# We can't depend on haddock except when bootstrapping when we
	# must build docs and include them into the binary .tbz2 package
	# app-text/dblatex is not in portage, can not build PDF or PS
	#echo "BUILD_SPHINX_PDF  = NO"  >> mk/build.mk
	hadrian_vars+=("--docs=no-sphinx-pdfs")
	#echo "BUILD_SPHINX_HTML = $(usex doc YES NO)" >> mk/build.mk
	use doc || hadrian_vars+=("--docs=no-sphinx-html")
	#echo "BUILD_MAN = $(usex doc YES NO)" >> mk/build.mk
	use doc || hadrian_vars+=("--docs=no-sphinx-man")
	# this controls presence on 'xhtml' and 'haddock' in final install
	#echo "HADDOCK_DOCS       = YES" >> mk/build.mk
	use doc || hadrian_vars+=("--docs=no-haddocks")

	# Any non-native build has to skip as it needs
	# target haddock binary to be runnabine.
	if ! is_native; then
		# disable docs generation as it requires running stage2
		# echo "HADDOCK_DOCS=NO" >> mk/build.mk
		hadrian_vars+=("--docs=no-haddocks")
		# echo "BUILD_SPHINX_HTML=NO" >> mk/build.mk
		hadrian_vars+=("--docs=no-sphinx-pdfs")
		# echo "BUILD_SPHINX_PDF=NO" >> mk/build.mk
		hadrian_vars+=("--docs=no-sphinx-html")
	fi

#	# allows overriding build flavours for libraries:
#	# v   - vanilla (static libs)
#	# p   - profiled
#	# dyn - shared libraries
#	# example: GHC_LIBRARY_WAYS="v dyn"
#	if [[ -n ${GHC_LIBRARY_WAYS} ]]; then
#		echo "GhcLibWays=${GHC_LIBRARY_WAYS}" >> mk/build.mk
#	fi
#	echo "BUILD_PROF_LIBS = $(usex profile YES NO)" >> mk/build.mk

	###
	# TODO: Move these env vars to a hadrian eclass, for better
	# documentation and clarity
	###

	# Control the build flavour
	if use profile; then
		: ${HADRIAN_FLAVOUR:="default"}
	else
		: ${HADRIAN_FLAVOUR:="default+no_profiled_libs"}
	fi

	hadrian_vars+=("--flavour=${HADRIAN_FLAVOUR}")

	# Control the verbosity of hadrian. Default is one level of --verbose
	${HADRIAN_VERBOSITY:=1}

	local n="${HADRIAN_VERBOSITY}"
	until [[ $n -le 0 ]]; do
		hadrian_vars+=("--verbose")
		n=$(($n - 1 ))
	done

	for i in $MAKEOPTS; do
		case $i in
			-j*) hadrian_vars+=("$i") ;;
			*) true ;;
		esac
	done

#	# Stage1Only crosscompiler does not build stage2
#	if ! is_crosscompile; then
#		# 1. build/pax-mark compiler binary first
#		#emake ghc/stage2/build/tmp/ghc-stage2
#		hadrian -j${nproc} --flavour=quickest stage2:exe:ghc-bin || die
#		# 2. pax-mark (bug #516430)
#		#pax-mark -m _build/stage1/bin/ghc
#		# 2. build/pax-mark haddock using ghc-stage2
#		if is_native; then
#			# non-native build does not build haddock
#			# due to HADDOCK_DOCS=NO, but it could.
#			#emake utils/haddock/dist/build/tmp/haddock
#			hadrian docs --docs=no-sphinx-pdfs --docs=no-sphinx-html || die
#			#pax-mark -m utils/haddock/dist/build/tmp/haddock
#		fi
#	fi
#	# 3. and then all the rest
#	#emake all

	if use ghcbootstrap; then
		local hadrian=( /usr/bin/hadrian )
	else
		local hadrian=( "${S}/hadrian/bootstrap/_build/bin/hadrian" )
	fi
	hadrian+=(
		"${hadrian_vars[@]}"
		binary-dist-dir
	)

	einfo "Running: ${hadrian[@]}"
	"${hadrian[@]}" || die
}

src_test() {
	# TODO: deal with:
	#    - sandbox (pollutes environment)
	#    - extra packages (to extend testsuite coverage)
	# bits are taken from 'validate'
	#local make_test_target='test' # can be fulltest
	# not 'emake' as testsuite uses '$MAKE' without jobserver available
	#make $make_test_target stage=2 THREADS=$(makeopts_jobs)
	hadrian test || die
}

src_install() {
	local package_confdir="${ED}/usr/$(get_libdir)/$(cross)${GHC_P}/lib/package.conf.d"

	[[ -f VERSION ]] || emake VERSION

#	einfo "Running: hadrian install ${hadrian_vars}"
#	hadrian install --prefix="${D}/usr/" ${hadrian_vars} || die

	pushd "${S}/_build/bindist/${P}-${CHOST}" || die
	econf
	emake DESTDIR="${D}" install
	popd

	#emake -j1 install DESTDIR="${D}"

	use llvm && llvmize "${ED}/usr/bin"

	# Skip for cross-targets as they all share target location:
	# /usr/share/doc/ghc-9999/
	if ! is_crosscompile; then
		dodoc "distrib/README" "LICENSE" "VERSION"
	fi

	# rename ghc-shipped files to avoid collision
	# of external packages. Motivating example:
	#  user had installed:
	#      dev-lang/ghc-7.8.4-r0 (with transformers-0.3.0.0)
	#      dev-haskell/transformers-0.4.2.0
	#  then user tried to update to
	#      dev-lang/ghc-7.8.4-r1 (with transformers-0.4.2.0)
	#  this will lead to single .conf file collision.
	local shipped_conf renamed_conf
	for shipped_conf in "${package_confdir}"/*.conf; do
		# rename 'pkg-ver-id.conf' to 'pkg-ver-id-gentoo-${PF}.conf'
		renamed_conf=${shipped_conf%.conf}-gentoo-${PF}.conf
		mv "${shipped_conf}" "${renamed_conf}" || die
	done

	# remove link, but leave 'haddock-${GHC_P}'
	rm -f "${ED}"/usr/bin/$(cross)haddock

	if ! is_crosscompile; then
		newbashcomp "${FILESDIR}"/ghc-bash-completion ghc-pkg
		newbashcomp utils/completion/ghc.bash         ghc
	fi

	# path to the package.cache
	PKGCACHE="${package_confdir}"/package.cache
	# copy the package.conf.d, including timestamp, save it so we can help
	# users that have a broken package.conf.d
	cp -pR "${package_confdir}"{,.initial} || die "failed to backup initial package.conf.d"

	# copy the package.conf, including timestamp, save it so we later can put it
	# back before uninstalling, or when upgrading.
	cp -p "${PKGCACHE}"{,.shipped} \
		|| die "failed to copy package.conf.d/package.cache"

	if is_crosscompile; then
		# When we build a cross-compiler the layout is the following:
		#     usr/lib/${CTARGET}-ghc-${VER}/ contains target libraries
		# but
		#     usr/lib/${CTARGET}-ghc-${VER}/bin/ directory
		# containst host binaries (modulo bugs).

		# Portage's stripping mechanism does not skip stripping
		# foreign binaries. This frequently causes binaries to be
		# broken.
		#
		# Thus below we disable stripping of target libraries and allow
		# stripping hosts executables.
		dostrip -x "/usr/$(get_libdir)/$(cross)${GHC_P}"
		dostrip    "/usr/$(get_libdir)/$(cross)${GHC_P}/bin"
	fi
}

pkg_preinst() {
	# have we got an earlier version of ghc installed?
	if has_version "<${CATEGORY}/${PF}"; then
		haskell_updater_warn="1"
	fi
}

pkg_postinst() {
	ghc-reregister

	# path to the package.cache
	PKGCACHE="${EROOT}/usr/$(get_libdir)/$(cross)${GHC_P}/lib/package.conf.d/package.cache"

	# give the cache a new timestamp, it must be as recent as
	# the package.conf.d directory.
	touch "${PKGCACHE}"

	if [[ "${haskell_updater_warn}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of GHC."
		ewarn "You may have to run"
		ewarn "      'haskell-updater'"
		ewarn "to rebuild all ghc-based Haskell libraries."
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
	fi
}

pkg_prerm() {
	PKGCACHE="${EROOT}/usr/$(get_libdir)/$(cross)${GHC_P}/lib/package.conf.d/package.cache"
	rm -rf "${PKGCACHE}"

	cp -p "${PKGCACHE}"{.shipped,}
}

pkg_postrm() {
	ghc-package_pkg_postrm
}
