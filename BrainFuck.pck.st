'From Cuis7.1 [latest update: #6456] on 7 June 2024 at 9:53:21 pm'!
'Description BrainFuck interpreter for Cuis Smalltalk. Original version at http://www.squeaksource.com/BrainFuck.html, author Bernat Romagosa'!
!provides: 'BrainFuck' 1 1!
SystemOrganization addCategory: #BrainFuck!


!classDefinition: #BFInterpreter category: #BrainFuck!
Object subclass: #BFInterpreter
	instanceVariableNames: 'byteCellArray dataPointer program instructionPointer instructionDictionary outputStream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BrainFuck'!
!classDefinition: 'BFInterpreter class' category: #BrainFuck!
BFInterpreter class
	instanceVariableNames: ''!


!BFInterpreter methodsFor: 'loops' stamp: 'tsl 9/10/2023 18:54:31'!
closeLoop
	| openingBracketsToIgnore |
	openingBracketsToIgnore := 0.
	(byteCellArray at: dataPointer) = 0
		ifFalse: [ 
			| endLoop |
			endLoop := false.
			[endLoop]
				whileFalse: [
					self decrementInstructionPointer. 
					self currentInstruction = $]
						ifTrue: [ openingBracketsToIgnore := openingBracketsToIgnore + 1 ].
					self currentInstruction = $[
						ifTrue: [ 
							openingBracketsToIgnore = 0	
								ifTrue: [ endLoop := true ]
								ifFalse: [ openingBracketsToIgnore := openingBracketsToIgnore - 1 ] ] ] ].
		self incrementInstructionPointer.
"This implementation DOESN'T WORK for nested brackets!!"
"	(byteCellArray at: dataPointer) = 0
		ifFalse: [
			[self currentInstruction = $[] whileFalse: [
				self decrementInstructionPointer]
			].
		self incrementInstructionPointer."! !

!BFInterpreter methodsFor: 'loops' stamp: 'tsl 9/10/2023 18:56:31'!
openLoop
	"We look for both [ and ]. If we find an [ we'll ignore one ] more"

	| closingBracketsToIgnore |
	closingBracketsToIgnore := 0.
	(byteCellArray at: dataPointer) = 0
		ifTrue: [ 
			| endLoop |
			endLoop := false.
			[endLoop]
				whileFalse: [
					self incrementInstructionPointer. 
					self currentInstruction = $[
						ifTrue: [ closingBracketsToIgnore := closingBracketsToIgnore + 1 ].
					self currentInstruction = $]
						ifTrue: [ 
							closingBracketsToIgnore = 0
								ifTrue: [ endLoop := true ]
								ifFalse: [ closingBracketsToIgnore := closingBracketsToIgnore - 1 ] ] ] ].
		self incrementInstructionPointer.

		"This implementation DOESN'T WORK for nested brackets!!"	"(byteCellArray at: dataPointer) = 0
		ifTrue: [
			[self currentInstruction = $]] whileFalse: [
				self incrementInstructionPointer]
			].
		self incrementInstructionPointer."! !

!BFInterpreter methodsFor: 'accessing' stamp: 'tsl 9/10/2023 18:56:41'!
currentInstruction
	^ program at: instructionPointer! !

!BFInterpreter methodsFor: 'accessing' stamp: 'tsl 9/10/2023 18:56:47'!
program
	^ program! !

!BFInterpreter methodsFor: 'accessing' stamp: 'tsl 9/10/2023 18:56:53'!
program: anObject
	program := anObject! !

!BFInterpreter methodsFor: 'add-substract' stamp: 'tsl 9/10/2023 19:38:39'!
decrementCurrentByte
	byteCellArray
		at: dataPointer
		put:
			((byteCellArray at: dataPointer) = 0
				ifTrue: [ 255 ]
				ifFalse: [ (byteCellArray at: dataPointer) - 1 ]).
		self incrementInstructionPointer! !

!BFInterpreter methodsFor: 'add-substract' stamp: 'tsl 9/10/2023 19:38:25'!
incrementCurrentByte
	byteCellArray
		at: dataPointer
		put:
			((byteCellArray at: dataPointer) = 255
				ifTrue: [ 0 ]
				ifFalse: [ (byteCellArray at: dataPointer) + 1 ]).
		self incrementInstructionPointer! !

!BFInterpreter methodsFor: 'pointers' stamp: 'tsl 9/10/2023 18:58:12'!
decrementDataPointer
	dataPointer = 1 ifFalse: [dataPointer := dataPointer - 1].
	self incrementInstructionPointer! !

!BFInterpreter methodsFor: 'pointers' stamp: 'tsl 9/10/2023 19:39:03'!
decrementInstructionPointer
	instructionPointer := instructionPointer - 1.! !

!BFInterpreter methodsFor: 'pointers' stamp: 'tsl 9/10/2023 19:39:13'!
incrementDataPointer
	dataPointer = byteCellArray size ifFalse: [dataPointer := dataPointer + 1].
	self incrementInstructionPointer! !

!BFInterpreter methodsFor: 'pointers' stamp: 'tsl 9/10/2023 18:58:24'!
incrementInstructionPointer
	instructionPointer := instructionPointer + 1.! !

!BFInterpreter methodsFor: 'execution' stamp: 'tsl 9/10/2023 18:58:39'!
executeCurrentInstruction
	[ self perform: (instructionDictionary at: self currentInstruction) ]
		on: Error
		do: [ self incrementInstructionPointer ]! !

!BFInterpreter methodsFor: 'execution' stamp: 'tsl 9/10/2023 18:59:16'!
executeProgram
	[ instructionPointer = (program size + 1) ]	"while we haven't reached the end of the program'"
		whileFalse: [ 
			self executeCurrentInstruction]. "incrementing the instruction pointer is responsibility of each instruction"
	self initialize.! !

!BFInterpreter methodsFor: 'initialization' stamp: 'tsl 9/10/2023 18:51:42'!
initialize
	super initialize.
	byteCellArray := ByteArray new: 30000.
	dataPointer := 1.
	instructionPointer := 1.
	outputStream := Transcript.
	self initializeInstructionDictionary.! !

!BFInterpreter methodsFor: 'initialization' stamp: 'tsl 9/10/2023 18:50:42'!
initializeInstructionDictionary
	instructionDictionary := Dictionary new.
	instructionDictionary 
		at: $> put: #incrementDataPointer;
		at: $< put: #decrementDataPointer;
		at: $+ put: #incrementCurrentByte;
		at: $- put: #decrementCurrentByte;
		at: $. put: #outputCurrentByteInAscii;
		at: $, put: #requestByte;
		at: $[ put: #openLoop;
		at: $] put: #closeLoop.! !

!BFInterpreter methodsFor: 'initialization' stamp: 'tsl 9/10/2023 19:44:02'!
outputTo: aStream
	outputStream := aStream ! !

!BFInterpreter methodsFor: 'initialization' stamp: 'tsl 9/10/2023 20:17:13'!
outputToFile: aFilePath
	outputStream := aFilePath asFileEntry assureExistence writeStream ! !

!BFInterpreter methodsFor: 'input-output' stamp: 'tsl 9/10/2023 19:39:35'!
outputCurrentByte
	^ byteCellArray at: dataPointer ! !

!BFInterpreter methodsFor: 'input-output' stamp: 'tsl 6/7/2024 21:52:07'!
outputCurrentByteInAscii
	outputStream nextPut: (Character codePoint: self outputCurrentByte) ; endEntry.
	self incrementInstructionPointer.! !

!BFInterpreter methodsFor: 'input-output' stamp: 'tsl 9/11/2023 21:16:47'!
requestByte
	| requestMorph answer |
	requestMorph := StringRequestMorph
		request: 'Input a character'
		initialAnswer: ''
		do: [:aString| ].
	answer := requestMorph getUserResponseOrCancel: [^nil]. 

	byteCellArray at: dataPointer put: answer first asciiValue.
	self incrementInstructionPointer.				

	! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:45:44'!
bottles
	"99 bottles implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/99botles.bf"
	"Author: Ben Olmstead"
	"To test it doIt: BFInterpreter bottles executeProgram"
	^ super new program: '>+++++++++[<+++++++++++>-]<[>[-]>[-]<<[>+>+<<-]>>[<<+>>-]>>>
[-]<<<+++++++++<[>>>+<<[>+>[-]<<-]>[<+>-]>[<<++++++++++>>>+<
-]<<-<-]+++++++++>[<->-]>>+>[<[-]<<+>>>-]>[-]+<<[>+>-<<-]<<<
[>>+>+<<<-]>>>[<<<+>>>-]>[<+>-]<<-[>[-]<[-]]>>+<[>[-]<-]<+++
+++++[<++++++<++++++>>-]>>>[>+>+<<-]>>[<<+>>-]<[<<<<<.>>>>>-
]<<<<<<.>>[-]>[-]++++[<++++++++>-]<.>++++[<++++++++>-]<++.>+
++++[<+++++++++>-]<.><+++++..--------.-------.>>[>>+>+<<<-]>
>>[<<<+>>>-]<[<<<<++++++++++++++.>>>>-]<<<<[-]>++++[<+++++++
+>-]<.>+++++++++[<+++++++++>-]<--.---------.>+++++++[<------
---->-]<.>++++++[<+++++++++++>-]<.+++..+++++++++++++.>++++++
++[<---------->-]<--.>+++++++++[<+++++++++>-]<--.-.>++++++++
[<---------->-]<++.>++++++++[<++++++++++>-]<++++.-----------
-.---.>+++++++[<---------->-]<+.>++++++++[<+++++++++++>-]<-.
>++[<----------->-]<.+++++++++++..>+++++++++[<---------->-]<
-----.---.>>>[>+>+<<-]>>[<<+>>-]<[<<<<<.>>>>>-]<<<<<<.>>>+++
+[<++++++>-]<--.>++++[<++++++++>-]<++.>+++++[<+++++++++>-]<.
><+++++..--------.-------.>>[>>+>+<<<-]>>>[<<<+>>>-]<[<<<<++
++++++++++++.>>>>-]<<<<[-]>++++[<++++++++>-]<.>+++++++++[<++
+++++++>-]<--.---------.>+++++++[<---------->-]<.>++++++[<++
+++++++++>-]<.+++..+++++++++++++.>++++++++++[<---------->-]<
-.---.>+++++++[<++++++++++>-]<++++.+++++++++++++.++++++++++.
------.>+++++++[<---------->-]<+.>++++++++[<++++++++++>-]<-.
-.---------.>+++++++[<---------->-]<+.>+++++++[<++++++++++>-
]<--.+++++++++++.++++++++.---------.>++++++++[<---------->-]
<++.>+++++[<+++++++++++++>-]<.+++++++++++++.----------.>++++
+++[<---------->-]<++.>++++++++[<++++++++++>-]<.>+++[<----->
-]<.>+++[<++++++>-]<..>+++++++++[<--------->-]<--.>+++++++[<
++++++++++>-]<+++.+++++++++++.>++++++++[<----------->-]<++++
.>+++++[<+++++++++++++>-]<.>+++[<++++++>-]<-.---.++++++.----
---.----------.>++++++++[<----------->-]<+.---.[-]<<<->[-]>[
-]<<[>+>+<<-]>>[<<+>>-]>>>[-]<<<+++++++++<[>>>+<<[>+>[-]<<-]
>[<+>-]>[<<++++++++++>>>+<-]<<-<-]+++++++++>[<->-]>>+>[<[-]<
<+>>>-]>[-]+<<[>+>-<<-]<<<[>>+>+<<<-]>>>[<<<+>>>-]<>>[<+>-]<
<-[>[-]<[-]]>>+<[>[-]<-]<++++++++[<++++++<++++++>>-]>>>[>+>+
<<-]>>[<<+>>-]<[<<<<<.>>>>>-]<<<<<<.>>[-]>[-]++++[<++++++++>
-]<.>++++[<++++++++>-]<++.>+++++[<+++++++++>-]<.><+++++..---
-----.-------.>>[>>+>+<<<-]>>>[<<<+>>>-]<[<<<<++++++++++++++
.>>>>-]<<<<[-]>++++[<++++++++>-]<.>+++++++++[<+++++++++>-]<-
-.---------.>+++++++[<---------->-]<.>++++++[<+++++++++++>-]
<.+++..+++++++++++++.>++++++++[<---------->-]<--.>+++++++++[
<+++++++++>-]<--.-.>++++++++[<---------->-]<++.>++++++++[<++
++++++++>-]<++++.------------.---.>+++++++[<---------->-]<+.
>++++++++[<+++++++++++>-]<-.>++[<----------->-]<.+++++++++++
..>+++++++++[<---------->-]<-----.---.+++.---.[-]<<<]'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:45:58'!
fibonacci
	"Fibonacci implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/fibonacci.txt"
	"Author unknown"
	"To test it doIt: BFInterpreter fibonacci executeProgram"
	^ super new program: '+++++++++++
>+>>>>++++++++++++++++++++++++++++++++++++++++++++
>++++++++++++++++++++++++++++++++<<<<<<[>[>>>>>>+>
+<<<<<<<-]>>>>>>>[<<<<<<<+>>>>>>>-]<[>++++++++++[-
<-[>>+>+<<<-]>>>[<<<+>>>-]+<[>[-]<[-]]>[<<[>>>+<<<
-]>>[-]]<<]>>>[>>+>+<<<-]>>>[<<<+>>>-]+<[>[-]<[-]]
>[<<+>>[-]]<<<<<<<]>>>>>[+++++++++++++++++++++++++
+++++++++++++++++++++++.[-]]++++++++++<[->-<]>++++
++++++++++++++++++++++++++++++++++++++++++++.[-]<<
<<<<<<<<<<[>>>+>+<<<<-]>>>>[<<<<+>>>>-]<-[>>.>.<<<
[-]]<<[>>+>+<<<-]>>>[<<<+>>>-]<<[<+>-]>[<+>-]<<<-]'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:44:59'!
helloWorld
	"HelloWorld implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/short.b"
	"Author: Daniel B Cristofani"
	"To test it doIt: BFInterpreter helloWorld executeProgram"
	"Output is sent to the Transcript"
	^super new program: '++++++++[>++++[>++>+++>+++>+<<<<-]>+>->+>>+[<]<-]>>.>>---.+++++++..+++.>.<<-.>.+++.------.--------.>+.>++.'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:46:20'!
mandelbrot
	"Mandelbrot fractal visualizer implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/mandelbrot.b"
	"Author: Erik Bosman"
	"To test it doIt: BFInterpreter mandelbrot executeProgram"
	"Output is sent to the Transcript, make sure your Transcript font is monospace, and make sure it is at least 129 columns wide"
	"Also, make sure you have A LOT of free time..."
	^super new program: '+++++++++++++[->++>>>+++++>++>+<<<<<<]>>>>>++++++>--->>>>>>>>>>+++++++++++++++[[
>>>>>>>>>]+[<<<<<<<<<]>>>>>>>>>-]+[>>>>>>>>[-]>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>[-]+
<<<<<<<+++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>>>>+>>>>>>>>>>>>>>>>>>>>>>>>>>
>+<<<<<<<<<<<<<<<<<[<<<<<<<<<]>>>[-]+[>>>>>>[>>>>>>>[-]>>]<<<<<<<<<[<<<<<<<<<]>>
>>>>>[-]+<<<<<<++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>>>+<<<<<<+++++++[-[->>>
>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>>>+<<<<<<<<<<<<<<<<[<<<<<<<<<]>>>[[-]>>>>>>[>>>>>
>>[-<<<<<<+>>>>>>]<<<<<<[->>>>>>+<<+<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>
[>>>>>>>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+<<+<<<+<<]>>>>>>>>]<<<<<<<<<[<<<<<<<
<<]>>>>>>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+<<+<<<<<]>>>>>>>>>+++++++++++++++[[
>>>>>>>>>]+>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+[
>+>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>[-<<<<+>>>>]<<<<[->>>>+<<<<<[->>[
-<<+>>]<<[->>+>>+<<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>>>>]<<<<<<<
<<[>[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<]>[->>>>>>>>>+<<<<<<<<<]<+>>>>>>>>]<<<<<<<<<
[>[-]<->>>>[-<<<<+>[<->-<<<<<<+>>>>>>]<[->+<]>>>>]<<<[->>>+<<<]<+<<<<<<<<<]>>>>>
>>>>[>+>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>>[-<<<<<+>>>>>]<<<<<[->>>>>+
<<<<<<[->>>[-<<<+>>>]<<<[->>>+>+<<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>
>>>>>>>]<<<<<<<<<[>>[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<<]>>[->>>>>>>>>+<<<<<<<<<]<<
+>>>>>>>>]<<<<<<<<<[>[-]<->>>>[-<<<<+>[<->-<<<<<<+>>>>>>]<[->+<]>>>>]<<<[->>>+<<
<]<+<<<<<<<<<]>>>>>>>>>[>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>]>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>+++++++++++++++[[>>>>
>>>>>]<<<<<<<<<-<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+>>>>>>>>>>>>>>>>>>>>>+<<<[<<<<<<
<<<]>>>>>>>>>[>>>[-<<<->>>]+<<<[->>>->[-<<<<+>>>>]<<<<[->>>>+<<<<<<<<<<<<<[<<<<<
<<<<]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>>>[-<<<<->>>>]+<<<<[->>>>-<[-<<<+>>>]<<<[->
>>+<<<<<<<<<<<<[<<<<<<<<<]>>>[-]+>>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>>>>>>>>]<<<<<<
<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]<<<<<<<[->+>>>-<<<<]>>>>>>>>>+++++++++++++++++++
+++++++>>[-<<<<+>>>>]<<<<[->>>>+<<[-]<<]>>[<<<<<<<+<[-<+>>>>+<<[-]]>[-<<[->+>>>-
<<<<]>>>]>>>>>>>>>>>>>[>>[-]>[-]>[-]>>>>>]<<<<<<<<<[<<<<<<<<<]>>>[-]>>>>>>[>>>>>
[-<<<<+>>>>]<<<<[->>>>+<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>[-<<<<<<<<
<+>>>>>>>>>]>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>+++++++++++++++[[>>>>>>>>>]+>[-
]>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+[>+>>>>>>>>]<<<
<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>>[-<<<<<+>>>>>]<<<<<[->>>>>+<<<<<<[->>[-<<+>>]<
<[->>+>+<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>>>>]<<<<<<<<<[>[->>>>
>>>>>+<<<<<<<<<]<<<<<<<<<<]>[->>>>>>>>>+<<<<<<<<<]<+>>>>>>>>]<<<<<<<<<[>[-]<->>>
[-<<<+>[<->-<<<<<<<+>>>>>>>]<[->+<]>>>]<<[->>+<<]<+<<<<<<<<<]>>>>>>>>>[>>>>>>[-<
<<<<+>>>>>]<<<<<[->>>>>+<<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>+>>>>>>>>
]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>>[-<<<<<+>>>>>]<<<<<[->>>>>+<<<<<<[->>[-<<+
>>]<<[->>+>>+<<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>>>>]<<<<<<<<<[>
[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<]>[->>>>>>>>>+<<<<<<<<<]<+>>>>>>>>]<<<<<<<<<[>[-
]<->>>>[-<<<<+>[<->-<<<<<<+>>>>>>]<[->+<]>>>>]<<<[->>>+<<<]<+<<<<<<<<<]>>>>>>>>>
[>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
]>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>++++++++
+++++++[[>>>>>>>>>]<<<<<<<<<-<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+[>>>>>>>>[-<<<<<<<+
>>>>>>>]<<<<<<<[->>>>>>>+<<<<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>>>>[
-]>>>]<<<<<<<<<[<<<<<<<<<]>>>>+>[-<-<<<<+>>>>>]>[-<<<<<<[->>>>>+<++<<<<]>>>>>[-<
<<<<+>>>>>]<->+>]<[->+<]<<<<<[->>>>>+<<<<<]>>>>>>[-]<<<<<<+>>>>[-<<<<->>>>]+<<<<
[->>>>->>>>>[>>[-<<->>]+<<[->>->[-<<<+>>>]<<<[->>>+<<<<<<<<<<<<[<<<<<<<<<]>>>[-]
+>>>>>>[>>>>>>>>>]>+<]]+>>>[-<<<->>>]+<<<[->>>-<[-<<+>>]<<[->>+<<<<<<<<<<<[<<<<<
<<<<]>>>>[-]+>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>>>>>>>>]<<<<<<<<]>>>>>>>>]<<<<<<<<<
[<<<<<<<<<]>>>>[-<<<<+>>>>]<<<<[->>>>+>>>>>[>+>>[-<<->>]<<[->>+<<]>>>>>>>>]<<<<<
<<<+<[>[->>>>>+<<<<[->>>>-<<<<<<<<<<<<<<+>>>>>>>>>>>[->>>+<<<]<]>[->>>-<<<<<<<<<
<<<<<+>>>>>>>>>>>]<<]>[->>>>+<<<[->>>-<<<<<<<<<<<<<<+>>>>>>>>>>>]<]>[->>>+<<<]<<
<<<<<<<<<<]>>>>[-]<<<<]>>>[-<<<+>>>]<<<[->>>+>>>>>>[>+>[-<->]<[->+<]>>>>>>>>]<<<
<<<<<+<[>[->>>>>+<<<[->>>-<<<<<<<<<<<<<<+>>>>>>>>>>[->>>>+<<<<]>]<[->>>>-<<<<<<<
<<<<<<<+>>>>>>>>>>]<]>>[->>>+<<<<[->>>>-<<<<<<<<<<<<<<+>>>>>>>>>>]>]<[->>>>+<<<<
]<<<<<<<<<<<]>>>>>>+<<<<<<]]>>>>[-<<<<+>>>>]<<<<[->>>>+>>>>>[>>>>>>>>>]<<<<<<<<<
[>[->>>>>+<<<<[->>>>-<<<<<<<<<<<<<<+>>>>>>>>>>>[->>>+<<<]<]>[->>>-<<<<<<<<<<<<<<
+>>>>>>>>>>>]<<]>[->>>>+<<<[->>>-<<<<<<<<<<<<<<+>>>>>>>>>>>]<]>[->>>+<<<]<<<<<<<
<<<<<]]>[-]>>[-]>[-]>>>>>[>>[-]>[-]>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>>>[-<
<<<+>>>>]<<<<[->>>>+<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>+++++++++++++++[
[>>>>>>>>>]+>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+
[>+>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>[-<<<<+>>>>]<<<<[->>>>+<<<<<[->>
[-<<+>>]<<[->>+>+<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>>>>]<<<<<<<<
<[>[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<]>[->>>>>>>>>+<<<<<<<<<]<+>>>>>>>>]<<<<<<<<<[
>[-]<->>>[-<<<+>[<->-<<<<<<<+>>>>>>>]<[->+<]>>>]<<[->>+<<]<+<<<<<<<<<]>>>>>>>>>[
>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]>
>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>[-]>>>>+++++++++++++++[[>>>>>>>>>]<<<<<<<<<-<<<<<
<<<<[<<<<<<<<<]>>>>>>>>>-]+[>>>[-<<<->>>]+<<<[->>>->[-<<<<+>>>>]<<<<[->>>>+<<<<<
<<<<<<<<[<<<<<<<<<]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>>>[-<<<<->>>>]+<<<<[->>>>-<[-
<<<+>>>]<<<[->>>+<<<<<<<<<<<<[<<<<<<<<<]>>>[-]+>>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>
>>>>>>>]<<<<<<<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>[-<<<+>>>]<<<[->>>+>>>>>>[>+>>>
[-<<<->>>]<<<[->>>+<<<]>>>>>>>>]<<<<<<<<+<[>[->+>[-<-<<<<<<<<<<+>>>>>>>>>>>>[-<<
+>>]<]>[-<<-<<<<<<<<<<+>>>>>>>>>>>>]<<<]>>[-<+>>[-<<-<<<<<<<<<<+>>>>>>>>>>>>]<]>
[-<<+>>]<<<<<<<<<<<<<]]>>>>[-<<<<+>>>>]<<<<[->>>>+>>>>>[>+>>[-<<->>]<<[->>+<<]>>
>>>>>>]<<<<<<<<+<[>[->+>>[-<<-<<<<<<<<<<+>>>>>>>>>>>[-<+>]>]<[-<-<<<<<<<<<<+>>>>
>>>>>>>]<<]>>>[-<<+>[-<-<<<<<<<<<<+>>>>>>>>>>>]>]<[-<+>]<<<<<<<<<<<<]>>>>>+<<<<<
]>>>>>>>>>[>>>[-]>[-]>[-]>>>>]<<<<<<<<<[<<<<<<<<<]>>>[-]>[-]>>>>>[>>>>>>>[-<<<<<
<+>>>>>>]<<<<<<[->>>>>>+<<<<+<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>+>[-<-<<<<+>>>>
>]>>[-<<<<<<<[->>>>>+<++<<<<]>>>>>[-<<<<<+>>>>>]<->+>>]<<[->>+<<]<<<<<[->>>>>+<<
<<<]+>>>>[-<<<<->>>>]+<<<<[->>>>->>>>>[>>>[-<<<->>>]+<<<[->>>-<[-<<+>>]<<[->>+<<
<<<<<<<<<[<<<<<<<<<]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>[-<<->>]+<<[->>->[-<<<+>>>]<
<<[->>>+<<<<<<<<<<<<[<<<<<<<<<]>>>[-]+>>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>>>>>>>>]<
<<<<<<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>[-<<<+>>>]<<<[->>>+>>>>>>[>+>[-<->]<[->+
<]>>>>>>>>]<<<<<<<<+<[>[->>>>+<<[->>-<<<<<<<<<<<<<+>>>>>>>>>>[->>>+<<<]>]<[->>>-
<<<<<<<<<<<<<+>>>>>>>>>>]<]>>[->>+<<<[->>>-<<<<<<<<<<<<<+>>>>>>>>>>]>]<[->>>+<<<
]<<<<<<<<<<<]>>>>>[-]>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+<<+<<<<<]]>>>>[-<<<<+>
>>>]<<<<[->>>>+>>>>>[>+>>[-<<->>]<<[->>+<<]>>>>>>>>]<<<<<<<<+<[>[->>>>+<<<[->>>-
<<<<<<<<<<<<<+>>>>>>>>>>>[->>+<<]<]>[->>-<<<<<<<<<<<<<+>>>>>>>>>>>]<<]>[->>>+<<[
->>-<<<<<<<<<<<<<+>>>>>>>>>>>]<]>[->>+<<]<<<<<<<<<<<<]]>>>>[-]<<<<]>>>>[-<<<<+>>
>>]<<<<[->>>>+>[-]>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+<<+<<<<<]>>>>>>>>>[>>>>>>
>>>]<<<<<<<<<[>[->>>>+<<<[->>>-<<<<<<<<<<<<<+>>>>>>>>>>>[->>+<<]<]>[->>-<<<<<<<<
<<<<<+>>>>>>>>>>>]<<]>[->>>+<<[->>-<<<<<<<<<<<<<+>>>>>>>>>>>]<]>[->>+<<]<<<<<<<<
<<<<]]>>>>>>>>>[>>[-]>[-]>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>[-]>[-]>>>>>[>>>>>[-<<<<+
>>>>]<<<<[->>>>+<<<+<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>>>>[-<<<<<+>>>>>
]<<<<<[->>>>>+<<<+<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>+++++++++++++++[[>>>>
>>>>>]+>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]>[-]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+[>+>>
>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>[-<<<<+>>>>]<<<<[->>>>+<<<<<[->>[-<<+
>>]<<[->>+>>+<<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>>>>]<<<<<<<<<[>
[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<]>[->>>>>>>>>+<<<<<<<<<]<+>>>>>>>>]<<<<<<<<<[>[-
]<->>>>[-<<<<+>[<->-<<<<<<+>>>>>>]<[->+<]>>>>]<<<[->>>+<<<]<+<<<<<<<<<]>>>>>>>>>
[>+>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>->>>>>[-<<<<<+>>>>>]<<<<<[->>>>>+<<<<
<<[->>>[-<<<+>>>]<<<[->>>+>+<<<<]+>>>>>>>>>]<<<<<<<<[<<<<<<<<<]]>>>>>>>>>[>>>>>>
>>>]<<<<<<<<<[>>[->>>>>>>>>+<<<<<<<<<]<<<<<<<<<<<]>>[->>>>>>>>>+<<<<<<<<<]<<+>>>
>>>>>]<<<<<<<<<[>[-]<->>>>[-<<<<+>[<->-<<<<<<+>>>>>>]<[->+<]>>>>]<<<[->>>+<<<]<+
<<<<<<<<<]>>>>>>>>>[>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>]>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>+++++++++++++++[[>>>>>>>>
>]<<<<<<<<<-<<<<<<<<<[<<<<<<<<<]>>>>>>>>>-]+>>>>>>>>>>>>>>>>>>>>>+<<<[<<<<<<<<<]
>>>>>>>>>[>>>[-<<<->>>]+<<<[->>>->[-<<<<+>>>>]<<<<[->>>>+<<<<<<<<<<<<<[<<<<<<<<<
]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>>>[-<<<<->>>>]+<<<<[->>>>-<[-<<<+>>>]<<<[->>>+<
<<<<<<<<<<<[<<<<<<<<<]>>>[-]+>>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>>>>>>>>]<<<<<<<<]>
>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>->>[-<<<<+>>>>]<<<<[->>>>+<<[-]<<]>>]<<+>>>>[-<<<<
->>>>]+<<<<[->>>>-<<<<<<.>>]>>>>[-<<<<<<<.>>>>>>>]<<<[-]>[-]>[-]>[-]>[-]>[-]>>>[
>[-]>[-]>[-]>[-]>[-]>[-]>>>]<<<<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>>>[-]>>>>]<<<<<<<<<
[<<<<<<<<<]>+++++++++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>+>>>>>>>>>+<<<<<<<<
<<<<<<[<<<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+[-]>>[>>>>>>>>>]<<<<<
<<<<[>>>>>>>[-<<<<<<+>>>>>>]<<<<<<[->>>>>>+<<<<<<<[<<<<<<<<<]>>>>>>>[-]+>>>]<<<<
<<<<<<]]>>>>>>>[-<<<<<<<+>>>>>>>]<<<<<<<[->>>>>>>+>>[>+>>>>[-<<<<->>>>]<<<<[->>>
>+<<<<]>>>>>>>>]<<+<<<<<<<[>>>>>[->>+<<]<<<<<<<<<<<<<<]>>>>>>>>>[>>>>>>>>>]<<<<<
<<<<[>[-]<->>>>>>>[-<<<<<<<+>[<->-<<<+>>>]<[->+<]>>>>>>>]<<<<<<[->>>>>>+<<<<<<]<
+<<<<<<<<<]>>>>>>>-<<<<[-]+<<<]+>>>>>>>[-<<<<<<<->>>>>>>]+<<<<<<<[->>>>>>>->>[>>
>>>[->>+<<]>>>>]<<<<<<<<<[>[-]<->>>>>>>[-<<<<<<<+>[<->-<<<+>>>]<[->+<]>>>>>>>]<<
<<<<[->>>>>>+<<<<<<]<+<<<<<<<<<]>+++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>+<<<
<<[<<<<<<<<<]>>>>>>>>>[>>>>>[-<<<<<->>>>>]+<<<<<[->>>>>->>[-<<<<<<<+>>>>>>>]<<<<
<<<[->>>>>>>+<<<<<<<<<<<<<<<<[<<<<<<<<<]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>>>>>>[-<
<<<<<<->>>>>>>]+<<<<<<<[->>>>>>>-<<[-<<<<<+>>>>>]<<<<<[->>>>>+<<<<<<<<<<<<<<[<<<
<<<<<<]>>>[-]+>>>>>>[>>>>>>>>>]>[-]+<]]+>[-<[>>>>>>>>>]<<<<<<<<]>>>>>>>>]<<<<<<<
<<[<<<<<<<<<]>>>>[-]<<<+++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>-<<<<<[<<<<<<<
<<]]>>>]<<<<.>>>>>>>>>>[>>>>>>[-]>>>]<<<<<<<<<[<<<<<<<<<]>++++++++++[-[->>>>>>>>
>+<<<<<<<<<]>>>>>>>>>]>>>>>+>>>>>>>>>+<<<<<<<<<<<<<<<[<<<<<<<<<]>>>>>>>>[-<<<<<<
<<+>>>>>>>>]<<<<<<<<[->>>>>>>>+[-]>[>>>>>>>>>]<<<<<<<<<[>>>>>>>>[-<<<<<<<+>>>>>>
>]<<<<<<<[->>>>>>>+<<<<<<<<[<<<<<<<<<]>>>>>>>>[-]+>>]<<<<<<<<<<]]>>>>>>>>[-<<<<<
<<<+>>>>>>>>]<<<<<<<<[->>>>>>>>+>[>+>>>>>[-<<<<<->>>>>]<<<<<[->>>>>+<<<<<]>>>>>>
>>]<+<<<<<<<<[>>>>>>[->>+<<]<<<<<<<<<<<<<<<]>>>>>>>>>[>>>>>>>>>]<<<<<<<<<[>[-]<-
>>>>>>>>[-<<<<<<<<+>[<->-<<+>>]<[->+<]>>>>>>>>]<<<<<<<[->>>>>>>+<<<<<<<]<+<<<<<<
<<<]>>>>>>>>-<<<<<[-]+<<<]+>>>>>>>>[-<<<<<<<<->>>>>>>>]+<<<<<<<<[->>>>>>>>->[>>>
>>>[->>+<<]>>>]<<<<<<<<<[>[-]<->>>>>>>>[-<<<<<<<<+>[<->-<<+>>]<[->+<]>>>>>>>>]<<
<<<<<[->>>>>>>+<<<<<<<]<+<<<<<<<<<]>+++++[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>>
+>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<[<<<<<<<<<]>>>>>>>>>[>>>>>>[-<<<<<<->>>>>>]+<
<<<<<[->>>>>>->>[-<<<<<<<<+>>>>>>>>]<<<<<<<<[->>>>>>>>+<<<<<<<<<<<<<<<<<[<<<<<<<
<<]>>>>[-]+>>>>>[>>>>>>>>>]>+<]]+>>>>>>>>[-<<<<<<<<->>>>>>>>]+<<<<<<<<[->>>>>>>>
-<<[-<<<<<<+>>>>>>]<<<<<<[->>>>>>+<<<<<<<<<<<<<<<[<<<<<<<<<]>>>[-]+>>>>>>[>>>>>>
>>>]>[-]+<]]+>[-<[>>>>>>>>>]<<<<<<<<]>>>>>>>>]<<<<<<<<<[<<<<<<<<<]>>>>[-]<<<++++
+[-[->>>>>>>>>+<<<<<<<<<]>>>>>>>>>]>>>>>->>>>>>>>>>>>>>>>>>>>>>>>>>>-<<<<<<[<<<<
<<<<<]]>>>]'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:46:48'!
quine
	"A quine (program that outputs itself) implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/quine505.b"
	"Author: Erik Bosman"
	"To test it doIt: BFInterpreter quine executeProgram"
	"Output is sent to the Transcript."
	^super new program: '-->+++>+>+>+>+++++>++>++>->+++>++>+>>>>>>>>>>>>>>>>->++++>>>>->+++>+++>+++>+++>+++>+++>+>+>>>->->>++++>+>>>>->>++++>+>+>>->->++>++>++>++++>+>++>->++>++++>+>+>++>++>->->++>++>++++>+>+>>>>>->>->>++++>++>++>++++>>>>>->>>>>+++>->++++>->->->+++>>>+>+>+++>+>++++>>+++>->>>>>->>>++++>++>++>+>+++>->++++>>->->+++>+>+++>+>++++>>>+++>->++++>>->->++>++++>++>++++>>++[-[->>+[>]++[<]<]>>+[>]<--[++>++++>]+[<]<<++]>>>[>]++++>++++[--[+>+>++++<<[-->>--<<[->-<[--->>+<<[+>+++<[+>>++<<]]]]]]>+++[>+++++++++++++++<-]>--.<<<]'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:48:35'!
sierpinski
	"Sierpinski triangle implementation found in http://esoteric.sange.fi/brainfuck/bf-source/prog/triangle.bf"
	"Author: Nyyrikki"
	"To test it doIt: BFInterpreter sierpinski executeProgram"
	"Output is sent to the Transcript, make sure your Transcript font is monospace, and make sure it is at least 80 columns wide"
	^super new program: '
                                >    
                               + +    
                              +   +    
                             [ < + +    
                            +       +    
                           + +     + +    
                          >   -   ]   >    
                         + + + + + + + +    
                        [               >    
                       + +             + +    
                      <   -           ]   >    
                     > + + >         > > + >    
                    >       >       +       <    
                   < <     < <     < <     < <    
                  <   [   -   [   -   >   +   <    
                 ] > [ - < + > > > . < < ] > > >    
                [                               [    
               - >                             + +    
              +   +                           +   +    
             + + [ >                         + + + +    
            <       -                       ]       >    
           . <     < [                     - >     + <    
          ]   +   >   [                   -   >   +   +    
         + + + + + + + +                 < < + > ] > . [    
        -               ]               >               ]    
       ] +             < <             < [             - [    
      -   >           +   <           ]   +           >   [    
     - < + >         > > - [         - > + <         ] + + >    
    [       -       <       -       >       ]       <       <    
   < ]     < <     < <     ] +     + +     + +     + +     + +    
  +   .   +   +   +   .   [   -   ]   <   ]   +   +   +   +   +    '! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 19:03:49'!
test1
	"Brainfuck implementation test found in http://esoteric.sange.fi/brainfuck/bf-source/prog/tests.b"
	"Author: Daniel B Cristofani"
	"To test it doIt: BFInterpreter test1 executeProgram"
	"Output is sent to the Transcript. It should output an H"
	^super new program: '[]++++++++++[>++++++++++++++++++>+++++++>+<<<-]A;?@!![#>>+<<]>[>++<[-]]>.>.'! !

!BFInterpreter class methodsFor: 'examples' stamp: 'tsl 9/10/2023 18:45:30'!
test2
	"Brainfuck implementation test found in http://esoteric.sange.fi/brainfuck/bf-source/prog/tests.b"
	"Author: Daniel B Cristofani"
	"To test it doIt: BFInterpreter test2 executeProgram"
	"Output is sent to the Transcript. It should output an # (it takes a while)"
	^super new program: '++++[>++++++<-]>[>+++++>+++++++<<-]>>++++<[[>[[>>+<<-]<]>>>-]>-[>+>+<<-]>]+++++[>+++++++<<++>-]>.<<.'! !

!BFInterpreter class methodsFor: 'instance creation' stamp: 'tsl 9/10/2023 18:48:58'!
new
	self error: 'Please instantiate me by doing BFInterpreter program: yourProgramInAString'! !

!BFInterpreter class methodsFor: 'instance creation' stamp: 'tsl 9/10/2023 18:49:06'!
program: aProgram
	^super new program: aProgram! !

!BFInterpreter class methodsFor: 'instance creation' stamp: 'tsl 9/10/2023 20:03:52'!
programFile: aFile
	^super new program: (aFile asFileEntry fileContents)! !
