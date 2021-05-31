# 拓展原生的hidl接口 
Android的hardware/interfaces下面有很多原生的定义接口，一般来说，我们需要修改它的接口，可以直接在里面增加或者修改，但是为了不影响原生的接口，我们其实可以在另外的地方，继承原生接口来做修改。 
以hardware/interfaces/broadcastradio为例，我们做一个扩展： 
在vender/FCE/interfaces/automotive/下增加一个radio/1.0/的目录，并增加一个ITuner.hal文件，我们试试扩展ITuner的接口： 
package vendor.fce.automotive.radio@1.0; 

import android.hardware.broadcastradio@1.1; 

 
/** 
 * Interacts with radio new api 
 */ 
interface ITuner extends android.hardware.broadcastradio@1.1::ITuner { 
 
  setRDSData(int32_t param1, int32_t param2); 
 
}; 


然后生成bp文件： 
hidl-gen -L androidbp -r android.hardware:hardware/interfaces -r android.hidl:system/libhidl/transport -rvendor.fce:vendor/FCE/interfaces vendor.fce.automotive.radio@1.0 
这里会生成接口的so库。 

在原先的实现代码里，我们是#include <android/hardware/broadcastradio/1.1/ITuner.h>  
改成#include <vendor/fce/automotive/radio/1.0/ITuner.h>  

直接使用vendor的ITuner就可以使用扩展的接口了。 

在编译的时候，会有错误，这个需要在外层的bp文件加上： 
hidl_package_root { 
    name: "vendor.fce", 
    path: "vendor/FCE/interfaces", 
} 

