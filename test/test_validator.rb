require File.expand_path('../test_helper', __FILE__)

class TestValidator < Minitest::Test

  class MockReader
    def read(location)
      schema = {
        '$schema' => 'http://json-schema.org/draft-04/schema#',
        'type' => 'string',
        'minLength' => 2
      }

      JSON::Schema.new(schema, Addressable::URI.parse(location.to_s))
    end
  end

  def setup
    @original_reader = JSON::Validator.schema_reader
  end

  def teardown
    JSON::Validator.schema_reader = @original_reader
  end

  def test_default_schema_reader
    reader = JSON::Validator.schema_reader
    assert reader.accept_uri?(Addressable::URI.parse('http://example.com'))
    assert reader.accept_file?(Pathname.new('/etc/passwd'))
  end

  def test_set_default_schema_reader
    JSON::Validator.schema_reader = MockReader.new

    schema = { '$ref' => 'http://any.url/at/all' }
    assert_valid schema, 'abc'
    refute_valid schema, 'a'
  end

  def test_validate_with_reader
    reader = MockReader.new
    schema = { '$ref' => 'http://any.url/at/all' }
    assert_valid schema, 'abc', :schema_reader => reader
    refute_valid schema, 'a', :schema_reader => reader
  end

  def test_validate_list_with_reader
    reader = MockReader.new
    schema = { '$ref' => 'http://what.ever/schema' }
    assert_valid schema, ['abc', 'def'], :schema_reader => reader, :list => true
    refute_valid schema, ['abc', 'a'], :schema_reader => reader, :list => true
  end

end
