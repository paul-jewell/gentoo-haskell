# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild generated by hackport 0.5.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="conduit instances for classy-prelude"
HOMEPAGE="https://github.com/snoyberg/classy-prelude"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/classy-prelude-0.12.8:=[profile?] <dev-haskell/classy-prelude-0.12.9:=[profile?]
	>=dev-haskell/conduit-1.0:=[profile?] <dev-haskell/conduit-1.3:=[profile?]
	>=dev-haskell/conduit-combinators-0.2.8:=[profile?]
	dev-haskell/monad-control:=[profile?]
	dev-haskell/resourcet:=[profile?]
	dev-haskell/transformers:=[profile?]
	dev-haskell/void:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( dev-haskell/hspec
		dev-haskell/quickcheck )
"
