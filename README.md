GC3DFlipTransitionStyleSegue
============================

iBooks-style 3D flip transition animation rendered in OpenGL ES 2.0 and wrapped in a UIStoryboardSegue subclass.

Comparison between iBooks and this segue class:

![image](https://dl.dropbox.com/u/10505256/Comparison.png)

Features / Design
-----------------
- Uses OpenGL ES rendering instead of Core Animation for high performance and shader effects.
- Uses GLKit to drastically reduce the amount of OpenGL ES 2.0 code (to write and maintain).
- Inspired by Apple's 3D flip view controller transition animation, as found in iOS apps like iBooks, iTunes U and Podcasts.
- Supports different screen sizes and screen orientations.

Requirements
------------
GC3DFlipTransitionStyleSegue requires iOS 5.0 and above.

Installation
------------
Add the source code to your project (and image file if you want to use it). Link your target against QuartzCore.framework, GLKit.framework and OpenGLES.framework.

CocoaPods support is coming soon.

If you use this class in a non-ARC project, make sure you add the -fobjc-arc compiler flag for the implementation file.

Quick setup: Just set this class as a custom segue and it'll work right away.

![image](https://dl.dropbox.com/u/10505256/SetCustomSegue.png)

Customization
-------------
![image](https://dl.dropbox.com/u/10505256/CustomizationEffects.png)

Todo
----
- Add option to flip view controllers in opposite direction like Apple's Podcasts app.
- Improve snapshot performance on the iPad.

License
-------

This code is distributed under the terms and conditions of the **zlib license**.

Copyright (c) 2013 Glenn Chiu

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

3. This notice may not be removed or altered from any source
   distribution.
