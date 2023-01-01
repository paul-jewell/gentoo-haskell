# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.0.0.9999
#hackport: flags: -debug,-dev,-has-llvm,use-c-malloc:c-malloc,use-unliftio:unliftio,streamly-core:minimal,+opt,inspection:test

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Dataflow programming and declarative concurrency"
HOMEPAGE="https://streamly.composewell.com"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="c-malloc fusion-plugin limit-build-mem minimal no-fusion streamk test unliftio"
RESTRICT+=" !test? ( test )"

CABAL_CHDEPS=(
	'inspection-testing >= 0.4   && < 0.5' 'inspection-testing >= 0.4'
	'template-haskell   >= 2.14  && < 2.17' 'template-haskell >= 2.14'
)

RDEPEND=">=dev-haskell/fusion-plugin-types-0.1:=[profile?] <dev-haskell/fusion-plugin-types-0.2:=[profile?]
	>=dev-haskell/heaps-0.3:=[profile?] <dev-haskell/heaps-0.5:=[profile?]
	>=dev-haskell/primitive-0.5.4:=[profile?] <dev-haskell/primitive-0.8:=[profile?]
	>=dev-haskell/transformers-base-0.4:=[profile?] <dev-haskell/transformers-base-0.5:=[profile?]
	>=dev-lang/ghc-8.10.1:=
	test? (
		>=dev-haskell/inspection-testing-0.4:=[profile?]
	 )
	!minimal? (
		>=dev-haskell/atomic-primops-0.8:=[profile?] <dev-haskell/atomic-primops-0.9:=[profile?]
		>=dev-haskell/lockfree-queue-0.2.4:=[profile?] <dev-haskell/lockfree-queue-0.3:=[profile?]
		>=dev-haskell/network-2.6:=[profile?] <dev-haskell/network-3.2:=[profile?]
		>=dev-haskell/unicode-data-0.1:=[profile?] <dev-haskell/unicode-data-0.4:=[profile?]
	)
	unliftio? (
		>=dev-haskell/unliftio-core-0.2:=[profile?] <dev-haskell/unliftio-core-0.3:=[profile?]
	)
	!unliftio? (
		>=dev-haskell/monad-control-1.0:=[profile?] <dev-haskell/monad-control-1.1:=[profile?]
	)
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.2.0.0
	test? (
		>=dev-haskell/hspec-2.0
		>=dev-haskell/network-3.1 <dev-haskell/network-3.2
		>=dev-haskell/quickcheck-2.13 <dev-haskell/quickcheck-2.15
		>=dev-haskell/random-1.0.0 <dev-haskell/random-1.3
		>=dev-haskell/temporary-1.3 <dev-haskell/temporary-1.4
		fusion-plugin? (
			>=dev-haskell/fusion-plugin-0.2 <dev-haskell/fusion-plugin-0.3
		)
	)
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=-debug \
		--flag=-dev \
		$(cabal_flag fusion-plugin fusion-plugin) \
		--flag=-has-llvm \
		$(cabal_flag test inspection) \
		$(cabal_flag limit-build-mem limit-build-mem) \
		$(cabal_flag no-fusion no-fusion) \
		--flag=opt \
		$(cabal_flag streamk streamk) \
		$(cabal_flag minimal streamly-core) \
		$(cabal_flag c-malloc use-c-malloc) \
		$(cabal_flag unliftio use-unliftio)
}

src_test() {
	if use test; then
		cabal-register-inplace || die
		local pkg_db="${S}/dist/package.conf.inplace"

		local old_S="${S}"
		export S="${S}/test"
		pushd "${S}" > /dev/null || die

		CABAL_FILE="${S}/${CABAL_PN}-tests.cabal" \
			cabal_chdeps \
			'hspec             >= 2.0   && < 2.10' 'hspec >= 2.0'

		CABAL_TEST_SUITE=yes \
			CABAL_USE_HADDOCK='' \
			CABAL_FILE="${S}/${CABAL_PN}-tests.cabal" \
			haskell-cabal_src_configure \
			--package-db="${pkg_db}" \
			$(cabal_flag fusion-plugin fusion-plugin) \
			$(cabal_flag limit-build-mem limit-build-mem) \
			--flag=-use-large-mem \
			--flag=-include-flaky-tests \
			--flag=-dev \
			--flag=-has-llvm \
			--flag=opt

		CABAL_FILE="${S}/${CABAL_PN}-tests.cabal" \
			haskell-cabal_src_compile

		CABAL_FILE="${S}/${CABAL_PN}-tests.cabal" \
			SKIP_REGISTER_INPLACE=yes \
			haskell-cabal_src_test

		export S="${old_S}"
		popd > /dev/null || die
	fi
}
