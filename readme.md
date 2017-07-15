# zthrottle

Throttles a pipeline, only letting a line through at most every `$1` seconds.
After each cooldown interval, only the most recent line is printed.

If you've used `lodash.js`' [`_.throttle`][lodash-throttle], this is that, but
for the \*NIX command line.

Here's an illustration from [the UNIX SE question][question].  Arrows represent
data being written.

![how it should look](https://i.stack.imgur.com/1CwCP.png)

## Install

Just put `zinterval` in your `$PATH`.

You need [`zsh`][wiki-zsh].

## Why

This is handy for when you have a crazy high rate firehose of data on an input
stream, and a fairly expensive sink that processes them, and you don't want the
sink to get lines too often, but you do want it to get the newest one whenever
it does.  So stick `zthrottle` in between:

```zsh
firehose | zthrottle 1 | expensive
# -> `expensive` gets the most recent `firehose` line, but at 1 Hz
```

## License

[Unlicense][unlicense].  Public domain.  Use freely.


[lodash-throttle]: https://lodash.com/docs/4.17.4#throttle
[question]: https://unix.stackexchange.com/q/378334/16404
[wiki-zsh]: https://en.wikipedia.org/wiki/Z_shell
[unlicense]: https://unlicense.org/
