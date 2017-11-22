def test_knot_is_installed(host):
    knot = host.package("knot2")
    assert knot.is_installed

       sysrc knot_enable=YES                                                                                                   
           sysrc knot_config=/usr/local/etc/knot/knot.conf                                            
               service knot start
               pkg install -y unbound

/var/db/knot/home.lan.zone exists

/usr/local/etc/unbound/unbound.conf
forward-addr pointing at knot server
listening on 5353

drill jail.home.lan @192.168.1.23
