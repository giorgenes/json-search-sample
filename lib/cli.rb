class CLI
  class UserQuit < RuntimeError
  end

  def initialize(input: STDIN, output: STDOUT, databases: nil, relations: nil)
    @in = input
    @out = output
    @databases = databases
    @relations = relations
  end

  # Execute the CLI until the user quits or closes STDIN
  def execute
    show_greeting

    begin
      loop do
        cmd = show_prompt("> ", %w[1 2])

        handle_cmd(cmd)
      end
    rescue UserQuit => e
    rescue Interrupt
    end

    @out.puts "Goodbye!"
  end

  private

  # handles the top level commands (1 = Search, 2 = Show fields)
  def handle_cmd(cmd)
    case cmd
    when "1"
      db = db_prompt
      term = show_prompt("Enter search term: ", db.fields)
      value = show_prompt("Enter search value: ", nil)
      @out.puts "Searching users for #{term} with a value of #{value}"

      docs = db.find_by(term, value)

      if docs.empty?
        @out.puts "No documents found"
      else
        docs.each do |doc|
          print_doc(db, doc)
          @out.puts
        end
      end
    when "2"
      @databases.each do |db|
        @out.puts "Search #{db.name} with: #{db.fields.join(", ")}"
      end
    end
  end

  def db_by_name(name)
    @databases.find { |db| db.name == name }
  end

  # Given a doc, find the associated records on the other database and print it
  def find_and_print_related(db, doc, max_key_size)
    rel = @relations[db.name]
    return unless rel

    key = rel.keys.first
    return unless key

    dbname, field = rel.values.first.split(".")
    return unless dbname && field

    related_db = db_by_name(dbname)
    return unless related_db

    related_docs = related_db.find_by(field, doc[key])

    if related_docs.any?
      related_docs.each_with_index do |related_doc, index|
        v = related_doc[related_db.display_field]
        if index == 0
          @out.puts("%-*s = - #{v}" % [max_key_size, related_db.name])
        else
          @out.puts("%-*s   - #{v}" % [max_key_size, ""])
        end
      end
    end
  end

  def print_doc(db, doc)
    max_key_size = doc.keys.map(&:size).max
    doc.each_pair do |k, v|
      @out.puts("%-*s = #{v}" % [max_key_size, k])
    end

    find_and_print_related(db, doc, max_key_size)
  end

  def show_greeting
    @out.puts "Welcome to Zendesk search"
    @out.puts "Type 'quit' to exit at any time. Press 'ENTER' to continue"
    @out.puts
    @out.puts "\tSelect search options:"
    @out.puts "\t\t* Press 1 to search Zendesk"
    @out.puts "\t\t* Press 2 to view a list of searcheable fields"
    @out.puts "\t\t* Type 'quit' to exist"
    @out.puts
  end

  # Show the prompt, read the input and check for the accepted options
  # options = list of accepted answers or nil for any
  def show_prompt(prompt, options)
    begin
      loop do
        @out.print prompt
        cmd = @in.readline.strip

        if options.nil? || options.include?(cmd)
          return cmd
        end

        if cmd == "quit"
          raise UserQuit.new
        end

        @out.puts "Invalid command"
      end
    rescue EOFError
      # You've reached the end. Handle it.
    end

    raise UserQuit.new
  end

  def db_options
    (1..@databases.size).map(&:to_s)
  end

  # Show the list of databases to search with the numbers
  def db_prompt
    options = (1..@databases.size).map(&:to_s)
    prompt = @databases.each_with_index.map { |db, index| "#{index + 1}) #{db.name}" }.join(" or ")

    op = show_prompt("Select #{prompt}: ", options)

    @databases[op.to_i - 1]
  end
end
