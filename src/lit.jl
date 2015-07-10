#!/usr/bin/env julia

# Functions
function name(path)
    basename(path[1:search(path, '.')[1]-1])
end

# Parse the arguments
html = false
code = false
outdir = "."
index = true

inputfiles = String[]

for arg in ARGS
    if arg == "-h"
        println("Usage: lit [-noindex] [-html] [-code] [--out-dir=dir] [file ...]")
        exit()
    elseif arg == "-html"
        html = true
    elseif arg == "-code"
        code = true
    elseif arg == "-noindex"
        index = false
    elseif startswith(arg, "--out-dir=")
        outdir = realpath(arg[11:end])
    else
        push!(inputfiles, arg)
    end
end

if !html && !code
    html = code = true
end

gen = "$(dirname(Base.source_path()))/../gen"

if length(inputfiles) == 0
# Use STDIN and STDOUT
input = readall(STDIN)
if html
    include("$gen/weave.jl")
    weave(readlines(IOBuffer(input)), STDOUT, ".", "none", false)
end

if code
    include("$gen/tangle.jl")
    tangle(readlines(IOBuffer(input)))
end

else
# Weave and/or tangle the input files
if code
    include("$gen/tangle.jl")
end
if html
    include("$gen/weave.jl")
end

for file in inputfiles
    inputstream = open(file)
    input = readall(inputstream)
    close(inputstream)
    source_dir = dirname(file) == "" ? "." : dirname(file)
    if html
        outputstream = open("$outdir/$(name(file)).html", "w")
        weave(readlines(IOBuffer(input)), outputstream, source_dir, file, index)
        close(outputstream)
    end
    if code
        tangle(readlines(IOBuffer(input)))
    end
end

end

# vim: set ft=julia:

