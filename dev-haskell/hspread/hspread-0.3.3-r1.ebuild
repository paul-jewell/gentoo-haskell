# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit base haskell-cabal

DESCRIPTION="A client library for the spread toolkit"
HOMEPAGE="http://hackage.haskell.org/package/hspread"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/binary-0.3:=[profile?]
		dev-haskell/extensible-exceptions:=[profile?]
		dev-haskell/network:=[profile?]
		>=dev-lang/ghc-6.10.4:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"

PATCHES=(
	"${FILESDIR}"/${P}-ghc-7.6.patch
	"${FILESDIR}"/${P}-ghc-7.10.patch
)
