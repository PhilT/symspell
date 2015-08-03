## Synopsis

The Symmetric Delete spelling correction algorithm reduces the complexity of edit candidate generation and dictionary lookup for a given Damerau-Levenshtein distance.

Same license as original (LGPL-3.0).


## About this port

This is a straight port of SymSpell from C# to Ruby. I've started moving things around a bit and also turned it into a gem.

Original source with inline comments and README is here: https://github.com/wolfgarbe/symspell.

I've changed very little from the original source (apart from removing the commandline interface) but please note it has only some very basic end to end tests at this time.


## Usage

    gem install symspell

    require 'symspell'

    speller = SymSpell.new <EDIT_DISTANCE_MAX> <VERBOSE>
    speller.create_dictionary %w(joe jo mark john peter mary andrew imogen)
    speller.lookup 'jo'

### EDIT_DISTANCE_MAX

`EDIT_DISTANCE_MAX` is the number of operations needed to tranform one string into another.

For example the edit distance between **CA** and **ABC** is 2 because **CA** => **AC** => **ABC**. Edit distances of 2-5 are normal. Note, however, increasing EDIT_DISTANCE_MAX exponentially increases the combinations and therefore the time it takes to create the dictionary.

### VERBOSE

* 0 - Return the top suggestion
* 1 - Return the suggestions with the lowest edit distance
* 2 - Return all suggestions

