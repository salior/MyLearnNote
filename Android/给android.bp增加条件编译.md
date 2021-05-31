# 给给android.bp增加条件编译
这个研究起源于一个需求，要在Android.bp里根据项目加入宏定义 
```
/// add start
bootstrap_go_package {
    // name and pkgPath need to  according to your module
    name: "soong-libdsp",
    pkgPath: "android/soong/libdsp",
    deps: [
        "blueprint",
        "blueprint-pathtools",
        "soong",
        "soong-android",
        "soong-cc",
        "soong-genrule",
    ],
    srcs: [
          // include new add .go file
          "target.go",
    ],
    pluginFor: ["soong_build"],
}

// libdspdefault is a module
targetdefault {
    name: "targetdef",
}
/// add end

cc_library_static {
    name: "libSiDspStatic",
    vendor: true,
	defaults: ["targetdef"],
	。。。。 
```

这里需要加一个go文件，用于编译逻辑的实现，这里主要实现了给cpp代码增加编译的宏定义：
```
package libdsp

import (
        "android/soong/android"
        "android/soong/cc"
		"strings"
        "fmt"
)

func init() {
    // for DEBUG
    fmt.Println("init start")
    android.RegisterModuleType("targetdefault", targetDefaultsFactory)
}

func targetDefaultsFactory() (android.Module) {
    module := cc.DefaultsFactory()
    android.AddLoadHook(module, targetDefaults)
    return module
}

func targetDefaults(ctx android.LoadHookContext) {
    type props struct {
        Cflags []string
    }
    p := &props{}
    p.Cflags = globalDefaults(ctx)
    ctx.AppendProperties(p)
}

func globalDefaults(ctx android.BaseContext) ([]string) {
    var cppflags []string
	var targetStr string
		
	targetStr = ctx.AConfig().Getenv("TARGET_PRODUCT")
	
	fmt.Println("target board TARGET_PRODUCT = ",targetStr)
	
	if strings.Contains(targetStr,"mek_8q"){
		fmt.Println("target is imx8")
        cppflags = append(cppflags,
                "-DTARGET_IMX8X")
    } else if strings.Contains(targetStr,"t7"){
		fmt.Println("target is t7")
        cppflags = append(cppflags,
                "-DTARGET_T7")
		if strings.Contains(targetStr,"t7_v302"){
			fmt.Println("target is t7_v302")
			cppflags = append(cppflags,
					"-DTARGET_T7_V302")		
		}
    } else {
		fmt.Println("target is j6")
        cppflags = append(cppflags,
                "-DTARGET_J6")
    }

    return cppflags
}
```
还可以实现根据不同项目，配置不同的编译文件，以下是另一个go例子：
```
package libMcuService
import (
        "android/soong/android"
        "android/soong/cc"
		"strings"
        "fmt"
)

func init() {
    fmt.Println("default mcu service init")
    android.RegisterModuleType("notifyMcuRest", notifyMcuRestBinaryFactory)
}

func notifyMcuRestBinaryFactory() (android.Module) {
    module := cc.DefaultsFactory()
    android.AddLoadHook(module, mcuServiceBinary)
    return module
}

func mcuServiceBinary(ctx android.LoadHookContext) {
	type props struct{
		Srcs []string
		Shared_libs []string
		Static_libs []string
		Include_dirs []string
    }
    p := &props{}

    targetStr := ctx.AConfig().Getenv("TARGET_PRODUCT")
    if strings.Contains(targetStr, "full_spm8666p1_64") {
	p.Srcs = append(p.Srcs, "testMcuCom.cpp")
	p.Shared_libs = append(p.Shared_libs, "libcutils")
	p.Shared_libs = append(p.Shared_libs, "libbinder")
	p.Shared_libs = append(p.Shared_libs, "libutils")
	p.Static_libs = append(p.Static_libs, "libMcuServiceStatic")
    } else {
	p.Srcs = append(p.Srcs, "notifyMcuRest.cpp")
	p.Include_dirs = append(p.Include_dirs, "vendor/FCE/vehicle/")
	p.Shared_libs = append(p.Shared_libs, "libMcuService")
//	fmt.Println("Error: Where is default mcuService.")
    }
    fmt.Println("libMcuService Srcs:", p.Srcs)
    fmt.Println("libMcuService Include_dirs:", p.Include_dirs)
    ctx.AppendProperties(p)
}
```

