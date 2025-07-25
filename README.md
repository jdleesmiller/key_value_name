# key_value_name

* https://github.com/jdleesmiller/key_value_name

## Synopsis

An 'object-file system mapper' for managing data files. Key-value pairs describing the data in each file are stored in its name. Useful for managing data files for experiments or simulation runs.

This gem provides:

1. Some standard naming conventions that work well across platforms by avoiding special characters in file names.

2. Automatic formatting and type conversion for the parameters.

3. A schema builder to organize files and folders and declare what parameters are allowed.

## Usage

```rb
require 'key_value_name'

Results = KeyValueName.schema do
  folder :simulation do
    key :seed, type: Integer, format: '%06d'
    key :algorithm, type: Symbol
    key :alpha, type: Float

    file :stats, :csv
  end
end

results = Results.new(root: 'data/results')

sim = results.simulation.new(
  seed: 123,
  algorithm: :reticulating_splines,
  alpha: 42.1)

sim.to_s
# => "data/results/simulation-seed-000123.algorithm-reticulating_splines.alpha-42.1"

sim.stats_csv.to_s
# => "data/results/simulation-seed-000123.algorithm-reticulating_splines.alpha-42.1/stats.csv"

# Pretend we've run a simulation and written the results...
sim.stats_csv.touch!

# List the results
results.simulation.all
# => [#<struct Results::Simulation seed=123, algorithm=:reticulating_splines, alpha=42.1>]

results.simulation.all.map(&:stats_csv).map(&:to_s)
# => ["data/results/simulation-seed-000123.algorithm-reticulating_splines.alpha-42.1/stats.csv"]
```

## INSTALLATION

```
gem install key_value_name
```

## LICENSE

(The MIT License)

Copyright (c) 2017-2025 John Lees-Miller

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
