# zthrottle

Throttles a pipeline, only letting a line through at most every `$1` seconds.
After each cooldown interval, only the most recent line is printed.

If you've used `lodash.js`' [`_.throttle`][lodash-throttle], this is that, but
for the \*NIX command line.

## Example

Here's an illustration of what happens when you run—

```zsh
firehose | zthrottle 1 | expensive
```

![example of what happens][illustration]

Arrows represent data being written.

Here's a GIF of that:

![the same example as a GIF][gif]

## Why

This is handy for when you have a crazy high rate firehose of data on an input
stream, and a fairly expensive sink that processes them, and you don't want the
sink to get lines too often, but you do want it to get the newest one whenever
it does.  So stick `zthrottle` in between:

```zsh
firehose | zthrottle 1 | expensive
# -> `expensive` gets the most recent `firehose` line, but at 1 Hz
```

## Install

Just put `zinterval` in your `$PATH`.

You need [`zsh`][wiki-zsh].

## License

[Unlicense][unlicense].  Public domain.  Use freely.


[gif]: https://user-images.githubusercontent.com/5231746/28240490-f6b818b6-697a-11e7-9923-1d976b542582.gif
[illustration]: https://user-images.githubusercontent.com/5231746/28240427-a0bbf3c0-6979-11e7-9c0c-b597bafd3873.png
[lodash-throttle]: https://lodash.com/docs/4.17.4#throttle
[unlicense]: https://unlicense.org/
[wiki-zsh]: https://en.wikipedia.org/wiki/Z_shell
