# ADB常用命令
```
1、通过adb 启动某个activity。如：在AndroidManifest.xml中查找到包名（假设为com.android.sales）,然后再找到要打开的activity(假设为SalesActivity), 运行adb shell am start -n com.android.sales/com.android.sales.SalesActivity即可。

2、有的时候install之后，会提示WARNING: linker: libmp4enc_sa.ca7.so has text relocations. This is wasting memory and is a security risk. Please fix. 这样可以
adb push /local/rio5_new/out/target/product/rio_5/system/lib/libmp4enc_sa.ca7.so system/lib,将最新编出来的库导入到system/lib下面。

3、列出安装的packages，adb shell pm list packages
adb shell am broadcast -a com.coagnet.ScreenLockDefine --es ACTION_TYPE "ANIM_FINISH"
4、adb发送BOOT_COMPLETED(Intent)
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED --es test_string "test string" --ei test_int 100 -ez test_boolean true
命令发送BOOT_COMPLETED广播，而不用重启测试机或模拟器来测试BOOT_COMPLETED广播，这条命令可以更精确的发送到某个package，如下：
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -c android.intent.category.HOME -n package_name/class_name

5、ps列出系统的进程，ps | grep xxx 找相关的进程

6、ps出来的进程，可以看到PID，kill PID号可以干掉该进程。

7、Usage: top
 [-m max_procs] [-n iterations] [-d delay] [-s sort_column] [-t] [-h] 

-m num  // 最多显示多少个进程 
-n num  // 刷新次数 
-d num  // 刷新间隔时间（默认5秒）
-s col  Column // 按哪列排序 
-t      // 显示线程信息而不是进程 

9、dumpsys 
   dumpsys activity activities 看activity的栈
   dumpsys meminfo com.coagent.hudsettings 看包的内存占用分配等状况
   dumpsys package 看各个包的内部结构，包含什么activity或者service之类的。
   dumpsys activity 
   dumpsys cpuinfo
   ...

10、adb shell procrank
  可以看内存占用情况
  PID Vss Rss Pss Uss cmdline

11、adb wait-for-device && adb shell logcat -b main > main.txt

12、安装apk
安装APK(如果加 -r 参数，保留已设定数据，重新安装filename.apk)
adb install xxx.apk
adb install -r xxx.apk
adb push AppName.apk /system/app/.

13、进各种模式
高通进入紧急下载模式
adb reboot edl
进入fastboot
adb reboot bootloader
进入recovery
adb reboot recovery

14、输入文本
input text abcde

15、查看设备占用
lsof /dev/pcmC0D0c

16、adb shell执行多个命令
adb shell "cd /data/local/tmp; ./dm --src gm --config gl"

17、在shell环境remount
mount -o remount,rw /

18、adb连接后，和pc端联调网络
adb forward tcp:8999 tcp:8999  //pc做客户端，车机做服务端
adb forward --remove-all 
adb reverse tcp:8999 tcp:8999  //车机做客户端，pc做服务端
adb reverse --remove-all
