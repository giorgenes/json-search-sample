class CLI
    class UserQuit < RuntimeError
    end

    def initialize(input, output, databases)
        @in = input
        @out = output
        @databases = databases
    end

    def execute
        show_greeting

        begin
            loop do
                cmd = show_prompt('> ', %w[1 2])

                handle_cmd(cmd)
           end
        rescue UserQuit => e
        end
     
        @out.puts "Goodbye!"
    end

    private

    def handle_cmd(cmd)
        case cmd
        when '1'
            op = db_prompt
            term = show_prompt("Enter search term: ", %w[_id owner_id tags])
            value = show_prompt("Enter search value: ", nil)
            @out.puts "Searching users for #{term} with a value of #{value}"

            if value == 'notfound'
                @out.puts 'No documents found'
            end
        when '2'
            @out.puts "Search Users with: _id, name"
            @out.puts "Search Tickets with: _id, name"
        end
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

    # options = list of accepted answers or nil for any
    def show_prompt(prompt, options)
         begin
            loop do
                @out.print prompt
                cmd = @in.readline.strip

                if options.nil? || options.include?(cmd)
                    return cmd
                end

                if cmd == 'quit'
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

    def db_prompt
        options = (1..@databases.size).map(&:to_s)
        prompt = @databases.each_with_index.map{ |db, index| "#{index+1}) #{db.name}" }.join(" or ")

        show_prompt("Select #{prompt}: ", options)
    end
end