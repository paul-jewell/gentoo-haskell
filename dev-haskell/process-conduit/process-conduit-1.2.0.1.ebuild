# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.4.2.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Conduits for processes (deprecated)"
HOMEPAGE="http://github.com/snoyberg/process-conduit"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/conduit-1.1:=[profile?]
	>=dev-haskell/control-monad-loop-0.1:=[profile?] <dev-haskell/control-monad-loop-0.2:=[profile?]
	>=dev-haskell/mtl-2.0:=[profile?]
	>=dev-haskell/resourcet-1.1:=[profile?]
	dev-haskell/shakespeare:=[profile?]
	>=dev-haskell/shakespeare-text-1.0:=[profile?]
	>=dev-haskell/text-0.11:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( dev-haskell/conduit-extra
		>=dev-haskell/hspec-1.3 )
"
