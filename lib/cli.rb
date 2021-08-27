class CLI
    def initialize(input, output)
        @in = input
        @out = output
    end

    def execute
        show_prompt

        begin
            loop do
                cmd = @in.readline.strip

                if cmd == 'quit'
                    @out.puts "Goodbye!"
                    return
                end

                handle_cmd(cmd)
            end
        rescue EOFError
            # You've reached the end. Handle it.
        end
    end

    private

    def handle_cmd(cmd)
        case cmd
        when '1'
            
        when '2'
            
        else
            @out.puts "Invalid command!"
        end
    end

    def show_prompt
        @out.puts "Welcome to Zendesk search"
        @out.puts "Type 'quit' to exist at any time. Press 'ENTER' to continue"
        @out.puts "\tSelect search options:"
        @out.puts "\t\t* Press 1 to search Zendesk"
        @out.puts "\t\t* Press 2 to view a list of searcheable fields"
        @out.puts "\t\t* Type 'quit' to exist"
    end
end