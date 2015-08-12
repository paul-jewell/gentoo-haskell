# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# ebuild generated by hackport 0.3.3.9999

CABAL_FEATURES="bin"
inherit darcs eutils haskell-cabal

DESCRIPTION="Nikki and the robots game"
HOMEPAGE="http://joyridelabs.de/"
EDARCS_REPOSITORY="http://code.joyridelabs.de/nikki"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
IUSE="devel"

RDEPEND="dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtopengl
"
DEPEND="${RDEPEND}
	dev-haskell/aeson
	dev-haskell/bifunctors
	dev-haskell/binary
	>=dev-haskell/binary-communicator-1.0.2
	>=dev-haskell/cabal-1.16.0
	>=dev-haskell/clocked-0.4.1 <dev-haskell/clocked-0.4.2
	>=dev-haskell/cmdargs-0.6.6
	>=dev-haskell/crypto-pubkey-types-0.1 <dev-haskell/crypto-pubkey-types-0.5
	>=dev-haskell/data-accessor-0.2.1.7
	>=dev-haskell/data-accessor-mtl-0.2.0.2
	>=dev-haskell/email-validate-1.0 <dev-haskell/email-validate-2.1
	>=dev-haskell/findbin-0.0.5
	>=dev-haskell/hipmunk-5.2.0.6
	>=dev-haskell/http-4000.2 <dev-haskell/http-4000.3
	>=dev-haskell/libzip-0.2.0.4
	>=dev-haskell/monadcatchio-transformers-0.2.2.2
	>=dev-haskell/mtl-2 <dev-haskell/mtl-3
	>=dev-haskell/network-2 <dev-haskell/network-3
	>=dev-haskell/parsec-3 <dev-haskell/parsec-4
	dev-haskell/random
	>=dev-haskell/rsa-1.2.1
	dev-haskell/safe
	>=dev-haskell/sfml-audio-0.7.1 <dev-haskell/sfml-audio-0.8
	dev-haskell/statevar
	>=dev-haskell/stickykeyshotkey-0.1 <dev-haskell/stickykeyshotkey-0.2
	>=dev-haskell/strict-0.3.2
	dev-haskell/string-conversions
	>=dev-haskell/template-0.2 <dev-haskell/template-0.3
	>=dev-haskell/temporary-1.1.1
	dev-haskell/text
	dev-haskell/transformers
	>=dev-haskell/uniplate-1.6
	>=dev-haskell/utf8-string-0.3
	>=dev-haskell/vector-0.10 <dev-haskell/vector-0.11
	>=dev-lang/ghc-7.6.1
	|| ( ( >=dev-haskell/hashable-1.1 <dev-haskell/hashable-1.2 )
		( >=dev-haskell/hashable-1.2 <dev-haskell/hashable-1.3 ) )
	|| ( <dev-haskell/mtl-2.1
		>dev-haskell/mtl-2.1 )
	|| ( ( >=dev-haskell/transformers-0.2 <dev-haskell/transformers-0.3 )
		( >=dev-haskell/transformers-0.3 <dev-haskell/transformers-0.5 ) )
	dev-util/cmake
"

S="${WORKDIR}/${P}/src"

src_prepare() {
	epatch "${FILESDIR}"/${P}-ev-2.0.patch
	epatch "${FILESDIR}"/${P}-ghc-7.8.patch

	cabal_chdeps \
		'-Werror' ' ' \
		'-optl-s' ' ' \
		'transformers == 0.2.* || == 0.3.*' 'transformers >= 0.2 && < 0.5' \
		', network == 2.*' ', network == 2.*, network-uri, string-conversions' \
		'utf8-string == 0.3.*' 'utf8-string >= 0.3' \
		'deepseq == 1.3.*' 'deepseq >= 1.3'
}

src_configure() {
	# FIXME: cmake hack!
	cmake cpp || die
	emake

	haskell-cabal_src_configure \
		$(cabal_flag devel devel) \
		--extra-lib-dirs=.
}

src_install() {
	haskell-cabal_src_install

	# FIXME: it's sharedir is fun :]
	insinto /usr/bin
	doins -r ../data/
}
