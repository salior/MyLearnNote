# 一个简单的HIDL完整例子

创建文件夹：
mkdir -p hardware/interfaces/naruto/1.0/default 

接着创建接口描述文件INaruto.hal，放在刚才创建的目录中(hardware/interfaces/naruto/1.0/)
package android.hardware.naruto@1.0;

interface INaruto {
    helloWorld(string name) generates (string result);
};

如果有自己定义的type，可以将types.hal文件放到同样的地方。

生成HAL 相关文件：
PACKAGE=android.hardware.naruto@1.0
LOC=hardware/interfaces/naruto/1.0/default/
//生成工具
# make hidl-gen -j64

//在default目录下生成Naruto.cpp,Naruto.h，这个是实现
//INaruto和types生成的头文件在 --- 这是一个空的实现，具体的功能需要完善
# hidl-gen -o $LOC -Lc++-impl -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport $PACKAGE
//在default目录下生成Android.bp --- 这个是指实现的bp
# hidl-gen -o $LOC -Landroidbp-impl -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport $PACKAGE

然后使用脚本来更新Makefile，自动生成Android,mk, Android.bp(naruto/,naruto/1.0下)  --- 这个是hidl的接口bp 用hidl-gen -o $LOC -Landroidbp也可以生成

# ./hardware/interfaces/update-makefiles.sh

打开Naruto.cpp，实现函数：
// Methods from INaruto follow.
Return<void> Naruto::helloWorld(const hidl_string& name, helloWorld_cb _hidl_cb) {
    // TODO implement
    char buf[100];
    ::memset(buf, 0x00, 100);
    ::snprintf(buf, 100, "Hello World, %s", name.c_str());
    hidl_string result(buf);

    _hidl_cb(result);
    return Void();
}


然后可以查看一下Android.bp文件看一下编译生成个啥
cc_library_shared {
    name: "android.hardware.naruto@1.0-impl",
    relative_install_path: "hw",
    proprietary: true,
    srcs: [
        "Naruto.cpp",
    ],
    shared_libs: [
        "libhidlbase",
        "libhidltransport",
        "libutils",
        "android.hardware.naruto@1.0",
    ],
}

在default/目录下执行mm，或者mmm
最终会生成一个android.hardware.naruto@1.0-impl.so, 生成在/vendor/lib/hw/下
它是依赖android.hardware.naruto@1.0的，/system/lib/android.hardware.naruto@1.0.so
在out\soong\.intermediates\hardware\interfaces\naruto\1.0目录下，还会有对应的types.h和INaruto.h等头文件

然后创建服务程序default/service.cpp:
#include "Naruto.h"
using android::hardware::naruto::V1_0::INaruto;
using android::hardware::defaultPassthroughServiceImplementation;

using namespace android;
using namespace android::hardware;

using android::hardware::naruto::V1_0::implementation::Naruto;

int main() {
    auto service = new Naruto();

    configureRpcThreadpool(4, true /* callerWillJoin */);

    ALOGI("Registering as service...");
    status_t status = service->registerAsService();

    if (status != OK) {
        ALOGE("Unable to register vehicle service (%d)", status);
        return 1;
    }

    ALOGI("Ready");
    joinRpcThreadpool();

    return 1;
}

在default/android.bp里加上：
cc_binary {
    name: "android.hardware.naruto@1.0-service",
    defaults: ["hidl_defaults"],
    proprietary: true,
    relative_install_path: "hw",
    srcs: ["service.cpp"],
    init_rc: ["android.hardware.naruto@1.0-service.rc"],
    shared_libs: [
        "libhidlbase",
        "libhidltransport",
        "libutils",
        "liblog",
        "android.hardware.naruto@1.0",
        "android.hardware.naruto@1.0-impl",
    ],
}

则可以编译出android.hardware.naruto@1.0-service执行文件。

再创建客户端进程default/client.cpp
# include <android/hardware/naruto/1.0/INaruto.h>

# include <hidl/Status.h>

# include <hidl/LegacySupport.h>

# include <utils/misc.h>

# include <hidl/HidlSupport.h>

# include <stdio.h>

using android::hardware::naruto::V1_0::INaruto;
using android::sp;
using android::hardware::hidl_string;

int main()
{
    int ret;

    android::sp<INaruto> service = INaruto::getService();
    if(service == nullptr) {
        printf("Failed to get service\n");
        return -1;
    }

    service->helloWorld("JayZhang", [&](hidl_string result) {
                printf("%s\n", result.c_str());
        });

    return 0;
}

在default/里加Android.mk:
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE := naruto_test
LOCAL_SRC_FILES := \
    client.cpp \

LOCAL_SHARED_LIBRARIES := \
   liblog \
   libhidlbase \
   libutils \
   android.hardware.naruto@1.0 \

include $(BUILD_EXECUTABLE)

则可以编译出naruto_test执行文件。

记得在manifest文件里添加vendor接口的定义，不然在client端是没法拿到service的，在相应的manifest.xml里面加入：
<hal format="hidl">
    <name>android.hardware.naruto</name>
    <transport>hwbinder</transport>
    <version>1.0</version>
    <interface>
        <name>INaruto</name>
        <instance>default</instance>
    </interface>
</hal>

然后我们来测试一下代码吧：

手动运行service，再运行naruto_test，我们的测试代码传入"JayZhang"字符串，结果输出"Hello World, JayZhang", 符合我们的预期结果。


生成Java库命令
authbash hidl-gen -o ./tmp/Java/ -Ljava   -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport android.hardware.screen@1.0
authbash hidl-gen -o ./tmp/ -Ljava   -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport android.hardware.automotive.audiocontrol@1.0

authbash hidl-gen -o ./tmp/ -Ljava   -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport -rvendor.fce:vendor/FCE/interfaces vendor.fce.automotive.audiocontrol@1.0

cmd: "$(location hidl-gen) -o $(genDir) -Lc++-headers -randroid.hardware:hardware/interfaces -randroid.hidl:system/libhidl/transport -rvendor.fce:vendor/FCE/interfaces vendor.fce.automotive.audiocontrol@1.0",
