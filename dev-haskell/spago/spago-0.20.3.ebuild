# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.6.7.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal
RESTRICT="test" # missing files

DESCRIPTION="Please see the README on GitHub at <https://github.com/purescript/spago#readme>"
HOMEPAGE="https://github.com/purescript/spago#readme"
SRC_URI="https://github.com/purescript/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/purescript/purescript-docs-search/releases/download/v0.0.10/purescript-docs-search -> ${PN}-purescript-docs-search-0.0.10
	https://github.com/purescript/purescript-docs-search/releases/download/v0.0.10/docs-search-app.js -> ${PN}-docs-search-app-0.0.10.js
	https://github.com/purescript/purescript-docs-search/releases/download/v0.0.11/purescript-docs-search -> ${PN}-purescript-docs-search-0.0.11
	https://github.com/purescript/purescript-docs-search/releases/download/v0.0.11/docs-search-app.js -> ${PN}-docs-search-app-0.0.11.js
	"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"

# Does not compile with >=dev-haskell/versions-5
RDEPEND="dev-haskell/aeson:=[profile?]
	dev-haskell/aeson-pretty:=[profile?]
	dev-haskell/ansi-terminal:=[profile?]
	dev-haskell/async-pool:=[profile?]
	dev-haskell/bower-json:=[profile?]
	dev-haskell/cryptonite:=[profile?]
	dev-haskell/either:=[profile?]
	dev-haskell/file-embed:=[profile?]
	dev-haskell/foldl:=[profile?]
	dev-haskell/fsnotify:=[profile?]
	dev-haskell/generic-lens:=[profile?]
	dev-haskell/glob:=[profile?]
	dev-haskell/http-client:=[profile?]
	dev-haskell/http-conduit:=[profile?]
	dev-haskell/http-types:=[profile?]
	dev-haskell/lens-family-core:=[profile?]
	dev-haskell/megaparsec:=[profile?]
	dev-haskell/mtl:=[profile?]
	dev-haskell/network-uri:=[profile?]
	dev-haskell/open-browser:=[profile?]
	dev-haskell/optparse-applicative:=[profile?]
	dev-haskell/prettyprinter:=[profile?]
	dev-haskell/retry:=[profile?]
	>=dev-haskell/rio-0.1.16.0:=[profile?]
	dev-haskell/rio-orphans:=[profile?]
	dev-haskell/safe:=[profile?]
	dev-haskell/semver-range:=[profile?]
	dev-haskell/stm:=[profile?]
	dev-haskell/stringsearch:=[profile?]
	dev-haskell/tar:=[profile?]
	dev-haskell/temporary:=[profile?]
	<dev-haskell/text-1.3:=[profile?]
	dev-haskell/turtle:=[profile?]
	dev-haskell/unliftio:=[profile?]
	dev-haskell/unordered-containers:=[profile?]
	dev-haskell/utf8-string:=[profile?]
	<dev-haskell/versions-5:=[profile?]
	dev-haskell/with-utf8:=[profile?]
	dev-haskell/zlib:=[profile?]
	>=dev-lang/dhall-1.38.0:=[profile?]
	>=dev-lang/ghc-8.8.3:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.0.1.0"
#	test? ( dev-haskell/extra
#		>=dev-haskell/hspec-2 <dev-haskell/hspec-3
#		dev-haskell/hspec-megaparsec
#		dev-haskell/quickcheck )

PURESCRIPT_DOCS_FILES=(
	"purescript-docs-search-0.0.10"
	"purescript-docs-search-0.0.11"
	"docs-search-app-0.0.10.js"
	"docs-search-app-0.0.11.js"
)

src_prepare() {
	for filename in "${PURESCRIPT_DOCS_FILES[@]}"
	do
		cp -v "${DISTDIR}/${PN}-${filename}" "${S}/templates/${filename}" || die
	done
	default
}
