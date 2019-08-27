require 'active_support/all'
require 'set'

class SymSpell
  MAX_INT = 2**30 - 1

  def initialize(edit_distance_max, verbose)
    @edit_distance_max = edit_distance_max
    @verbose = verbose
    @maxlength = 0
    @dictionary = {}
    @wordlist = []
  end

  def create_dictionary(corpus)
    word_count = 0

    corpus.each do |word|
      word_count += 1 if create_dictionary_entry(word.strip)
    end
  end

  def lookup(input)
    return [] if (input.size - @edit_distance_max) > @maxlength

    candidates = []
    hashset1 = Set.new

    suggestions = []
    hashset2 = Set.new

    valueo = nil

    candidates << input

    while (candidates.count > 0)
      candidate = candidates.shift

      return sort(suggestions) if @verbose < 2 && suggestions.count > 0 && (input.size - candidate.size) > suggestions[0].distance

      if valueo = @dictionary[candidate]
        value = DictionaryItem.new
        if (valueo.is_a?(Integer))
          value.suggestions << valueo
        else
          value = valueo
        end

        if (value.count > 0) && hashset2.add?(candidate)
          si = SuggestItem.new
          si.term = candidate
          si.count = value.count
          si.distance = input.size - candidate.size
          suggestions << si
          return sort(suggestions) if @verbose < 2 && input.size - candidate.size == 0
        end

        value2 = nil
        value.suggestions.each do |suggestionint|
          suggestion = @wordlist[suggestionint]
          if hashset2.add?(suggestion)
            distance = 0
            if suggestion != input
              if suggestion.size == candidate.size
                distance = input.size - candidate.size
              elsif input.size == candidate.size
                distance = suggestion.size - candidate.size
              else
                ii = 0
                jj = 0
                while (ii < suggestion.size) && (ii < input.size) && (suggestion[ii] == input[ii])
                  ii += 1
                end

                while (jj < suggestion.size - ii) && (jj < input.size - ii) && (suggestion[suggestion.size - jj - 1] == input[input.size - jj - 1])
                  jj += 1
                end

                if ii > 0 || jj > 0
                  distance = damerau_levenshtein_distance(
                    suggestion[ii..(suggestion.size - jj)],
                    input[ii..(input.size - jj)])
                else
                  distance = damerau_levenshtein_distance(suggestion, input)
                end
              end
            end

            suggestions.clear if @verbose < 2  && suggestions.count > 0 && suggestions[0].distance > distance
            next if @verbose < 2  && suggestions.count > 0 && distance > suggestions[0].distance

            if (distance <= @edit_distance_max)
              value2 = @dictionary[suggestion]
              if value2
                si = SuggestItem.new
                si.term = suggestion
                si.count = value2.count
                si.distance = distance
                suggestions << si
              end
            end
          end
        end
      end

      if (input.size - candidate.size < @edit_distance_max)
        if suggestions.count > 0 && input.size - candidate.size >= suggestions[0].distance
          next
        end

        candidate.size.times do |i|
          delete = candidate.dup
          delete.slice!(i)
          if hashset1.add?(delete)
            candidates << delete
          end
        end
      end
    end
    sort(suggestions)
  end


  private

  class DictionaryItem
    attr_accessor :suggestions, :count

    def initialize
      @suggestions = []
      @count = 0
    end
  end

  class SuggestItem
    attr_accessor :term, :distance, :count

    def initialize
      @term = ''
      @distance = 0
      @count = 0
    end

    def ==(other)
      term == other.term
    end

    def hash
      term.hash
    end
  end

  def parse_words(text)
    text.downcase.scan(/[\w-[\d_]]+/).first
  end

  def create_dictionary_entry(key)
    result = false
    value = nil
    valueo = @dictionary[key]
    if valueo
      if valueo.is_a?(Integer)
        tmp = valueo
        value = DictionaryItem.new
        value.suggestions << tmp
        @dictionary[key] = value
      else
        value = valueo
      end
      value.count += 1 if value.count < MAX_INT
    elsif @wordlist.count < MAX_INT
      value = DictionaryItem.new
      value.count += 1
      @dictionary[key] = value

      @maxlength = key.size if key.size > @maxlength
    end

    if value.count == 1
      @wordlist << key
      keyint = @wordlist.size - 1
      result = true

      edits(key, 0, Set.new).each do |delete|
        if value2 = @dictionary[delete]
          if value2.is_a?(Integer)
            tmp = value2
            di = DictionaryItem.new
            di.suggestions << tmp
            @dictionary[delete] = di
            add_lowest_distance(di, key, keyint, delete) unless di.suggestions.include?(keyint)
          elsif !value2.suggestions.include?(keyint)
          end
        else
          @dictionary[delete] = keyint
        end
      end
    end
    result
  end

  def add_lowest_distance(item, suggestion, suggestionint, delete)
    if @verbose < 2 && item.suggestions.count > 0 && @wordlist[item.suggestions[0]].size - delete.size > suggestion.size - delete.size
      item.suggestions.clear
    end
    if @verbose == 2 || item.suggestions.size == 0 || (@wordlist[item.suggestions[0]].size - delete.size >= suggestion.size - delete.size)
      item.suggestions << suggestionint
    end
  end

  def edits(word, edit_distance, deletes)
    edit_distance += 1
    if (word.size > 1)
      word.size.times do |i|
        delete = word.dup
        delete.slice!(i)
        if !deletes.include?(delete)
          deletes.add(delete)
          edits(delete, edit_distance, deletes) if edit_distance < @edit_distance_max
        end
      end
    end
    deletes
  end

  def sort(suggestions)
    if @verbose < 2
      suggestions.sort! {|x, y| -x.count <=> y.count}
    else
      suggestions.sort! {|x, y| (2 * x.distance <=> y.distance) - x.count <=> y.count}
    end

    @verbose == 0 ? suggestions[0..0] : suggestions
  end

  def damerau_levenshtein_distance(source, target)
    m = source.size
    n = target.size
    h = Array.new(m + 2) { Array.new(n + 2) { 0 } }
    inf = m + n

    h[0][0] = inf
    (0..m).each { |i| h[i + 1][1] = i; h[i + 1][0] = inf }
    (0..n).each { |j| h[1][j + 1] = j; h[0][j + 1] = inf }

    sd = {}
    (source + target).each_char do |letter|
      sd[letter] = 0 unless sd[letter]
    end

    (1..m).each do |i|
      db = 0
      (0..n).each do |j|
        i1 = sd[target[j - 1]]
        j1 = db
        if source[i - 1] == target[j - 1]
          h[i + 1][j + 1] = h[i][j]
          db = j
        else
          h[i + 1][j + 1] = [h[i][j], [h[i + 1][j], h[i][j + 1]].min].min + 1
        end

        first = h[i + 1][j + 1]
        second = h[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1)
        h[i + 1][j + 1] = [first, second].min
      end

      sd[source[i - 1]] = i
    end
    return h[m + 1][n + 1]
  end
end

