启动顺序:
触发器的执行顺序为on early-init -> init -> late-init，从上面的代码可知，在late-init触发器中会触发文件系统挂载以及on boot。
在on boot过程会触发启动core class。
至于main class的启动是由vold.decrypt的以下4个值的设置所决定的， 该过程位于system/vold/cryptfs.c文件。

之后顺序post-fs, load_system_props_action,post-fs-data ,load_persist_props_action,firmware_mounts_complete,boot

on nonencrypted
    class_start main
    class_start late_start

on property:vold.decrypt=trigger_restart_min_framework
    class_start main

on property:vold.decrypt=trigger_restart_framework
    class_start main
    class_start late_start

on property:vold.decrypt=trigger_reset_main
    class_reset main

on property:vold.decrypt=trigger_shutdown_framework
    class_reset late_start
    class_reset main
