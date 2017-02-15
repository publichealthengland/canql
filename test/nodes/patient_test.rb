# frozen_string_literal: true
require 'test_helper'

# case host patient tests
class PatientTest < Minitest::Test
  def test_should_filter_by_male_gender
    parser = Canql::Parser.new('all male cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => '1' }, parser.meta_data['patient.sex'])
  end

  def test_should_filter_by_female_gender
    parser = Canql::Parser.new('all female cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => '2' }, parser.meta_data['patient.sex'])
  end

  def test_should_filter_by_stillbirth_outcome
    parser = Canql::Parser.new('all stillborn cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => 'stillborn' }, parser.meta_data['patient.outcome'])
  end

  def test_should_filter_by_livebirth_outcome
    parser = Canql::Parser.new('all liveborn cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => 'liveborn' }, parser.meta_data['patient.outcome'])
  end

  def test_should_filter_by_miscarriage_outcome
    parser = Canql::Parser.new('all miscarried cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => 'miscarried' }, parser.meta_data['patient.outcome'])
  end

  def test_should_filter_by_top_outcome
    parser = Canql::Parser.new('all terminated cases')
    assert parser.valid?
    assert_equal({ Canql::EQUALS => 'terminated' }, parser.meta_data['patient.outcome'])
  end

  def test_should_filter_on_specific_edd
    parser = Canql::Parser.new('all cases expected on 20/06/2015')
    assert parser.valid?
    assert_equal({ Canql::LIMITS => ['2015-06-20', '2015-06-20'] },
                 parser.meta_data['patient.expecteddeliverydate'])
  end

  def test_should_filter_on_edd_range
    parser = Canql::Parser.new('all cases expected between 20/06/2015 and 25/06/2015')
    assert parser.valid?
    assert_equal({ Canql::LIMITS => ['2015-06-20', '2015-06-25'] },
                 parser.meta_data['patient.expecteddeliverydate'])
  end

  def test_should_filter_by_missing_fields
    parser = Canql::Parser.new('all cases with missing postcode, date of birth')
    parser_v2 = Canql::Parser.new('all cases with missing postcode and date of birth')
    assert parser.valid?
    assert_array_includes parser.meta_data['patient.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
    assert_array_includes parser_v2.meta_data['patient.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
  end

  def test_should_filter_by_missing_place_of_delivery
    parser = Canql::Parser.new('all cases with missing place of delivery')
    assert parser.valid?
    assert_array_includes parser.meta_data['patient.fields_missing'][Canql::EQUALS],
                          %w(placeofdelivery)
  end

  def test_should_filter_by_populated_fields
    parser = Canql::Parser.new('all cases with fields postcode, date of birth')
    parser_v2 = Canql::Parser.new('all cases with tests and fields postcode and date of birth')
    assert parser.valid?
    assert_array_includes parser.meta_data['patient.fields_populated'][Canql::EQUALS],
                          %w(postcode birthdate)
    assert_array_includes parser_v2.meta_data['patient.fields_populated'][Canql::EQUALS],
                          %w(postcode birthdate)
  end

  def test_should_filter_by_missing_mother_fields
    parser = Canql::Parser.new('all cases with mother with missing postcode, date of birth')
    parser_v2 = Canql::Parser.new('all cases with mother with missing postcode and date of birth')
    assert parser.valid?
    assert_array_includes parser.meta_data['mother.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
    assert_array_includes parser_v2.meta_data['mother.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
  end

  def test_should_filter_by_missing_mother_fields_v2
    parser = Canql::Parser.new('all cases with mother missing postcode, date of birth')
    parser_v2 = Canql::Parser.new('all cases with mother missing postcode and date of birth')
    assert parser.valid?
    assert_array_includes parser.meta_data['mother.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
    assert_array_includes parser_v2.meta_data['mother.fields_missing'][Canql::EQUALS],
                          %w(postcode birthdate)
  end

  def test_should_filter_by_populated_mother_fields
    parser = Canql::Parser.new('all cases with mother with fields postcode, date of birth')
    parser_v2 = Canql::Parser.new('all cases with mother with fields postcode and date of birth')
    assert parser.valid?
    assert_array_includes parser.meta_data['mother.fields_populated'][Canql::EQUALS],
                          %w(postcode birthdate)
    assert_array_includes parser_v2.meta_data['mother.fields_populated'][Canql::EQUALS],
                          %w(postcode birthdate)
  end

  def test_dob_alias_valid
    query1 = 'all babies with missing date of birth'
    parser = Canql::Parser.new(query1)
    message = "That's a reference test for 'dob' alias, if this fails,\
               something is wrong!!!"
    assert(parser.valid?, message)

    query1 = 'all babies with missing dob'
    parser = Canql::Parser.new(query1)
    message = '\'dob\' should be a valid alias for \'date of birth\'!'
    assert(parser.valid?, message)
  end

  def test_dob_alias_simple_query
    query1 = 'all babies with missing postcode, date of birth'
    query2 = 'all babies with missing postcode, dob'
    parser1 = Canql::Parser.new(query1)
    parser2 = Canql::Parser.new(query2)
    message = '\'dob\' doesn\'t work as an alias of \'date of birth\'!'
    assert_equal(parser1.meta_data, parser2.meta_data, message)

    query1 = 'all babies with missing postcode, date of birth'
    query2 = 'all babies with missing postcode, pac'
    parser1 = Canql::Parser.new(query1)
    parser2 = Canql::Parser.new(query2)
    message = "'pac' appears to be working in the same way as 'dob' does,\
               and 'pac' wasn't included in the grammar config!"
    assert(parser1.meta_data != parser2.meta_data, message)
  end

  def test_dob_alias_complicated_query
    query1 = 'first 27 male liveborn thames cases \
      expected between 20/06/2015 and 25/06/2015 \
      and born on 22/06/2015 and that died on 01/12/2015 \
      with prenatal anomalies \
      and postnatal tests and missing postcode and date of birth \
      and wait action and unprocessed paediatric records \
      and mother born between 01/10/1990 and 10/01/1999 \
      and who died on 01/01/2016 \
      with fields postcode and nhs number'
    query2 = 'first 27 male liveborn thames cases \
      expected between 20/06/2015 and 25/06/2015 \
      and born on 22/06/2015 and that died on 01/12/2015 \
      with prenatal anomalies \
      and postnatal tests and missing postcode and dob \
      and wait action and unprocessed paediatric records \
      and mother born between 01/10/1990 and 10/01/1999 \
      and who died on 01/01/2016 \
      with fields postcode and nhs number'
    parser1 = Canql::Parser.new(query1)
    parser2 = Canql::Parser.new(query2)
    message = "'dob' doesn't work as an alias of 'date of birth'\
      in a complicated query!"
    assert_equal(parser1.meta_data, parser2.meta_data, message)
  end
end
