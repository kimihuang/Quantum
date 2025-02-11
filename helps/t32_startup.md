#T32: Finally creating example config files...

################################################################################
#T32: Installation of TRACE32 finished.
#
#     To start TRACE32 you will find 4 example configuration files in the
#     installation directory:
#     - config.t32          explaining general config-file syntax.
#     - config_usb.t32      example to start USB-Debugger configurations
#     - config_eth.t32      example to start Ethernet-Debugger configurations
#                           (adapt the debugger IP-address inside!)
#     - config_hostmci.t32  example to start HostMCI configurations
#     - config_sim.t32      example to start Simulator configurations
################################################################################

Example 1: Start TRACE32 with an attached USB-Debugger for ARM 64bit targets:
 "/Users/lianghuang/t32/bin/macosx64/t32marm-qt" -c "/Users/lianghuang/t32/config_usb.t32"
Example 2: Start TRACE32 as PowerPC simulator:
 "/Users/lianghuang/t32/bin/macosx64/t32mppc-qt" -c "/Users/lianghuang/t32/config_sim.t32"