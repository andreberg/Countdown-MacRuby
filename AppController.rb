# AppController.rb
# Countdown
#
# Created by Andre Berg on 28.02.10.
# Copyright 2010 Berg Media. All rights reserved.

require 'PreferenceController'

LogOutputVerboseKeyPath = 'logOutputVerbose'

$defaults = NSUserDefaults.standardUserDefaults
$center = NSNotificationCenter.defaultCenter
$prefs = PreferenceController.sharedPreferenceController

class AppController < NSObject
   
   attr_accessor :mainWindow, :startButton, :timeTextField, :timeStepper, :progressIndicator
   attr_reader :isCounting
   
   UPDATE_INTERVAL = 1.0
   
   def awakeFromNib
      @is_counting = false
      @stop_time = nil
      @time_text_field_value = nil
      @timer = nil
      @timer_count = nil
      @action = nil
      
      @textFieldEditor = nil
      @repeatingTimer = nil
   end
   
   def startStopCountdown(sender)
      sb = startButton
      if sb.title == "Start" then
         self.startCountdown
         sb.setTitle "Stop"
         timeTextField.setEnabled false
      else
         self.stopCountdown
         sb.setTitle "Start"
         timeTextField.setEnabled true
      end
   end
   
   def startCountdown
      puts "starting countdown at #{Time.new}"
      @is_counting = true
      @timer_count = 0
      @time_text_field_value = Float(timeTextField.stringValue)
      @stop_time = NSDate.dateWithTimeIntervalSinceNow(@time_text_field_value)
          
      @timer = NSTimer.alloc.initWithFireDate(NSDate.date, 
                                                 interval:UPDATE_INTERVAL, 
                                                   target:self, 
                                                 selector:'updateCountdownAndCheckStopCondition:' , 
                                                 userInfo:nil, 
                                                  repeats:true)
                                                
      NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSDefaultRunLoopMode)
      progressIndicator.setDoubleValue 100.0
      #@action.performSelector :run, withObject:nil, afterDelay:@stop_time
   end
   
   def updateCountdownAndCheckStopCondition(timer)
      cmp = @stop_time.compare NSDate.date
      if cmp < 0
         progressIndicator.setDoubleValue 0.0
         @timer.invalidate
         @action.run
      else
         pvalue = 100 - ((Float(@timer_count)/Float(@time_text_field_value)) * 100.0)
         puts "%02.02f" % pvalue
         @timer_count += UPDATE_INTERVAL
         progressIndicator.setDoubleValue(pvalue)
      end
   end
   
   def stopCountdown
      @timer.invalidate
      # NSObject.cancelPreviousPerformRequestsWithTarget @action
      puts "stopping countdown at #{Time.new}"
      @is_counting = false
   end
   
   # MARK: NSApplication Delegate
   
   def applicationShouldTerminateAfterLastWindowClosed(theApp)
      true
   end
   
   # because we can't rely on the nib loading mechanism to load top-level objects
   # in the order we need them, as a little workaround I created ivars on the top-level
   # objects that had their outlet connections turn nil so I could then set them from
   # here when the app has really finished loading up completely.
   def applicationDidFinishLaunching(notification)
      defaults = NSUserDefaults.standardUserDefaults
      PreferenceController.setupDefaults
      @action = Action.new(self, defaults.stringForKey(ActionTypeKey), defaults.stringForKey(ActionTextKey))
      progressIndicator.setDisplayedWhenStopped false
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