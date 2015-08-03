require 'minitest/autorun'
require_relative '../lib/symspell'

class SymSpellTest < Minitest::Test
  def setup
    @edit_distance_max = 2
    @verbose = 0
  end

  def subject
    @subject ||= SymSpell.new(@edit_distance_max, @verbose).tap do |subject|
      words = %w(joe mark john peter mary andrew imogen)
      subject.create_dictionary words
    end
  end
  def test_lookup_correctly_spelled_word
    assert_equal 'andrew', subject.lookup('andrew').first.term
  end

  def test_lookup_misspelt_word
    assert_equal 'andrew', subject.lookup('andre').first.term
  end

  def test_lookup_fails_to_find_match
    assert_equal nil, subject.lookup('amigon').first
  end

  def test_lookup_finds_match_after_turning_up_edit_distance
    @edit_distance_max = 3
    assert_equal ['imogen'], subject.lookup('amigon').map(&:term)
  end

  def test_lookup_returns_multiple_suggestions
    @edit_distance_max = 2
    @verbose = 2
    assert_equal ['joe', 'john'], subject.lookup('jo').map(&:term)
  end
end

