# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.2.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Implements IDNA (RFC 3490)"
HOMEPAGE="http://hackage.haskell.org/package/idna"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=">=dev-haskell/punycode-2.0:=[profile?]
		>=dev-haskell/stringprep-0.1.2:=[profile?]
		>=dev-haskell/text-0.1:=[profile?]
		>=dev-lang/ghc-7.0.1:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"
