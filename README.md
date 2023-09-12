# BrainFuck
BrainFuck interpreter for [Cuis Smalltalk](https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev) .

Ported from: http://www.squeaksource.com/BrainFuck.html, author: Bernat Romagosa.

## Installation Instructions
After cloning this repo, open a workspace in Cuis and type:
```Smalltalk
Feature require: #'BrainFuck'.
```

## To try it out
```Smalltalk
(BFInterpreter program: myBrainFuckProgramInAString) executeProgram.
```
### You can find some examples in BFInterpreter's class side methods, categorized under "examples".

The output is sent to the Transcript. 
![hello_bf](https://github.com/thiagoslino/BrainFuck/assets/1688134/e2437dff-7237-4fa5-a153-5e3d74012aed)

### You can output to any stream (outputTo:) and to a file (outputToFile:).
![file_bf](https://github.com/thiagoslino/BrainFuck/assets/1688134/ba05d7d9-e82a-454c-bf14-067a0fabc0ba)

### You can read a program from a file (using programFile:)
```Smalltalk
| p |
p := BFInterpreter programFile: '/path/to/file'.
p executeProgram. 
```

## References

-  http://www.squeaksource.com/BrainFuck.html
-  https://blog.klipse.tech/brainfuck/2016/12/17/brainfuck.html
-  https://esolangs.org/wiki/Brainfuck_implementations
