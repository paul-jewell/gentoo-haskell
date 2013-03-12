# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# ebuild generated by hackport 0.3.2.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Cabal support for creating Mac OSX application bundles."
HOMEPAGE="http://github.com/gimbo/cabal-macosx"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/cabal-1.6:=[profile?]
		>=dev-haskell/fgl-5.4.2.2:=[profile?]
		<dev-haskell/fgl-5.5:=[profile?]
		dev-haskell/missingh:=[profile?]
		dev-haskell/parsec:=[profile?]
		>=dev-lang/ghc-6.10.4:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"
