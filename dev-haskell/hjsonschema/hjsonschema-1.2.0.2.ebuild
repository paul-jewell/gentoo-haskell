# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild generated by hackport 0.5.1

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="JSON Schema library"
HOMEPAGE="https://github.com/seagreen/hjsonschema"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/aeson-0.11:=[profile?] <dev-haskell/aeson-1.1:=[profile?]
	>=dev-haskell/file-embed-0.0.8:=[profile?] <dev-haskell/file-embed-0.1:=[profile?]
	>=dev-haskell/hjsonpointer-0.3:=[profile?] <dev-haskell/hjsonpointer-1.1:=[profile?]
	>=dev-haskell/http-client-0.4.30:=[profile?] <dev-haskell/http-client-0.6:=[profile?]
	>=dev-haskell/http-types-0.8:=[profile?] <dev-haskell/http-types-0.10:=[profile?]
	>=dev-haskell/pcre-heavy-1.0:=[profile?] <dev-haskell/pcre-heavy-1.1:=[profile?]
	>=dev-haskell/profunctors-5.0:=[profile?] <dev-haskell/profunctors-5.3:=[profile?]
	>=dev-haskell/quickcheck-2.8:2=[profile?] <dev-haskell/quickcheck-2.10:2=[profile?]
	>=dev-haskell/scientific-0.3:=[profile?] <dev-haskell/scientific-0.4:=[profile?]
	>=dev-haskell/semigroups-0.18:=[profile?] <dev-haskell/semigroups-0.19:=[profile?]
	>=dev-haskell/text-1.1:=[profile?] <dev-haskell/text-1.3:=[profile?]
	>=dev-haskell/unordered-containers-0.2:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-haskell/vector-0.10:=[profile?] <dev-haskell/vector-0.12:=[profile?]
	>=dev-lang/ghc-7.8.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
	test? ( dev-haskell/async
		>=dev-haskell/hspec-2.2 <dev-haskell/hspec-2.4
		dev-haskell/wai-app-static
		dev-haskell/warp )
"
