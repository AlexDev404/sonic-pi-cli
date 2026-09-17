sonic-pi-cli
====

A simple command line interface for Sonic Pi, written in Ruby.

**Requires Sonic Pi v2.7 or higher**.

Current code supports both the older fixed-port releases and newer Sonic Pi releases which expose dynamic ports and an auth token via `.sonic-pi/log/gui.log`.

Installation
-------

    gem install sonic-pi-cli

Usage
-----

Sonic Pi must be running, as this is just a client.

The client reads Sonic Pi connection details from the standard `.sonic-pi` directory in your home folder. You can override that location with `SONIC_PI_HOME`.

    sonic_pi play 50
    sonic_pi sample :loop_breakbeat, rate: 0.5
    sonic_pi stop

or

    echo 'sample :loop_amen' | sonic_pi
    cat music.rb | sonic_pi

or

    $ irb

    irb(main):001:0> require 'sonic_pi'
    => true
    irb(main):002:0> SonicPi.new.run('play [50, 55, 60]')
    => 36

License
------

sonic-pi-cli is released under the MIT license. See LICENSE file for more details.

Alternatives
------
[lpil/sonic-pi-tool](https://github.com/lpil/sonic-pi-tool) - written in Rust, also supports viewing logs.


Thanks to Sam Aaron for creating Sonic Pi. Official command line support is planned for Sonic Pi 3.0.

For those interested, the code weighs in at around 120 lines and is stupid simple. Take a look.
