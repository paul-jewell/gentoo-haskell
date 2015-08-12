# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="indentation sensitive parser-combinators for parsec"
HOMEPAGE="http://patch-tag.com/r/salazar/indents"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="<dev-haskell/concatenative-2:=[profile?]
	<dev-haskell/mtl-3:=[profile?]
	>=dev-haskell/parsec-3:=[profile?] <dev-haskell/parsec-4:=[profile?]
	>=dev-lang/ghc-6.10.4:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6.0.3
"

src_prepare() {
	# https://ghc.haskell.org/trac/ghc/ticket/10667
	[[ $(ghc-version) == 7.10.1.20150630 ]] && replace-hcflags -g ''
	[[ $(ghc-version) == 7.10.2 ]] && replace-hcflags -g ''
}
