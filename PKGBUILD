# Maintainer: Safing ICS Technologies <noc@safing.io>
#
# Application Firewall: Block Mass Surveillance - Love Freedom
# The Portmaster enables you to protect your data on your device. You
# are back in charge of your outgoing connections: you choose what data
# you share and what data stays private. Read more on docs.safing.io.
#
pkgname=portmaster-bin
pkgver=0.7.0
pkgrel=1
pkgdesc='Application Firewall: Block Mass Surveillance - Love Freedom'
arch=('x86_64')
url='https://safing.io/portmaster'
license=('AGPL3')
depends=('libnetfilter_queue')
makedepends=('imagemagick') # for convert
optdepends=('libappindicator-gtk3: for systray indicator')
options=('!strip')
provides=('portmaster')
conflicts=('portmaster')
install=arch.install
source=("portmaster-start::https://updates.safing.io/linux_amd64/start/portmaster-start_v${pkgver//./-}"
		'portmaster.desktop'
		'portmaster_notifier.desktop'
		'portmaster_logo.png'
		"portmaster.service")
noextract=('portmaster-start')
sha256sums=('6ade636aaf2b608f251972fd98b25a8020b301023a6377e5275de5195a132e7f'
         '276209488a70d2e7ce269d18fe5780dc64e6e318a759b6231ee12e42ce275683'
         '26de52c4eece41d2373cf60bfd61eb28d13d9e510102830a8298ca41fa143abc'
         'ecb02625952594af86d3b53762363c1e227c2b9604fc9c9423682fc87a92a957'
         '6676f10f49d21bf184edf5c00759d0a7c5c6f8b5538abf261226eaadb2b38670')

prepare() {
	for res in 16 32 48 96 128 ; do
		local iconpath="${srcdir}/icons/${res}x${res}/"
		mkdir -p "${iconpath}" ; 
		convert ./portmaster_logo.png -resize "${res}x${res}" "${iconpath}/portmaster.png" ; 
	done
}

package() {
    install -Dm 0755 "${srcdir}/portmaster-start" "${pkgdir}/opt/portmaster/portmaster-start"
    install -Dm 0644 "${srcdir}/portmaster.desktop" "${pkgdir}/opt/portmaster/portmaster.desktop"
    install -Dm 0644 "${srcdir}/portmaster_notifier.desktop" "${pkgdir}/opt/portmaster/portmaster_notifier.desktop"
    install -dm 0755 "${pkgdir}/etc/xdg/autostart"
    ln -s "/opt/portmaster/portmaster_notifier.desktop" "${pkgdir}/etc/xdg/autostart/portmaster_notifier.desktop"
    install -Dm 0644 "${srcdir}/portmaster.service" "${pkgdir}/opt/portmaster/portmaster.service"
    install -Dm 0644 "${srcdir}/icons/32x32/portmaster.png" "${pkgdir}/usr/share/pixmaps/portmaster.png"
    install -Dm 0644 "${srcdir}/icons/16x16/portmaster.png" "${pkgdir}/usr/share/icons/hicolor/16x16/apps/portmaster.png"
    install -Dm 0644 "${srcdir}/icons/32x32/portmaster.png" "${pkgdir}/usr/share/icons/hicolor/32x32/apps/portmaster.png"
    install -Dm 0644 "${srcdir}/icons/48x48/portmaster.png" "${pkgdir}/usr/share/icons/hicolor/48x48/apps/portmaster.png"
    install -Dm 0644 "${srcdir}/icons/96x96/portmaster.png" "${pkgdir}/usr/share/icons/hicolor/96x96/apps/portmaster.png"
    install -Dm 0644 "${srcdir}/icons/128x128/portmaster.png" "${pkgdir}/usr/share/icons/hicolor/128x128/apps/portmaster.png"
}
