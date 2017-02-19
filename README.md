# key_value_name

* https://github.com/jdleesmiller/key_value_name

## Synopsis

Store key-value pairs in file names, e.g. parameter names and parameters for experiments or simulation runs.

## Usage

```rb
require 'key_value_name'
require_relative 'lib/key_value_name'

ResultName = KeyValueName.new do |n|
  n.key :seed, type: Numeric, format: '%d'
  n.key :algorithm, type: Symbol
  n.key :alpha, type: Numeric
  n.extension :dat
end

name = ResultName.new(
  seed: 123,
  algorithm: :reticulating_splines,
  alpha: 42.1)
name.to_s # => seed-123.algorithm-reticulating_splines.alpha-42.1.dat
```

## INSTALLATION

  gem install key_value_name

## LICENSE

(The MIT License)

Copyright (c) 2017 John Lees-Miller

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
