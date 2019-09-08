Contributions to this project are released to the public under the [project's open source license](LICENSE).

Some useful tools in development are:

```
script/bootstrap
```

Sets up the development environment. The prerequisites are:

* Ruby 1.9+
* Bundler

```
script/test
```

Runs the test suite.

```
script/console
```

Opens `irb` console with negarmoji library preloded for experimentation.

```
script/release
```

For maintainers only: after the gemspec has been edited, this commits the
change, tags a release, and pushes it to both GitHub and RubyGems.org.
