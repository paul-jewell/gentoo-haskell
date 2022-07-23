# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.6.7.9999
#hackport: flags: -monolithic,+network-uri,-debug-tracetree,-debug-expensive-assertions

CABAL_FEATURES=""
inherit haskell-cabal

DESCRIPTION="The command-line interface for Cabal and Hackage"
HOMEPAGE="https://www.haskell.org/cabal/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
# keep in sync with cabal-3.4
KEYWORDS="~amd64 ~x86"
IUSE="debug-conflict-sets +lukko +native-dns"

RDEPEND=">=dev-haskell/async-2.0:= <dev-haskell/async-2.3:=
	>=dev-haskell/base16-bytestring-0.1.1:=
	>=dev-haskell/cabal-3.4:= <dev-haskell/cabal-3.5:=
	>=dev-haskell/cryptohash-sha256-0.11:= <dev-haskell/cryptohash-sha256-0.12:=
	>=dev-haskell/echo-0.1.3:= <dev-haskell/echo-0.2:=
	>=dev-haskell/edit-distance-0.2.2:= <dev-haskell/edit-distance-0.3:=
	>=dev-haskell/hackage-security-0.6.0.1:= <dev-haskell/hackage-security-0.7:=
	>=dev-haskell/hashable-1.0:=
	>=dev-haskell/http-4000.1.5:= <dev-haskell/http-4000.5:=
	>=dev-haskell/mtl-2.0:= <dev-haskell/mtl-2.3:=
	>=dev-haskell/network-uri-2.6.0.2:= <dev-haskell/network-uri-2.7:=
	>=dev-haskell/parsec-3.1.13.0:= <dev-haskell/parsec-3.2:=
	>=dev-haskell/random-1.2:= <dev-haskell/random-1.3:=
	>=dev-haskell/regex-base-0.94.0.0:= <dev-haskell/regex-base-0.95:=
	>=dev-haskell/regex-posix-0.96.0.0:= <dev-haskell/regex-posix-0.97:=
	>=dev-haskell/stm-2.0:= <dev-haskell/stm-2.6:=
	>=dev-haskell/tar-0.5.0.3:= <dev-haskell/tar-0.6:=
	>=dev-haskell/text-1.2.3:= <dev-haskell/text-1.3:=
	>=dev-haskell/zlib-0.5.3:= <dev-haskell/zlib-0.7:=
	>=dev-lang/ghc-8.4.3:=
	lukko? ( >=dev-haskell/lukko-0.1:= <dev-haskell/lukko-0.2:= )
	native-dns? ( >=dev-haskell/resolv-0.1.1:= <dev-haskell/resolv-0.2:= )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-2.2.0.1
"

src_prepare() {
	default

	#if use noprefs; then
	#	epatch "${FILESDIR}/${PN}"-0.13.3-nopref.patch
	#fi

	# no chance to link to -threaded on ppc64, alpha and others
	# who use UNREG, not only ARM
	if ! ghc-supports-threaded-runtime; then
		cabal_chdeps '-threaded' ' '
	fi
	eapply_user
}

src_prepare() {
	default
	cabal_chdeps \
		'base       >= 4.8      && < 4.15' 'base       >= 4.8' \
		'hashable   >= 1.0      && < 1.4' 'hashable >=1.0' \
		'base16-bytestring >= 0.1.1 && < 0.2' 'base16-bytestring >=0.1.1' \
		'HTTP       >= 4000.1.5 && < 4000.4' 'HTTP       >= 4000.1.5 && < 4000.5'
	eapply_user
}

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag debug-conflict-sets debug-conflict-sets) \
		--flag=-debug-expensive-assertions \
		--flag=-debug-tracetree \
		$(cabal_flag lukko lukko) \
		--flag=-monolithic \
		$(cabal_flag native-dns native-dns) \
		--flag=network-uri
}
