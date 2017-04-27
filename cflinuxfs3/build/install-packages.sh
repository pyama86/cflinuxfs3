set -e -x

source /etc/lsb-release

function apt_get() {
  apt-get -y --force-yes --no-install-recommends "$@"
}

packages="
cron
less
libcap2-bin
libcurl3-dev
libmariadbclient-dev
libsqlite-dev
libxml2-dev

ruby
"

if [ "`uname -m`" == "ppc64le" ]; then
packages=$(sed '/\b\(libopenblas-dev\|libdrm-intel1\|dmidecode\)\b/d' <<< "${packages}")
ubuntu_url="http://ports.ubuntu.com/ubuntu-ports"
else
ubuntu_url="http://archive.ubuntu.com/ubuntu"
fi

cat > /etc/apt/sources.list <<EOS
deb $ubuntu_url $DISTRIB_CODENAME main universe multiverse
deb $ubuntu_url $DISTRIB_CODENAME-updates main universe multiverse
deb $ubuntu_url $DISTRIB_CODENAME-security main universe multiverse
EOS

# install gpgv so we can update
apt_get install gpgv
apt_get update
apt_get dist-upgrade
apt_get install ubuntu-minimal $packages
apt-get clean

rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/groff/* /usr/share/info/* /usr/share/lintian/* /usr/share/linda/*

