# Action.rb
# Countdown
#
# Created by Andre Berg on 28.02.10.
# Copyright 2010 Berg Media. All rights reserved.

# Action deals with what happens when the countdown has ended.
# The user may choose from a set of pre-existing options, e.g.:
# 
#  a) Shutdown
#  b) Sleep
#  c) Dialog
#  d) Dialog + Beep
#  e) Custom Action
# 
# These options will be implemented using a matrix form containing
# radio buttons. Below the form will be a text field where the user
# can enter a text to be displayed for options based on a dialog or
# a short shell script for the custom action. As an added bonus the
# custom action should recognize automatically when the user enters
# a path to a shell script file and execute the shell script from 
# the file in a new environment instead. 

class Time
   def self.mstamp
      n = self.now
      n.strftime("%H:%M:%S.#{String(n.usec).substringToIndex 3}")
   end
   def self.ustamp
      n = self.now
      n.strftime("%H:%M:%S.#{n.usec}")
   end
   def self.stamp
      now.strftime("%H:%M:%S")
   end
   def self.datemstamp
      n = self.now
      n.strftime("%Y-%m-%d %H:%M:%S.#{String(n.usec).substringToIndex 3} %z")
   end
end

class Action
   
   attr_accessor :type, :text

   Types = [
      'Shut Down', 
      'Sleep', 
      'Log Off', 
      'Dialog', 
      'Dialog + Beep', 
      'Shell Script'
   ]
   
   def initialize(appController, type, text)
      @type = type
      @text = text
      @appController = appController
   end
   
   def run
      puts "executing action '#{@type}' with action text '#{Time.mstamp + ': ' + @text}'"
      @appController.startStopCountdown(self)
   end
   
end