require "reg_gen/version"

class RegGen
	# TODO:
	# 	Escape symbol "\" may not function properly

  attr_reader :tree

  def initialize pattern
    
		@stack = []
    @tokens = if pattern.instance_of? Regexp then
      pattern.inspect.gsub(/(^\/|\/$)/, "")
    else
      pattern
    end
		@tree = parse_tree
	end
	
	def gen
		return _gen @tree, ""
	end
	
	private ###########
	
	def _gen node, result

		if node.instance_of? Array then
			node.each{|_node|
				result = _gen _node, result
			}
			return result

		elsif node.instance_of? Hash then

			case node[:type]
			when :block, :list then
				_node = node[:values].shuffle[0]
				return _gen _node, result

			when :repeat then
				__count, _count = node[:count], 0
				if __count.instance_of? Fixnum then
					_count = __count
				elsif __count.instance_of? Range then
					_count = __count.to_a.shuffle[0]
				else
					raise "unknown repeat counter: #{node[:count]}"
				end
				Array.new(_count).each{|e| result = _gen node[:value], result }
				return result

			when :string then
				return result + node[:value]

			when :range then
				_value = (node[:from]..node[:to]).to_a.shuffle[0]
				return result + _value

			else
				raise "unknown node type: #{node[:type]}"
			end
		end
	end
	
	def parse_tree
		tree = []
		loop do
			token, @tokens = @tokens[0], @tokens[1..-1]
			case token
			when "(" then #block
				@stack << token
				tree << parse_block
			when "[" then #list
				@stack << token
				tree << parse_list
			when "{" then #repeat
				@stack << token
				tree << parse_repeat(tree.pop)
			else
				tree << { type: :string, value: token }
			end
			if @tokens.empty? then
				raise "stack not empty: #{@stack}" if @stack.length > 0
				return tree 
			end
		end
	end

	def parse_block # parse after (
		#puts "parse_block"
		#p [@tokens, @stack]
		block, item, escape = { type: :block, values: [] }, [], false
		loop do
			token, @tokens = @tokens[0], @tokens[1..-1]
			case token
			when ")" then #block end
				if escape then
					escape = false
					item << { type: :string, value: token }
				else
					raise "expect '('." if @stack.pop != "("
					block[:values] << item
					return block
				end
			when "(" then #block
				if escape then
					escape = false
					item << { type: :string, value: token }
				else
					@stack << token
					item << parse_block
				end
			when "[" then #list
				if escape then
					escape = false
					item << { type: :string, value: token }
				else
					@stack << token
					item << parse_list
				end
			when "{" then #repeat
				if escape then
					escape = false
					item << { type: :string, value: token }
				else
					@stack << token
					item << parse_repeat(item.pop)
				end
			when "|" then #end item
				if escape then
					escape = false
					item << { type: :string, value: token }
				else
					block[:values] << item
					item = []
				end
			when "\\" then
				escape = true
			else
				item << { type: :string, value: token }
			end
		end
	end

	def parse_list # parse after [
		#puts "parse_list"
		#p [@tokens, @stack]
		list, item, range, escape = {:type=>:list,:values=>[]}, [], false, false
		loop do

			token, @tokens = @tokens[0], @tokens[1..-1]
			
			if range then
				from, to = item.pop, token
				while item.length > 0 do
					list[:values] << { type: :string, value: item.shift }
				end
				list[:values] << { type: :range, from: from, to: to }
				range = false
				next
			end

			case token
			when "]" then #list end
				if escape then
					escape = false
					item << token
				else
					raise "expect '['." if @stack.pop != "["
					while item.length > 0 do
						list[:values] << { type: :string, value: item.shift }
					end
					escape = false
					return list
				end
			when "-" then #range
				if escape then
					escape = false
					item << token
				else
					range = true
				end
			when "\\" then #escape
				escape = true
			else
				item << token
			end
			
		end
	end


	def parse_repeat node # parse after {
		#puts "parse_repeat"
		#p [@tokens, @stack, node]
		repeat = {:type=>:repeat, :value=>node, :count=>0}
		item = ""
		loop do
			token, @tokens = @tokens[0], @tokens[1..-1]
			break if token == "}"
			item += token
		end
		fromto = item.split(',').each(&:strip).map(&:to_i)
		if fromto.length == 1 then
			repeat[:count] = fromto.shift
		else
			from, to = fromto.shift, fromto.shift
			repeat[:count] = from..to
		end
		raise "expect '{'." if @stack.pop != "{"
		return repeat
	end

end

__END__

irb
require './string_generator.rb'
g = StringGenerator.new "(\\|C\\||\\[D\\]|\\{B\\}|\\(A\\)){3}"
[
	{:type=>:repeat, :value=>
		{:type=>:block, :values=>[
			[
				{:type=>:string, :value=>"|"}, 
				{:type=>:string, :value=>"C"}, 
				{:type=>:string, :value=>"|"}
			], [
				{:type=>:string, :value=>"["}, 
				{:type=>:string, :value=>"D"}, 
				{:type=>:string, :value=>"]"}, 
				{:type=>:string, :value=>"|"}, 
				{:type=>:string, :value=>"{"}, 
				{:type=>:string, :value=>"B"}, 
				{:type=>:string, :value=>"}"}, 
				{:type=>:string, :value=>"|"}, 
				{:type=>:string, :value=>"("}, 
				{:type=>:string, :value=>"A"}, 
				{:type=>:string, :value=>")"}
			]
		]}
	, :count=>3}
]


irb
require './string_generator.rb'
g = StringGenerator.new "x([a-z]{3}|[0-9]{3}){2}x"
[
	{:type=>:string, :value=>"x"}, 
	{:type=>:repeat, :value=>
		{:type=>:block, :values=>[
			[
				{:type=>:repeat, :value=>
					{:type=>:list, :values=>[
						{:type=>:range, :from=>"a", :to=>"z"}
					]}
				, :count=>3}
			], [
				{:type=>:repeat, :value=>
					{:type=>:list, :values=>[
						{:type=>:range, :from=>"0", :to=>"9"}
					]}
				, :count=>3}
			]
		]}
	, :count=>2}, 
	{:type=>:string, :value=>"x"}
]



irb
require './string_generator.rb'
g = StringGenerator.new "x[_\\-a-z]{5}x"
	[
		{:type=>:string, :value=>"x"}, 
		{:type=>:repeat, :value=>{:type=>:list, :values=>[
			{:type=>:string, :value=>"_"}, 
			{:type=>:string, :value=>"-"}, 
			{:type=>:range, :from=>"a", :to=>"z"}
		]}, :count=>5}, 
		{:type=>:string, :value=>"x"}
	]
g.gen
=> "x_j_u_x"

