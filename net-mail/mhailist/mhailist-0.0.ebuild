# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# ebuild generated by hackport 0.2.13

EAPI="3"

CABAL_FEATURES="bin"
inherit base haskell-cabal

MY_PN="Mhailist"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Haskell mailing list manager"
HOMEPAGE="http://hackage.haskell.org/package/Mhailist"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
		dev-haskell/binary
		>=dev-haskell/cabal-1.6
		dev-haskell/mtl
		dev-haskell/time-locale-compat
		>=dev-lang/ghc-6.10.1"

PATCHES=("${FILESDIR}/${PN}"-0.0-ghc-7.2.patch
	"${FILESDIR}/${PN}"-0.0-time-1.5.patch
)

S="${WORKDIR}/${MY_P}"
