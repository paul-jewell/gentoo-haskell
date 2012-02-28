# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

# ebuild generated by hackport 0.2.16.9999

EAPI=4

CABAL_FEATURES="bin"
inherit base haskell-cabal

DESCRIPTION="manage files with git, without checking their contents into git"
HOMEPAGE="http://git-annex.branchable.com/"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-vcs/git-1.7.7" # TODO: add more deps?
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6
		dev-haskell/dataenc
		dev-haskell/hs3
		dev-haskell/hslogger
		dev-haskell/http
		dev-haskell/ifelse
		dev-haskell/json
		dev-haskell/lifted-base
		dev-haskell/missingh
		dev-haskell/monad-control
		>=dev-haskell/mtl-2
		dev-haskell/network
		dev-haskell/pcre-light
		>=dev-haskell/quickcheck-2.1
		dev-haskell/sha
		dev-haskell/text
		dev-haskell/time
		dev-haskell/transformers-base
		dev-haskell/utf8-string
		>=dev-lang/ghc-7.4"

PATCHES=("${FILESDIR}"/${PN}-3.20120227-text-dep.patch)
