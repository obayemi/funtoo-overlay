# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

XPP=xpp
XPP_V=1.3.6
I3IPCPP=i3ipcpp

DESCRIPTION="A fast and easy-to-use tool for creating status bars"
HOMEPAGE="https://github.com/jaagr/polybar"
SRC_URI="
	https://github.com/jaagr/polybar/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/jaagr/xpp/archive/1.3.6.tar.gz -> xpp-1.3.6.tar.gz
	https://github.com/jaagr/i3ipcpp/archive/v0.6.2.tar.gz -> i3ipcpp-0.6.2.tar.gz
"

PYTHON_COMPAT=( python2_7 )
SLOT="0"
inherit cmake-utils python-single-r1

KEYWORDS="~amd64 ~x86"
IUSE="xkeyboard network mpd i3 curl alsa +ccache"

DEPEND="
	alsa? ( media-libs/alsa-lib )
	i3? ( dev-libs/jsoncpp )
	mpd? ( media-libs/libmpdclient )
	network? ( net-wireless/wireless-tools )
	ccache? ( ccache )
	x11-libs/cairo
	x11-libs/libxcb
	x11-proto/xcb-proto
	x11-libs/xcb-util-image
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-xrm
"
RDEPEND="${DEPEND}"

src_prepare() {
	rmdir ${WORKDIR}/${P}/lib/xpp
	ln -s ${WORKDIR}/xpp-1.3.6 ${WORKDIR}/${P}/lib/xpp

	rmdir ${WORKDIR}/${P}/lib/i3ipcpp
	ln -s ${WORKDIR}/i3ipcpp-0.6.2 ${WORKDIR}/${P}/lib/i3ipcpp

	eapply_user
}


src_configure () {

	local mycmakeargs=(
		-DENABLE_ALSA=$(usex alsa)
		-DENABLE_CCACHE=$(usex ccache)
		-DENABLE_CURL=$(usex curl)
		-DENABLE_I3=$(usex i3)
		-DENABLE_MPD=$(usex mpd)
		-DENABLE_NETWORK=$(usex network)
		-DENABLE_XKEYBOARD=$(usex xkeyboard)
	)

	cmake-utils_src_configure
}

# src_compile() {
# 	emake || die "emake failed"
# }
