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
    
## LearnOpenGLCN学习笔记
1、openGL就是一个巨大的状态机。  
2、建议将这三个单词先记下来：  
顶点数组对象：Vertex Array Object，VAO  
顶点缓冲对象：Vertex Buffer Object，VBO  
索引缓冲对象：Element Buffer Object，EBO或Index Buffer Object，IBO  
3、着色器(Shader)。OpenGL着色器是用OpenGL着色器语言(OpenGL Shading Language, GLSL)写成。在现代OpenGL中，我们必须定义至少一个顶点着色器和一个片段着色器（因为GPU中没有默认的顶点/片段着色器）。从基本意义上来说，着色器只是一种把输入转化为输出的程序。着色器也是一种非常独立的程序，因为它们之间不能相互通信；它们之间唯一的沟通只有通过输入和输出。  
着色器其实可以这么理解，它是一个函数，输入一个，然后它对opengl内部的对应状态器进行输出：  
	   char vShaderStr[] =  
				"attribute vec4 vPosition;\n"  
				"void main() {\n"  
				"  gl_Position = vPosition;\n"  
				"}\n";  
比如上面这个，输入一个position，然后不经任何变化就送到gl_Position，是一个最最简单的顶点着色器。  

4、请记住，矩阵乘法是反向应用的。  
5、一些OpenGL开发使用到的库或者概念：  
OpenGL:OpenGL（英语：Open Graphics Library，译名：开放图形库或者“开放式图形库”）是用于渲染2D、3D矢量图形的跨语言、跨平台的应用程序编程接口（API）。这个接口由近350个不同的函数调用组成，用来从简单的图形比特绘制复杂的三维景象。  

OpenGL ES:OpenGL ES（OpenGL for Embedded Systems）是三维图形应用程序接口OpenGL的子集，针对手机、PDA和游戏主机等嵌入式设备而设计。  
OpenGL ES是从OpenGL裁剪定制而来的，去除了glBegin/glEnd，四边形（GL_QUADS）、多边形（GL_POLYGONS）等复杂图元等许多非绝对必要的特性。经过多年发展，现在主要有两个版本，OpenGL ES 1.x针对固定管线硬件的，OpenGL ES 2.x针对可编程管线硬件。OpenGL ES 1.0是以OpenGL 1.3规范为基础的，OpenGL ES 1.1是以OpenGL 1.5规范为基础的，它们分别又支持common和common lite两种profile。lite profile只支持定点实数，而common profile既支持定点数又支持浮点数。OpenGL ES 2.0则是参照OpenGL 2.0规范定义的，common profile发布于2005-8，引入了对可编程管线的支持。OpenGL ES 3.0于2012年公布，加入了大量新特性。  

OpenGL ES模拟器：总的来说，OpenGL ES的api与OpenGL有差异，Android上使用的是OpenGL ES，为了在PC上调试Android上的openGL代码，可以使用OpenGL ES模拟器。如果只是为了学习OpenGL，可以直接用GLFW，比较方便。  

GLFW:GLFW is an Open Source, multi-platform library for OpenGL, OpenGL ES and Vulkan development on the desktop. It provides a simple API for creating windows, contexts and surfaces, receiving input and events.实际上这个就是为了使用OpenGL方便，对系统窗口的一个包装（window和Linux）。  

extension:某个版本的OpenGL可以看它扩展的库有什么，这些库表示它支持什么功能。

glm：GLM是OpenGL Mathematics的缩写，它是一个只有头文件的库，也就是说我们只需包含对应的头文件就行了，不用链接和编译。GLM可以在它们的网站上下载。把头文件的根目录复制到你的includes文件夹，然后你就可以使用这个库了。
