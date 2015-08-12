# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.2.18.9999

CABAL_FEATURES="bin"
inherit git-2 haskell-cabal

MY_PN="BlogLiterately"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A tool for posting Haskelly articles to blogs"
HOMEPAGE="http://github.com/trofi/BlogLiterately"
EGIT_REPO_URI="git://github.com/trofi/${MY_PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=app-text/pandoc-1.14:=
	>=dev-haskell/attoparsec-0.12:=
	>=dev-haskell/blaze-html-0.5:=
	>=dev-haskell/blaze-markup-0.5:=
	>=dev-haskell/haxml-1.22:=
	>=dev-haskell/haxr-3000.2.1:=
	>=dev-haskell/highlighting-kate-0.5.3.0:=
	>=dev-haskell/hscolour-1.15:=
	>=dev-haskell/parsec-2.1.0.0:=
	>=dev-haskell/xhtml-3000.2:=
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.5
"

S="${WORKDIR}/${MY_P}"
