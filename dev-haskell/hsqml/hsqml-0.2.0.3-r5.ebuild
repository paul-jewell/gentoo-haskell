# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
CABAL_FEATURES+=" nocabaldep"
inherit haskell-cabal

DESCRIPTION="Haskell binding for Qt Quick"
HOMEPAGE="http://www.gekkou.co.uk/software/hsqml/"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="+forceghcilib +threadedtestsuite usepkgconfig"

RDEPEND=">=dev-haskell/network-2.3:=[profile?] <dev-haskell/network-2.7:=[profile?]
	dev-haskell/network-uri:=[profile?]
	>=dev-haskell/tagged-0.4:=[profile?] <dev-haskell/tagged-0.8:=[profile?]
	>=dev-haskell/text-0.11:=[profile?]
	>=dev-haskell/transformers-0.2:=[profile?] <dev-haskell/transformers-0.5:=[profile?]
	>=dev-lang/ghc-7.4.1:=
	dev-qt/qtdeclarative:4
	dev-qt/qtscript:4
	sys-devel/gcc[cxx]
"
DEPEND="${RDEPEND}
	dev-haskell/c2hs
	>=dev-haskell/cabal-1.14
	virtual/pkgconfig
	test? ( >=dev-haskell/quickcheck-2.4:2 <dev-haskell/quickcheck-2.7:2 )
"

RESTRICT=test # needs X

src_prepare() {
	cabal_chdeps \
		'network      >= 2.3 && < 2.5' 'network      >= 2.3 && < 2.7, network-uri' \
		'network    >= 2.3 && < 2.5' 'network    >= 2.3 && < 2.7' \
		'QuickCheck >= 2.4 && < 2.7' 'QuickCheck >= 2.4 && < 2.8' \
		'transformers >= 0.2 && < 0.4' 'transformers >= 0.2 && < 0.5' \
		'text         >= 0.11 && < 1.2' 'text         >= 0.11' \
		'text       >= 0.11 && < 1.2' 'text       >= 0.11'
}

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag forceghcilib forceghcilib) \
		$(cabal_flag threadedtestsuite threadedtestsuite) \
		$(cabal_flag usepkgconfig usepkgconfig) \
		--constraint="Cabal == $(cabal-version)"
}
