# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils multilib savedconfig toolchain-funcs

DESCRIPTION="simple terminal implementation for X"
HOMEPAGE="https://st.suckless.org/"
SRC_URI="https://dl.suckless.org/st/${P}.tar.gz"

LICENSE="MIT-with-advertising"
SLOT="0"
KEYWORDS="amd64 hppa x86"
IUSE="savedconfig alpha-patch clipboard copyurl delkey extpipe hidecursor
	  scrollback solarized-dark solarized-light spoiler vertcenter
	  no-bold-italic"

RDEPEND="
	>=sys-libs/ncurses-6.0:0=
	media-libs/fontconfig
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXft
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	x11-proto/xextproto
	x11-proto/xproto
"

src_prepare() {
	eapply_user

	sed -e '/^CFLAGS/s:[[:space:]]-O[^[:space:]]*[[:space:]]: :' \
		-e '/^X11INC/{s:/usr/X11R6/include:/usr/include/X11:}' \
		-e "/^X11LIB/{s:/usr/X11R6/lib:/usr/$(get_libdir)/X11:}" \
		-i config.mk || die
	sed -e '/@echo/!s:@::' \
		-e '/tic/d' \
		-i Makefile || die

	if use alpha-patch ; then
		epatch "${FILESDIR}/${PV}/${PN}-alpha-${PV}.diff"
		use vertcenter && ewarn "Can't use alpha patch with vertcenter patch, not using vertcenter"
		if use solarized-dark || use solarized-light ; then
			ewarn "Can't use themes with alpha patch, disabling them"
		fi
	else
		use vertcenter && epatch "${FILESDIR}/${PV}/${PN}-vertcenter-${PV}.diff"
		if use solarized-dark || use solarized-light ; then
			epatch "${FILESDIR}/${PV}/${PN}-no_bold_colors-${PV}.diff"
		fi
		if use solarized-dark ; then
			epatch "${FILESDIR}/${PV}/${PN}-solarized-dark-${PV}.diff"
			use solarized-light && ewarn "Can't use solarized dark and light at the same time, using dark theme"
		elif use solarized-light ; then
			epatch "${FILESDIR}/${PV}/${PN}-solarized-light-${PV}.diff"
		fi
	fi

	use clipboard && epatch "${FILESDIR}/${PV}/${PN}-clipboard-${PV}.diff"
	use copyurl && epatch "${FILESDIR}/${PV}/${PN}-copyurl-${PV}.diff"
	use delkey && epatch "${FILESDIR}/${PV}/${PN}-delkey-${PV}.diff"
	use extpipe && epatch "${FILESDIR}/${PV}/${PN}-extpipe-${PV}.diff"
	use hidecursor && epatch "${FILESDIR}/${PV}/${PN}-hidecursor-${PV}.diff"
	use scrollback && epatch "${FILESDIR}/${PV}/${PN}-scrollback-${PV}.diff"
	use spoiler && epatch "${FILESDIR}/${PV}/${PN}-spoiler-${PV}.diff"
	use no-bold-italic && epatch "${FILESDIR}/${PV}/${PN}-disable-bold-italic-fonts-${PV}.diff"


	tc-export CC

	restore_config config.h
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}"/usr install

	dodoc TODO

	make_desktop_entry ${PN} simpleterm utilities-terminal 'System;TerminalEmulator;' ''

	save_config config.h
}
