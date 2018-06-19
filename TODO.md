#  Smart Car TODO list

## CANHACK

- [DONE] Fix perf bottleneck in parsing.. wewrite parsing to be cleaner, modular, and use less string mutation
- [DONE]Update Occurance Graph drawing code to skip repeated lines of the same color (note.. may not be necessary with next change)
- Change Occurance Graph to automatically switch to "continuous mode" for signals over say 10 
- [DONE] (or just stop drawing after 10)
- Write some Tests!! :)

Other:
- [DONE] Revisit "Signal Abstraction".. make it more clear/useful/
  - update UI code to match the abstraction
- Maybe it should be "Message Abstraction" with a specifc type of Message (ie. CAN extended, CAN normal, LIN...)
- Consider Occurance Graph Controller?

### Main MessageSetTableView 
- More views and sorting options?
 - Hide Data Labels?
 - Show Data Labels in Binary
 - Show Occurace Graphs at the byte level (or should we always do this?)
 - Ability to move all the graphs over so they aren't under the labels? 
   - (A graph view cooridnator to match scales and sizes across the tables)
 - **Filtering!**
  - Filter on specifc bytes of IDs (or datas)
  - Filter with regex or some other pattern matching syntax
  - Filter what has already been annotated (do you do this at an id level, byte level?)
- Even higher level grouping.. here are all the xxxxxx50s and xxxxxx30s or here are all the 1610xxxxs or AF8xxxxs

Maybe what we need is a search box? where you can just put in 0xAFxx0050 or whatever and find stuff?
Yeah.. and then when you tap on the search box you get filter suggestions for recent filters
But maybe also have a list of specifc ID's to hide.. OH! you could use swipe to delete to hide, and maybe it just shrinks down to be really
small and you can tap on it to bring it back up.. i like that.. that's all the filtering you'd ever need, and it's simple, intuitive, and you're 
operating directly on the data.. not need to switch workflows or bring up another screen on mobile. 

### Drill into ID 
Tap on an ID to see more interesting data
Number of times, avg time between messages
Breakdown of every bit in the message, plus the ability to scroll through time again
This is also the place to add signal Annotations and show detailed graphs
Use this as a place to show comparisions to other files
  - Stack histograms from other files (maybe just a list of recent ones, plus the ability to manually pin)

### Looking through time
Some way to zoom/scroll though histograms 
^^ Maybe just that.. zoom and scroll gestures?

### Annotation
- DBC like features..
- Label groups of IDs by byte(s)? (or regex)
- Label Messages
- Label signals within messages
  - Label Descrete options.. (ie 02 is brake on, 00 is brake off) 
  - Label Continous options (ie bit 0-12, big endian, signed, scale, offset, all that jazz)
  - Maybe look at exisitng DBC functionality and see if we want to use that or switch to our own
- Switch from generic occurance graph to annotation specfic
  - Identify which bytes are part of a continuous labeling, descrete labeling, and unlabled and graph approprietly 
  - Makes for a more logical filter on unlabeled (maybe filter on labeling type)
  - Trick is graphing the unlabled stuff (lol is this getting complicated, time for that occurance graph controller)
  - I guess you just look at all the bytes between labeled signals 
  - This actually resovles do you show things at the byte level or whole data level, you just pick one (probably whole data) and as you label it 
  quickly becomes smaller parts

  ### Set comparison
  (File comparision)
  Maybe the best way to do this is to do a side by side (vertically) between all the files
  Good at a Drill into ID option
  
  ### Settings storage
  - Goes with above, but configurations for annotations and labeling should be saved
  - How do we group configurations between the same bus? 
  - Maybe they are assigned to a dbc/Annotation file, and you pull up an annotation file and associate it with a message set

### Live Updating
- Append Feature for MessageStats
- Ability to update only the graph views that change? (animate! :)
- Record and Save
- ^^ More general, but make our own binary file format to improve load times
- Make a great live viewing experince by automatically sorting messages that look relevant to the top
- (probably by just seeing what changes the most)
Maybe dim things that don't change as much

### **Sending!!!**
Start with "Try Replaying this message"
Some way to create a sort/specifc recording of messages to play
Cool rules from savvyCAN, repeat x times, trigger on whatever, + generating data dynamically
Scripting... This doesn't seem that cool, but maybe theres a good use for it (Python?)

### Advanced RE features
Cool stuff from SavvyCAN like "Here are continous signals that look interesting", or cycle through your states and we'll see what changes
These aren't super useful with Live updating you should be able to find most signals quickly, but could be usefull on busses with
a lot more traffic (My car's can busses are pretty sparce, but a modern car with even more connectivtiy could make it trickier)
