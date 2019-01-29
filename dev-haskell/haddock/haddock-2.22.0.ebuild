# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.5.6.9999
#hackport: flags: -in-ghc-tree

CABAL_FEATURES="" # broken test-suite
inherit haskell-cabal

DESCRIPTION="A documentation-generation tool for Haskell libraries"
HOMEPAGE="http://www.haskell.org/haddock/"
SRC_URI="https://github.com/haskell/${PN}/archive/${P}-release.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
# keep in sync with ghc-8.6
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

RESTRICT=test # test suite unavailable on hackage

RDEPEND="~dev-haskell/haddock-api-2.22.0:=
	>=dev-lang/ghc-8.6.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.4.0.1"
#	test? ( ~dev-haskell/haddock-test-0.0.1 )
#"

src_configure() {
	haskell-cabal_src_configure \
		--flag=-in-ghc-tree
}

S=${WORKDIR}/${PN}-${P}-release
