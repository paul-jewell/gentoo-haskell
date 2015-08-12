# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# ebuild generated by hackport 0.2.17.9999

EAPI=4

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

MY_PN="HJScript"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HJScript is a Haskell EDSL for writing JavaScript programs"
HOMEPAGE="http://patch-tag.com/r/nibro/hjscript"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/hjavascript-0.4.6[profile?]
		>=dev-haskell/hsx-0.10.2[profile?]
		<dev-haskell/hsx-0.11[profile?]
		dev-haskell/mtl[profile?]
		>=dev-lang/ghc-6.8.2"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"

S="${WORKDIR}/${MY_P}"
