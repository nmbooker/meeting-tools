#! /usr/bin/env ruby

while gets
  $_.sub!(/ *# TOPIC [0-9.]+ # *$/, '')
  $stdout.puts $_
end
