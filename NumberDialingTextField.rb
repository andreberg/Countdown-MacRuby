# NumberDialingTextField.rb
# Countdown
#
# Created by Andre Berg on 28.02.10.
# Copyright 2010 Berg Media. All rights reserved.

# The next two subclasses deal with swapping the default field editor
# for the custom one defined here. We need to do this because we want
# to catch keyDown events. Because keyDown events happen at the begin
# of an edit in an NSTextField they are sent to the text fields field 
# editor and not the text field itself.
# This is also why keyUp events can be caught directly on NSTextFields
# as keyUp events happen when editing has ended and thus the text field
# becomes the first responder again.
# Compare to http://tinyurl.com/yz6rfus (Text Editing Programming Guide
# for Cocoa - Using a Custom Field Editor).
# Our custom field editor will get swapped in for the defalt one when
# we return from the corresponding NSWindow delegate method in our 
# AppController.

require 'AppController'

class NumberDialingTextFieldEditor < NSTextView

   attr_accessor :timeTextField, :timeStepper
   
   def keyDown(event)
      characters = event.characters
      if characters.length == 1
         character = characters.characterAtIndex(0)
         if character == NSLeftArrowFunctionKey
            #puts "LEFT pressed"
         elsif character == NSRightArrowFunctionKey
            #puts "RIGHT pressed"
         elsif character == NSUpArrowFunctionKey
            #puts "UP pressed"
            timeTextField.doubleValue += 1
            timeStepper.takeDoubleValueFrom(timeTextField)
         elsif character == NSDownArrowFunctionKey
            #puts "DOWN pressed"
            timeTextField.doubleValue -= 1
            timeStepper.takeDoubleValueFrom(timeTextField)
         end
      end
      super
   end

end

class NumberDialingTextField < NSTextField
   
   attr_accessor :timeStepper
   
   def awakeFromNib
      self.addTrackingRect self.bounds, owner:self, userData:nil, assumeInside:true
   end
      
   def mouseEntered(theEvent)
      #puts "mouse entered #{theEvent.description}"
      if not AppController.isCounting?
         self.becomeFirstResponder
      end
      super
   end
   
   def mouseExited(theEvent)
      #puts "mouse exited #{theEvent.description}"
      if not AppController.isCounting?
         timeStepper.takeDoubleValueFrom(self)
      end
      super
   end
   
   def scrollWheel(theEvent)
      #puts "scroll wheel #{theEvent.description}"
      self.becomeFirstResponder
      
      dy = theEvent.deltaY
      mf = theEvent.modifierFlags
      
      if (mf & NSCommandKeyMask) > 0 then
         dy *= 10
         elsif (mf & NSAlternateKeyMask) > 0 then
         dy *= 0.1
      end
      
      self.doubleValue += dy
      timeStepper.doubleValue += dy
      super
   end
   
end