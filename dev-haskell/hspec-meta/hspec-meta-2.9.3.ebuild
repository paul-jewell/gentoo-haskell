# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.7.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="A version of Hspec which is used to test Hspec itself"
HOMEPAGE="https://hspec.github.io/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-haskell/ansi-terminal:=[profile?]
	dev-haskell/call-stack:=[profile?]
	dev-haskell/clock:=[profile?]
	>=dev-haskell/quickcheck-2.12:2=[profile?]
	dev-haskell/quickcheck-io:=[profile?]
	dev-haskell/random:=[profile?]
	dev-haskell/setenv:=[profile?]
	>=dev-haskell/stm-2.2:=[profile?]
	>=dev-lang/ghc-8.4.3:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
"
