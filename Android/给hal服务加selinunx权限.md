
给一个自定义的hal加入自启动

这个主要是涉及加selinux权限的问题。这里将mqtt hal服务添加的过程记录一下。

首先需要在 system/sepolicy/private/hwservice_contexts 里加上:
vendor.parrot.hardware.mqtt::IMqttService                   	u:object_r:hal_mqtt_hwservice:s0

在 system/sepolicy/public/attributes 里加上:
hal_attribute(mqtt); 	//这个其实是定义了hal_mqtt_server,hal_mqtt_client,hal_mqtt

在 system/sepolicy/public/hwservice.te 里加:
type hal_mqtt_hwservice, hwservice_manager_type;  //这个是将上面的hal_mqtt_hwservice定义为hwservice_manager_type

以上3项，在 system/sepolicy/prebuilts/api/28.0 必须做相应的修改，不然会报differ错误。并且在
system/sepolicy/prebuilts/api/28.0/private/compat/26.0/26.0.ignore.cil
system/sepolicy/prebuilts/api/28.0/private/compat/27.0/27.0.ignore.cil
system/sepolicy/private/compat/26.0/26.0.ignore.cil
system/sepolicy/private/compat/27.0/27.0.ignore.cil
里，加上hal_mqtt_hwservice，忽略它。

在 system/sepolicy/vendor/file_contexts 里面加:
/(vendor|system/vendor)/bin/hw/vendor\.parrot\.hardware\.mqtt@1\.0-service  u:object_r:hal_mqtt_default_exec:s0、

以上修改好像不能放在system以外的文件夹，可能是编译顺序的问题，没有再研究

再加mqtt本身的te文件:
hal_mqtt.te
# HwBinder IPC from client to server, and callbacks
binder_call(hal_mqtt_client, hal_mqtt_server)
binder_call(hal_mqtt_server, hal_mqtt_client)

add_hwservice(hal_mqtt_server, hal_mqtt_hwservice)

allow hal_mqtt_client hal_mqtt_hwservice:hwservice_manager find;

hal_mqtt_default.te
# mqtt subsystem
type hal_mqtt_default, domain;
hal_server_domain(hal_mqtt_default, hal_mqtt)

# may be started by init
type hal_mqtt_default_exec, exec_type, vendor_file_type, file_type;
init_daemon_domain(hal_mqtt_default)
