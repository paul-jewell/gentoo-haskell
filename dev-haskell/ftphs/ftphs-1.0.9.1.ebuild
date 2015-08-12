# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.3.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="FTP Client and Server Library"
HOMEPAGE="https://github.com/jgoerzen/ftphs/wiki"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="buildtests"

RDEPEND="dev-haskell/hslogger:=[profile?]
		>=dev-haskell/missingh-1.0.0:=[profile?]
		dev-haskell/mtl:=[profile?]
		dev-haskell/network:=[profile?]
		dev-haskell/parsec:=[profile?]
		dev-haskell/regex-compat:=[profile?]
		>=dev-lang/ghc-6.10.4:=
		buildtests? ( dev-haskell/hunit:=[profile?]
			dev-haskell/testpack:=[profile?]
		)"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.2.3"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag buildtests buildtests)
}
