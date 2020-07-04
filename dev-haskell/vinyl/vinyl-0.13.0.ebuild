# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.6.5.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Extensible Records"
HOMEPAGE="http://hackage.haskell.org/package/vinyl"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT=test # ambiguous modules base-4.9.1.0 type-equality-0.1.2

RDEPEND=">=dev-lang/ghc-8.4.3:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
	test? ( >=dev-haskell/aeson-1.4
		>=dev-haskell/doctest-0.8
		>=dev-haskell/hspec-2.2.4 <dev-haskell/hspec-2.8
		dev-haskell/lens
		dev-haskell/lens-aeson
		dev-haskell/microlens
		dev-haskell/mtl
		>=dev-haskell/should-not-typecheck-2.0 <dev-haskell/should-not-typecheck-2.2
		>=dev-haskell/singletons-0.10
		dev-haskell/text
		dev-haskell/unordered-containers
		dev-haskell/vector )
"
