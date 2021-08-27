class CLI
    def initialize(input, output)
        @in = input
        @out = output
    end

    def execute
        show_greeting

        loop do
            cmd = show_prompt('> ', ['1', '2'])

            break if cmd.nil?

            handle_cmd(cmd)
        end

        @out.puts "Goodbye!"
    end

    private

    def handle_cmd(cmd)
        case cmd
        when '1'
            show_prompt("Select 1) Users or 2) Tickets: ")
        when '2'
            
        else
            @out.puts "Invalid command!"
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

    def show_prompt(prompt, options)
         begin
            loop do
                cmd = @in.readline.strip

                if options.include?(cmd)
                    return cmd
                end

                if cmd == 'quit'
                    return nil
                end

                @out.puts "Invalid command"
            end
        rescue EOFError
            # You've reached the end. Handle it.
        end


        nil
    end
end