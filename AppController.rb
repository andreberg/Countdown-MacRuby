# AppController.rb
# Countdown
#
# Created by Andre Berg on 28.02.10.
# Copyright 2010 Berg Media. All rights reserved.

LogOutputVerboseKeyPath = 'logOutputVerbose'

$defaults = NSUserDefaults.standardUserDefaults
$center = NSNotificationCenter.defaultCenter

class AppController < NSObject
   
   attr_accessor :mainWindow, :startButton, :timeTextField, :timeStepper, :progressIndicator
   
   def awakeFromNib
      # Objects
      @timeStepper = timeStepper
      @timeTextField = timeTextField
      @textFieldEditor = nil
      @timer = nil
      
      $DEBUG = $prefs.logOutputVerbose
      
      $center.addObserver(self, selector:'logOutputVerboseChanged:', name: LogOutputVerboseChangedNotification, object:$prefs)
   end
   
   def init
      super
      @@isCounting = false
      
      @timerCount = 0
      @stopTime = nil
      @updateInterval = 0   # granularity of log and progress indicator updates
      @timeInterval = 0     # granularity of the interval used for the timer math
      @action = ""
      self
   end
   
   def self.sharedAppController
      @instance ||= alloc.init
   end
   
   def self.isCounting?
      @@isCounting
   end
   
   def startStopCountdown(sender)
      @action = Action.new(self, $defaults.stringForKey(ActionTypeKey), $defaults.stringForKey(ActionTextKey))
      
      sb = startButton
      if sb.title == "Start" then
         self.startCountdown
         sb.setTitle "Stop"
         timeTextField.setEnabled false
         timeStepper.setEnabled false
      else
         self.stopCountdown
         sb.setTitle "Start"
         timeTextField.setEnabled true
         timeStepper.setEnabled true
      end
   end
   
   def startCountdown
      puts "starting countdown at #{Time.datemstamp}"
      @@isCounting = true
      
      @timeTextFieldValue = timeTextField.doubleValue
      @timeInterval = @timeTextFieldValue
      @timeUnit = $defaults.stringForKey TimeUnitKey
      
      if @timeUnit == "minutes"
         @timeInterval = @timeInterval * 60.0
      end
      
      puts "using time unit #{@timeUnit}" if $DEBUG
      puts "target interval = %02.02f s" % @timeInterval if $DEBUG
      
      @timerCount = 0
      @stopTime = NSDate.dateWithTimeIntervalSinceNow(@timeInterval)
      
      @updateInterval = Float($defaults.stringForKey('UpdateInterval'))
      @timer = NSTimer.alloc.initWithFireDate(NSDate.date, 
                                                 interval:@updateInterval, 
                                                   target:self, 
                                                 selector:'updateCountdownAndCheckStopCondition:' , 
                                                 userInfo:nil, 
                                                  repeats:true)
                                                
      NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSDefaultRunLoopMode)
      progressIndicator.setDoubleValue 100.0
   end
   
   def updateCountdownAndCheckStopCondition(timer)
      cmp = @stopTime.compare NSDate.date
      if cmp < 0
         progressIndicator.setDoubleValue 0.0
         timeTextField.setDoubleValue @timeTextFieldValue
         @timer.invalidate
         @action.run
      else
         pvalue = 100 - ((Float(@timerCount)/Float(@timeInterval)) * 100.0)
         pvaluestr = "%02.02f" % pvalue
         puts "%s %%" % pvaluestr if $DEBUG
         @timerCount += @updateInterval
         progressIndicator.setDoubleValue pvalue
         timeTextField.setDoubleValue pvaluestr
      end
   end
   
   def stopCountdown
      @timer.invalidate
      timeTextField.setDoubleValue @timeTextFieldValue
      puts "stopping countdown at #{Time.datemstamp}"
      @@isCounting = false
   end
   
   # MARK: KVO
   
   # couldn't get KVO to work
#    def observeValueForKeyPath keyPath, ofObject:theObject, change:theChange, context:theContext
#       p "KVO"
#       if keyPath == LogOutputVerboseKeyPath
#          self.logOutputVerboseChanged(change.valueForKey NSKeyValueChangeNewKey)
#       end
#    end

   # MARK: Notifications
   
   def logOutputVerboseChanged(notification)
      puts "log output verbose changed" if $DEBUG
      newValue = notification.userInfo['newValue']
      if newValue
        puts "setting $DEBUG to true" if $DEBUG
        $DEBUG = true
      else
        $DEBUG = false
        puts "setting $DEBUG to false" if $DEBUG
      end
   end
   
   # MARK: NSApplication Delegate
   
   def applicationShouldTerminateAfterLastWindowClosed(theApp)
      true
   end
   
   def applicationWillTerminate(notification)
      $center.removeObserver self, name: LogOutputVerboseChangedNotification, object:$prefs
   end
   
   # because we can't rely on the nib loading mechanism to load top-level objects
   # in the order we need them, as a little workaround I created ivars on the top-level
   # objects that had their outlet connections turn nil so I could then set them from
   # here when the app has really finished loading up completely and all the connections 
   # should exist and not point to nil.
   def applicationDidFinishLaunching(notification)
      @timeTextField = timeTextField
      @timeStepper = timeStepper
   end
   
   # MARK: NSWindow Delegate
   
   # we need to substitute the default field editor of our time text field for 
   # our custom subclass so that we can handle keyDown events when the user sends
   # control characters like up or down arrow
   def windowWillReturnFieldEditor sender, toObject:client
      if client.isKindOfClass NSTextField
         if @textFieldEditor == nil
            @textFieldEditor = NumberDialingTextFieldEditor.new
            @textFieldEditor.setFieldEditor true
         end
         @textFieldEditor
      end
   end   
end

