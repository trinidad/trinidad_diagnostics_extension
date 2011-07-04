# Trinidad diagnostics extension

Trinidad diagnostics let's you know the level of compatibility between
your application and JRuby. 

It uses [JRuby lint](http://github.com/jruby/jruby-lint)
under the hood to inspect your code before Trinidad starts up your
application. Once your code is audited jruby-lint generates an html report
that's located under your public directory, so you can access to it from a
browser. I.e if the application path is `/` the report is located under
`/diagnostics.html`.

## Installation

Install the gem trinidad_diagnostics_extension or add it to your Gemfile.

## Configuration

Add the extension to the Trinidad's configuration file:

    ---
      extensions:
        diagnostics:

Or load it from the command line:

    $ trinidad --load diagnostics

### Further configuration

There is a debug mode that prints the results by the console log to. Add the
option `debug: true` under the extension configuration or use the option
`--diagnostics-debug` from the command line.
