# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.1.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal

MY_PN="NanoProlog"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Very small  interpreter for a Prolog-like language"
HOMEPAGE="http://hackage.haskell.org/package/NanoProlog"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/listlike-3.1:=[profile?]
		>=dev-haskell/uu-parsinglib-2.7.1:=[profile?]
		>=dev-lang/ghc-7.0.1:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	CABAL_FILE=${MY_PN}.cabal cabal_chdeps \
		'containers     == 0.4.*' 'containers     >= 0.4' \
		'uu-parsinglib  >= 2.7.1  && < 2.8' 'uu-parsinglib  >= 2.7.1' \
		'ListLike       == 3.1.*' 'ListLike       >= 3.1'
}
