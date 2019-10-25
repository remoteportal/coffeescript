# CoffeeScript is a little language that compiles into JavaScript.


## Peter's Customizations

- Copy *.js from unit test project to ReactNative project
- Conditional code: #if target

## Conditional Compilation

if:

    #if ut
    #else
    #endif

switch:

    #switch
    #when <target>
    #when <target>
    #else
    #endif

## TODO List

- learn how to run unit tests
- how pass new command line option?
- did I already do this: install MY coffeescript into rn/API/Flexbase (npm install git://github.com/remoteportal/coffeescript --save)
- finally figure out the cake 'lib' directory issue with the sub-coffeescript directory
- move cake into Flexbase?
- re-purpose for Flexbase

## Wishes List

- turn off comprehension auto-array generation or introduce new syntax?
- ability to remove trace altogether?
- Overall, to deviate as little as possible from ES6!!!
- ES6: for for-in and for-of
- ES6: Conditional (ternary) Operator (?:).  MUST HAVE SPACES or won't be able to distinguish from existential operator.  NESTABLE! [BEST: re-write grammar; POOR: pre-process file looking for ?: pattern and replace with if-then-else]

    OUCH: look for : after this expression?
    a ? b	returns a if a is in scope and a != null; otherwise, b

- ES6: Standard string interpolation ${} instead of #{} (choose new character instead of backtick for embedded JavaScript OR better yet just use tripple backtick ```)

## Research / Learn

- do comprehensions have any value?
- how to update my repo with fixes in main repo?
- learn all cake commands

## Didn't Know

- "You may even use interpolation in object keys."
- "If you don’t need the current iteration value you may omit it"
- The first ten global properties:

    globals = (name for name of window)[0...10]

- // performs floor division
- %% provides “dividend dependent modulo”
- generator in CoffeeScript is simply a function that yields
- [].concat

## Remember

- MUST pass -c to actually write transpiled .js to file!

## Installation

Once you have Node.js installed:

```shell
# Install locally for a project:
npm install --save-dev coffeescript

# Install globally to execute .coffee files anywhere:
npm install --global coffeescript
```

## Getting Started

Execute a script:

```shell
coffee /path/to/script.coffee
```

Compile a script:

```shell
coffee -c /path/to/script.coffee
```

For documentation, usage, and examples, see: http://coffeescript.org/

To suggest a feature or report a bug: https://github.com/jashkenas/coffeescript/issues

If you’d like to chat, drop by #coffeescript on Freenode IRC.

The source repository: https://github.com/jashkenas/coffeescript.git

Changelog: http://coffeescript.org/#changelog

Our lovely and talented contributors are listed here: https://github.com/jashkenas/coffeescript/contributors
