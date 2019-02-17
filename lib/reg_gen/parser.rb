module RegGen
    class Parser

        attr_reader :tree

        def initialize _pattern
            pattern = _pattern.inspect
            @tokens = to_tokens pattern
            @tree = to_tree
        end
    
        private
    
        def to_tokens _pattern
            pattern = _pattern.dup
            tokens = []
            loop do
                match = pattern.match(/^(\\?.)(.*)$/) || []
                head, pattern = match[1], match[2]
                break if !head
    
                token, hasY = head[-1], (head.length==2)
                if hasY then
                    c = meta_chars[token.to_sym]
                    if c then
                        pattern = c + pattern
                    else
                        tokens << token
                    end
                else
                    block = meta_block[token.to_sym]
                    if !block then
                        tokens << token 
                    else
                        tokens << block[:token] if block[:token]
                        pattern = (block[:add] + pattern) if block[:add]
                    end
                end
            end
            #remove ignore char
            tokens.shift if tokens.first == '/'
            tokens.shift if tokens.first == :hat
            tokens.pop if tokens.last == '/'
            tokens.pop if tokens.last == '$'

            return tokens
        end

        def to_tree
            @stack = [:group_open]
            return parse_group @tokens.dup
        end
    
        def exit_expect token
            _token = @stack.pop
            raise "unexpected token '#{_token}', expect is #{token}." if token != _token
        end
    
        def parse_group tokens
    
            group = { type: :group, items: [] }
            get_new_item = Proc.new {{ type: :item, values: [] }}
            get_new_string = Proc.new {|s| { type: :string, value: s }}
            item = get_new_item.call
            loop do
                token = tokens.shift
                if !token || token == :group_close then
                    group[:items] << item
                    exit_expect :group_open
                    return group 
                end
    
                valid_token = token.instance_of? String ||
                    ([:pipe, :minus, :comma, :hat].include? token)
                if valid_token then
                    str = meta_block_str[token] || token
                    item[:values] << get_new_string.call(str)
                    next
                elsif token == :dot then
                    item[:values] << get_new_string.call(token)
                    next
                end
    
                case token
                when :class_open then
                    @stack << token
                    item[:values] << parse_class(tokens)
                when :group_open then
                    @stack << token
                    item[:values] << parse_group(tokens)
                when :repeat_open then
                    @stack << token
                    item[:values] << parse_repeat(tokens, item[:values].pop)
                when :pipe then
                    group[:items] << item
                    item = get_new_item.call
                when :minus then
                    item[:values] << get_new_string.call('-')
                when :comma then
                    item[:values] << get_new_string.call(',')
                when :hat then
                    item[:values] << get_new_string.call('^')
                else
                    raise "invalid token in group: #{token}."
                end
    
            end
        end
    
        def parse_class tokens
    
            klass = { type: :class, exclude: false, items: [] }
            get_new_range = Proc.new {{ type: :range, from: nil, to: nil }}
            if tokens[0] == :hat then
                # ATTENTION: excludeは親classを反転する模様
                # ↑違うかもよくわからん
                klass[:exclude] = true
                drop = tokens.shift
            end
    
            loop do
                token, after = tokens.shift, tokens[0]
                if token == :class_close then
                    exit_expect :class_open
                    return klass 
                end
                if token == :class_open then
                    @stack << token
                    klass[:items] << parse_class(tokens)
                    next
                end
    
                if after != :minus then
                    range = get_new_range.call
                    range[:from] = range[:to] = token
                    klass[:items] << range
                    next
                end
    
                drop, after = tokens.shift, tokens.shift
                valid_token = after.instance_of? String ||
                    ([:pipe, :minus, :comma, :hat].include? after)
                if !valid_token then
                    raise "unexpected range to: '#{token}-#{after}'"
                end
                range = get_new_range.call
                range[:from] = token
                range[:to] = meta_block_str[after] || after
                
                if range[:to] < range[:from] then
                    raise "invalid range: '#{range[:from]}-#{range[:to]}'"
                else
                    klass[:items] << range
                end
    
            end
        end
    
        def parse_repeat tokens, item

            from, to = nil, nil
            repeat = { type: :repeat, from: from, to: to, item: item }
            tmp_stack, comma_len = [], 0
    
            loop do
                token = tokens.shift

                if token && token != :repeat_close then
                    if token != :comma && token !~ /^\d{1}$/ then
                        raise "unexpected token in repeat: '#{token}'.'"
                    else
                        comma_len += 1 if token == :comma 
                        raise "too much comma in repeat.'" if comma_len > 1
                        tmp_stack << token
                        next
                    end
                else
                    break
                end
            end
    
            index = tmp_stack.index(:comma)
            if !index then
                num = tmp_stack.join.to_i
                from, to = num, num
            else
                from = tmp_stack[0...index].join.to_i
                _num = tmp_stack[(index+1)..-1].join
                to = _num.empty? ? Float::INFINITY : _num.to_i
            end
    
            repeat[:from], repeat[:to] = from, to
            exit_expect :repeat_open
            return repeat
    
        end
       
        def meta_chars
            return {
                't': "\t", 'n': "\n", 'r': "\r", 's': '[ \t\r\n]', 'S': '[^ \t\r\n]',
                'w': '[a-zA-Z0-9_]', 'W': '[^a-zA-Z0-9_]', 'd': '[0-9]', 'D': '[^0-9]',
                'h': '[0-9a-fA-F]', 'H': '[^0-9a-fA-F]'
            }
        end
    
        def meta_block
            return {
                '[': { token: :class_open }, ']': { token: :class_close },
                '(': { token: :group_open }, ')': { token: :group_close },
                '{': { token: :repeat_open }, '}': { token: :repeat_close },
                '?': { add: '{0,1}' }, '+': { add: '{1,}' }, '*': { add: '{0,}' },
                '|': { token: :pipe }, '-': { token: :minus },
                '.': { token: :dot }, ',': { token: :comma }, '^': { token: :hat },
            }
        end
    
        def meta_block_str
            return {
                class_open: '[', class_close: ']',
                group_open: '(', group_close: ')',
                repeat_open: '{', repeat_close: '}',
                pipe: '|', minus: '-', dot: '.', comma: ',', hat: '^',
            }
        end
    
    end#class
end#module
  