Countdown
=========

What is it?
-----------

*Countdown* is a little demo application I built to get to grips with the new MacRuby version (v0.5 at the time of writing).  

It is a port of an idea I realized with Apple Script Studio and Xcode 2.x. 

Features
--------

Basically Countdown, as the name implies, lets you specify a time to count down from and a type of action to be executed when the timer hits 0.
You can chose between the following action types:

1. Shut Down
2. Restart
3. Sleep
4. Log Out
5. Display Dialog
6. Display Dialog + Beep
7. Execute Shell Script

You need to specify an action text for items 5 through 7 in the app preferences.
The preferences also let you configure the update interval, verbose logging, and the time unit (seconds or minutes).

The shell script option is completely unchecked or unescaped, so please be careful (read: use it at your own risk!).

MacRuby Limitations
-------------------

MacRuby is a very impressive and fluent way to code full blown Cocoa applications completely in Ruby.

Classes between Foundation / AppKit and the Ruby standard library are what Apple calls toll-free bridged (meaning you can exchange one class for the other and use methods of both classes on their counterpart).

While developing with MacRuby, I seem to have hit some minor limitations:

* I couldn't get KVO to work. I registered an observer, implemented the recieving method in the observer and made sure I was using accessor methods in the sender when setting the dependant keys.   
It appears to me that Ruby @ivars are not reachable by keyPath notation though I may have overlooked something.

* Variadic methods like [NSString stringWithFormat...] do not work and Objective-C based format strings do not work with Ruby strings.  
  Most of the time you get SEGFAULTs for the latter case.

* MacRuby v0.5 (at the time of writing) is only available for 10.6 and up. Leopard users will have to compile the framework themselves which also includes the quite hefty compilation of LLVM.  
This is quite a drawback since it limits your ability to just share your app with a Leopard user, as you will need to tell them they will have to compile the framework for their operating system.

Other than that I was very impressed overall by the amount of integrity and completeness MacRuby provides in terms of coverage of the Cocoa framework. 

For more info check out [MacRuby.org](http://macruby.org/ "MacRuby Website").