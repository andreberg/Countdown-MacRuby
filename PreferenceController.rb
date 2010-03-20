# PreferenceController.rb
# Countdown
#
# Created by Andre Berg on 04.03.10.
# Copyright 2010 Berg Media. All rights reserved.

LogOutputVerboseChangedNotification = 'LogOutputVerboseChangedNotification'
TimeUnitChangedNotification = 'TimeUnitChangedNotification'
ActionTypeChangedNotification = 'ActionTypeChangedNotification'
ActionTextChangedNotification = 'ActionTextChangedNotification'

ActionTypeKey = 'ActionType'
ActionTextKey = 'ActionText'
TimeUnitKey = 'TimeUnit'
TimeValueKey = 'TimeValue'
LogOutputVerboseKey = 'LogOutputVerbose'
UpdateIntervalKey = 'UpdateInterval'

class PreferenceController < NSWindowController
   
   attr_accessor :appController
   attr_reader :logOutputVerbose
   
   def init
      initWithWindowNibName('Preferences')
      
      self.setupDefaults

      defaults = NSUserDefaults.standardUserDefaults
      
      @actionType = defaults.stringForKey(ActionTypeKey)
      @actionText = defaults.stringForKey(ActionTextKey)
      @timeUnit = defaults.stringForKey(TimeUnitKey)
      @timeValue = defaults.doubleForKey(TimeValueKey)
      @logOutputVerbose = defaults.boolForKey(LogOutputVerboseKey)
      @updateInterval = defaults.stringForKey(UpdateIntervalKey)

      self
   end

   def logOutputVerboseClicked(sender)
      if sender.state == 0
         @logOutputVerbose = false
      else
         @logOutputVerbose = true
      end
      info = { "newValue" => @logOutputVerbose }
      $center.postNotificationName LogOutputVerboseChangedNotification, object:$prefs, userInfo:info
   end

   def self.sharedPreferenceController
      @instance ||= alloc.init
   end
   
   def setupDefaults
      defaultsPlist = NSBundle.mainBundle.pathForResource "Defaults", ofType:"plist"
      defaultsDict = NSDictionary.dictionaryWithContentsOfFile defaultsPlist
      $defaults.registerDefaults defaultsDict
      NSUserDefaultsController.sharedUserDefaultsController.setInitialValues defaultsDict
   end
   
   def showWindow(sender)
      if window == nil
         NSBundle.loadNibNamed("Preferences", owner:self)
      end
      NSApp.beginSheet(window, modalForWindow:NSApp.mainWindow, modalDelegate:self, didEndSelector:'didEndSheet:', contextInfo:nil)
   end
   
   def savePrefsAndCloseWindow(sender)
      NSUserDefaultsController.sharedUserDefaultsController.save(nil)
      NSUserDefaults.standardUserDefaults.synchronize()
      NSApp.endSheet window
   end
   
   def closeWindow(sender)
      NSApp.endSheet window
   end
   
   def didEndSheet(sheet)
      sheet.orderOut self
   end
end

$prefs = PreferenceController.sharedPreferenceController