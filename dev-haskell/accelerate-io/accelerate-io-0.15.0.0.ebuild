# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.4.4.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Read and write Accelerate arrays in various formats"
HOMEPAGE="https://github.com/AccelerateHS/accelerate-io"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="+bounds-checks internal-checks unsafe-checks"

RDEPEND=">=dev-haskell/accelerate-0.15:=[profile?] <dev-haskell/accelerate-0.16:=[profile?]
	>=dev-haskell/bmp-1.2:=[profile?]
	>=dev-haskell/repa-3.2:=[profile?]
	>=dev-haskell/vector-0.9:=[profile?]
	>=dev-lang/ghc-7.6.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.16.0
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag bounds-checks bounds-checks) \
		$(cabal_flag internal-checks internal-checks) \
		$(cabal_flag unsafe-checks unsafe-checks)
}
