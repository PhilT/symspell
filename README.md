## Synopsis

The Symmetric Delete spelling correction algorithm reduces the complexity of edit candidate generation and dictionary lookup for a given Damerau-Levenshtein distance.

Same license as original (LGPL-3.0).


## About this port

This is a straight port of SymSpell from C# to Ruby. I've started moving things around a bit and also turned it into a gem.

Original source with inline comments and README is here: https://github.com/wolfgarbe/symspell.

I've changed very little from the original source (apart from removing the commandline interface) but please note it has no test coverage at this time.


## Usage

    gem install symspell

    require 'symspell'

    speller = SymSpell.new <EDIT_DISTANCE_MAX>
    speller.create_dictionary('words.txt')
    speller.lookup('something')

## EDIT_DISTANCE_MAX

`EDIT_DISTANCE_MAX` is the number of letters to remove to find a match. Standard text should be around 2-3 if you have a smaller dictionary you could try larger numbers to catch drastically misspelt words. Note that creating the dictionary will take a lot longer as the combinations go up exponentially.

