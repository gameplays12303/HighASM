
HighASM is a programming language that combines elements of Lua and assembly to offer both high-level and low-level programming capabilities. Its syntax is very streamlined, focusing on actions that modify existing variables rather than creating new ones. Here's a summary of its main features and syntax:

### Syntax Overview
  General Form -- `[var]:[action]([arguments]...)`
  [var] -- A variable that the action will affect.
  [action] -- An operation to be performed on `[var]`.

### Compiler Configuration

  compiler:BareMode([boolean])-- Specifies whether to run directly on hardware without an OS.
  compiler:kernelMode([boolean])-- Switches between kernel and user mode.
  compiler:set_Heap_manager_class([heap_class])-- Sets the heap manager class.
  compiler:set_thread_class([thread])-- Sets the thread class.

### Keywords
  global -- Stored in RAM, must be manually removed.
  local -- Stored on the stack, nullified when the stack is popped.
  ret   Used to return values.

### Data Types
  nil -- place holder type
  static_Table-- Table with fixed size.
  number -- Numeric values.
  string -- Strings.
  boolean -- Boolean values.
  func -- Functions.
  threads -- Concurrent executions.

### Mock ASM (Restricted Assembly)
  Assembly-Like Syntax -- Similar to real assembly but restricted.
  Indirect Memory Access -- Direct memory addressing is prohibited; indirect manipulation is allowed.
  Compiler Enforcement -- Ensures no direct general-purpose memory access.

### Actions

#### For `nil` Type
  [nil]:set([value]) -- Sets a variable dynamically.
  [nil]:static_var([value|nil],[type]) -- Sets a literal variable.
  [nil]:boolean(true|false|nil) -- Reserves a variable for booleans.
  [nil]:getBytes([vars|start_label],[nil|end_IDE_address])-- Returns number of bytes.
  [nil]:syscall([args]...) -- Performs a syscall.
  [nil]:asm("string_code") -- Returns a mock ASM function pointer.
  [nil]:func("string_code") -- Returns a function pointer.
  [nil]:dynamic_Table("table|nil") -- Reserves a variable for a dynamic table.
  [nil]:static_Table([number_of_bytes]) -- Reserves a variable for a static table.
  [nil]:import("string") -- Imports external libraries.

#### For `number`
  [number]:add([number]) -- Adds a number.
  [number]:multi([number]) -- Multiplies by a number.
  [number]:divide([number]) -- Divides by a number.
  [number]:subtract([number]) -- Subtracts a number.
  [number]:greater([number]) -- Checks if greater.
  [number]:less([number]) -- Checks if less.
  [number]:equal([number]) -- Checks if equal.
  [number]:not_equal([number]) -- Checks if not equal.

#### For `string`
  [nil]:string([type],[value|nil]) -- Reserves a variable for a string.
  [str]:index() -- Gets a single character.
  [str]:add([index],[char]) -- Adds to the string.
  [str]:remove([index]) -- Removes a character.

#### For `table` (static and dynamic)
  [table]:set_index([name|number],[value]) -- Sets a value in the table.
  [table]:index([name|number]) -- Gets a value from the table.
  [table]:get_Sizes() -- Gets sizes of the table.

#### For `dynamic_Table`
  [table]:pop([index/nil]) -- Removes and returns a value.
  [table]:push([var/value],[index\nil]) -- Adds a value.

#### For `func`
  [fn]:call([args]...) -- Calls a function.
  [fn]:pcall([args]...) -- Calls a function in isolation.

#### For `threads`
  [var]:create_thread([fn]) -- Reserves a variable for threads.
  [var]:run_threads([fn]...) -- Runs threads and handles syscalls.

#### for `booleans`
  [var]:flip() -- flips the boolean
  [var]:jump(label) -- jumps if true


### Mock ASM Design
  Assembly-Like Syntax -- Mimics traditional assembly with specific restrictions.
  Indirect Memory Manipulation -- Allows indirect access while avoiding direct general memory address manipulation.
  Controlled Assembly Experience -- Ensures safety by limiting access to general-purpose memory.

  Feel free to ask if you need more details or examples on any of these features!
