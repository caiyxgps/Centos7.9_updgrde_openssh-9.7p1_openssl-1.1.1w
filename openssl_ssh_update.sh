yum install -y gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel pam-devel wget vim unzip lrzsz
yum install -y pam* zlib*
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
mkdir -p /app/src
cd /app/src
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1w.tar.gz
wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.7p1.tar.gz
tar xf openssl-1.1.1w.tar.gz
cd /app/src/openssl-1.1.1w/
mkdir /usr/local/openssl
./config --prefix=/usr/local/openssl
make && make install
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl /usr/include/openssl.bak
unlink /usr/lib64/libssl.so
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ln -s /usr/local/openssl/lib/libssl.so /usr/lib64/libssl.so
echo '/usr/local/openssl/lib' >> /etc/ld.so.conf
ldconfig -v
ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
openssl version

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
cp /etc/pam.d/sshd /etc/pam.d/sshd.backup
yum install -y wget gcc pam-devel libselinux-devel zlib-devel openssl-devel perl
rpm -e --nodeps `rpm -qa | grep openssh`
cd /app/src
tar -zxvf openssh-9.7p1.tar.gz
cd /app/src/openssh-9.7p1/
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam --with-zlib --with-tcp-wrappers --with-ssl-dir=/usr/local/openssl --without-hardening
make && make install
chmod 600 /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key
cp -af contrib/redhat/sshd.init /etc/init.d/sshd
chmod u+x /etc/init.d/sshd
mv -f /etc/pam.d/sshd.backup /etc/pam.d/sshd
mv -f /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
chkconfig --add sshd
chkconfig sshd on
systemctl restart sshd
ssh -V
