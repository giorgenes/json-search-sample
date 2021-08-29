class JsonDatabase
  attr_reader :name, :display_field

  def initialize(name:, display_field:)
    @name = name
    @display_field = display_field
    @docs = []
  end

  def add_docs(docs)
    @docs = docs
  end

  def find_by(field, value)
    @docs.select do |doc|
      field_value = doc[field]

      if field_value.is_a?(Array)
        field_value.include?(value)
      else
        doc[field].to_s == value.to_s
      end
    end
  end
end
