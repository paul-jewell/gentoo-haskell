# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.6

CABAL_FEATURES="bin test-suite"
inherit haskell-cabal

DESCRIPTION="Perform basic syntax and deliverability checks on email addresses"
HOMEPAGE="http://hackage.haskell.org/package/email-validator"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.16.0
	>=dev-haskell/cmdargs-0.10 <dev-haskell/cmdargs-0.11
	>=dev-haskell/dns-1 <dev-haskell/dns-2
	>=dev-haskell/email-validate-2 <dev-haskell/email-validate-3
	>=dev-haskell/hunit-1.2 <dev-haskell/hunit-1.3
	>=dev-haskell/parallel-io-0.3 <dev-haskell/parallel-io-0.4
	>=dev-haskell/pcre-light-0.4
	>=dev-haskell/tasty-0.8 <dev-haskell/tasty-0.9
	>=dev-haskell/tasty-hunit-0.8 <dev-haskell/tasty-hunit-0.9
	>=dev-lang/ghc-7.6.1
	test? ( >=dev-haskell/doctest-0.9 <dev-haskell/doctest-0.10 )
"

src_install() {
	haskell-cabal_src_install
	doman "${S}/doc/man1/${PN}.1"
}
