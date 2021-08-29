require "byebug"

class JsonDatabase
  attr_reader :name, :display_field, :indexes

  IndexItem = Struct.new(:value, :doc)

  def initialize(name:, display_field:)
    @name = name
    @display_field = display_field
    @docs = []

    @indexes = {}
  end

  def fields
    @indexes.keys
  end

  def load_json_file(path)
    add_docs(JSON.parse(File.read(path)))
  end

  def add_docs(docs)
    docs.each do |doc|
      add_doc(doc)
    end

    @indexes.each_pair do |field, index|
      index.sort! { |a, b| a.value <=> b.value }
    end
  end

  def add_doc(doc)
    doc.each_pair do |k, v|
      @indexes[k] ||= []
      if v.is_a?(Array)
        v.each do |e|
          @indexes[k].push(IndexItem.new(e.to_s, doc))
        end
      else
        @indexes[k].push(IndexItem.new(v.to_s, doc))
      end
    end

    @docs.push(doc)
  end

  def find_by(field, value)
    index = @indexes[field]
    raise "field not found" unless index

    pos = index.bsearch_index { |item| value <=> item.value }

    # not found
    if pos.nil?
      return []
    end

    lower = upper = pos

    # find the first item
    while lower >= 0 && index[lower].value == value
      lower -= 1
    end

    # find the last item
    while upper < index.size && index[upper].value == value
      upper += 1
    end

    index[(lower + 1)...upper].map(&:doc)
  end
end
