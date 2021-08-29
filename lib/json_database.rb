class JsonDatabase
  attr_reader :name, :display_field

  def initialize(name:, display_field:)
    @name = name
    @display_field = display_field
  end
end
