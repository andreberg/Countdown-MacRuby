# PreferenceController.rb
# Countdown
#
# Created by Andre Berg on 04.03.10.
# Copyright 2010 Berg Media. All rights reserved.

TimeUnitChangedNotification = 'TimeUnitChangedNotification'
ActionTypeChangedNotification = 'ActionTypeChangedNotification'
ActionTextChangedNotification = 'ActionTextChangedNotification'

ActionTypeKey = 'ActionType'
ActionTextKey = 'ActionText'
TimeUnitKey = 'TimeUnit'
LastTimeValueKey = 'LastTimeValue'


class PreferenceController < NSWindowController

   attr_accessor :actionType, :actionText, :timeUnit, :lastTimeValue

#    Defaults = {
#       ActionTypeKey => 'Dialog + Beep',
#       ActionTextKey => 'Countdown has ended...',
#       TimeUnitKey => 'seconds',
#       LastTimeValueKey => '1.0',
#       LogOutputVerbose => true
#    }
   
   def self.setupDefaults
      defaultsPlist = NSBundle.mainBundle.pathForResource "Defaults", ofType:"plist"
      defaultsDict = NSDictionary.dictionaryWithContentsOfFile defaultsPlist
      p defaultsDict
      NSUserDefaults.standardUserDefaults.registerDefaults defaultsDict
      NSUserDefaultsController.sharedUserDefaultsController.setInitialValues defaultsDict
   end

   def init
      initWithWindowNibName('Preferences')
      defaults = NSUserDefaults.standardUserDefaults
      
      @actionType = defaults.stringForKey(ActionTypeKey)
      @actionText = defaults.stringForKey(ActionTextKey)
      @timeUnit = defaults.stringForKey(TimeUnitKey)
      @timeValue = defaults.stringForKey(LastTimeValueKey)
      
      self
   end

   def self.sharedPreferenceController
      @instance ||= alloc.init
   end
   
#    def showWindow(sender)
#       self.window
#    end

   def windowDidLoad
      
   end
end