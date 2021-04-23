## 创建一个surface并显示：
1、创建surfaceComposerClient，用它创建createSurface  
2、SurfaceComposerClient::Transaction{} setLayer show ，这时候是看不到任何东西的，因为这个surface没有画东西，所以看不到。  
adb shell dumpsys SurfaceFlinger  
可以看到有创建窗口，这里的窗口名字是NativeBinApp  
+ Layer 0x7b3ba66000 (NativeBinApp#0)  
  Region transparentRegion (this=0x7b3ba66380, count=1)  
    [  0,   0,   0,   0]  
  Region visibleRegion (this=0x7b3ba66010, count=1)  
  

  
## openGL记录，有用的网页资料
1、链接 https://juejin.cn/post/6844903858380996616，这个作者的opengl为系列文章，可以跟学 
作者：程序员kenney
2、https://learnopengl-cn.github.io/  opengl 3的中文书  

## //参照\frameworks\native\opengl\tests\gl2_basic的程序记录一下基本顺序
1、在一个没有EGL环境的线程中调用了OpenGL ES API会失败，必须让一个线程拥有EGL环境，步骤以下几点：  
(1)初始化显示设备  
	dpy = eglGetDisplay(EGL_DEFAULT_DISPLAY);  
	returnValue = eglInitialize(dpy, &majorVersion, &minorVersion);  

(2)选择config  
    EGLint s_configAttribs[] = {  
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,  
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,  
            EGL_NONE };  
	EGLConfig myConfig = {0};  
	//从SurfaceComposerClient获取一个Surface  

    EGLNativeWindowType window = windowSurface.getSurface();  
    returnValue = EGLUtils::selectConfigForNativeWindow(dpy, s_configAttribs, window, &myConfig);  

(3)创建EGL Context  
	EGLint context_attribs[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };  
	context = eglCreateContext(dpy, myConfig, EGL_NO_CONTEXT, context_attribs);  

(4)创建EGL Surface  
    EGLint winAttribs[] = {EGL_GL_COLORSPACE_KHR, EGL_GL_COLORSPACE_SRGB_KHR, EGL_NONE};  
    surface = eglCreateWindowSurface(dpy, myConfig, window, winAttribs);  
	
	还有个对应的eglCreatePbSurface函数，这个是创建在pb上，离屏的时候用。

(5)绑定EGL  
	returnValue = eglMakeCurrent(dpy, surface, surface, context);  

(6)一个使用例子  
Thread {  

    val egl = EGL()  
    egl.init()	//上述的初始化  
    egl.draw()  
	egl.swap()  
    egl.release()  

}.start()  

(7) GLSurfaceView 其实和上面例子查不多，做完初始化就Renderer回调给用户画东西。  

## window上实践：
https://blog.csdn.net/u010312436/article/details/82984322

## Android里面的一些基本demo
\frameworks\native\opengl\tests\angeles  
\frameworks\native\opengl\tests\gl2_basic  
这里面还有很多例子，需要直接去那里看就行。  

## //glDrawTexiOES
首先，这个函数的作用是将指定的纹理贴到视图中的一个矩形区域，无须坐标变换，渲染速度加快。  
使用的步骤大概如下：  
      glGenTextures(...)  
      glBindTexture(...)  
      ...  
      glTexImage2D(...)  
      GLint crop[4] = { 0, h, w, -h };  
      ...  
     glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_CROP_RECT_OES, crop);  
      ...
     glDrawTexiOES(...)  
     从上面可以看到，使用时主要是需要设置GL_TEXTURE_CROP_RECT_OES参数。  
    当然，还有其他渲染纹理的方法，那么何时该使用这种方式呢？  从该函数的应用范围可知，它一般适用于所贴纹理的区域是矩形区域，且不需要作坐标变换的情形。  