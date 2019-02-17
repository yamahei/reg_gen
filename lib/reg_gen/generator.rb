require 'time'

module RegGen
    class Generator

        DEFAULT_MULTILINE = false
        DEFAULT_INFINITY_LEN = 100
    
        def initialize option={}
            @rand = Random.new(Time.now.to_i)
            set_options option
        end

        def gen tree
            return root_gen tree
        end

        private

        def set_options option
            @multiline = option[:multiline] || DEFAULT_MULTILINE
            @infinity_len = option[:infinity_len] || DEFAULT_INFINITY_LEN
        end

        def root_gen node
            case node[:type]
            when :group  then group_gen node
            when :item   then item_gen node
            when :class  then class_gen node
            when :repeat then repeat_gen node
            when :string then
                str = node[:value]
                (str == :dot )? any_str.split("").shuffle[0] : str
            else raise "unknown type: '#{node[:type]}'"
            end
        end

        def group_gen node
            raise "node isnot group: '#{node[:type]}'" if node[:type] != :group
            root_gen node[:items].shuffle[0]
        end

        def item_gen node
            raise "node isnot item: '#{node[:type]}'" if node[:type] != :item
            node[:values].map{|item| root_gen item }.join
        end

        def class_gen node
            raise "node isnot class: '#{node[:type]}'" if node[:type] != :class
            inc, exc, flag = [], [], !node[:exclude]
            range_gen node, inc, exc, flag

            chars = []
            if !inc.empty? then
                inc.each{|r| chars += (r[:from]..r[:to]).to_a }
            else
                chars = any_str.split ""
            end
            if !exc.empty? then
                exc.each{|r| chars -= (r[:from]..r[:to]).to_a }
            end

            raise 'no char match class.' if chars.empty?
            chars.shuffle[0]
        end

        def range_gen node, inc, exc, _flag
            raise "node isnot class: '#{node[:type]}'" if node[:type] != :class
            flag = !node[:exclude] ? _flag : _flag
            node[:items].each{|item|
                if item[:type] == :class then
                    range_gen item, inc, exc, flag
                elsif item[:type] == :range then
                    if flag then
                        inc << item
                    else
                        exc << item
                    end
                else
                    raise "unknown type: '#{node[:type]}'"
                end
            }
        end

        def repeat_gen node
            raise "node isnot repeat: '#{node[:type]}'" if node[:type] != :repeat
            from, to = node[:from], node[:to]
            to = @infinity_len if to == Float::INFINITY
            times = @rand.rand(from..to)
            Array.new(times).map{ root_gen node[:item] }.join
        end

        def any_str
            return ((@multiline ? "\n" * 10 : '').split('') + [
                '0123456789!"#$%&\'()-=^~\|[]{}:*;+\_/?.>,<',
                'abcdefghijklmnopqrstuvwxyz',
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                'いろはにほへとちりぬるをわかよたれそつねならむ',
                'うゐのおくやまけふこえてあさきゆめみしゑひもせす',
                'イロハニホヘトチリヌルヲワカヨタレソツネナラム',
                'ウヰノオクヤマケフコエテアサキユメミシヱヒモセス',
                'ｲﾛﾊﾆﾎﾍﾄﾁﾘﾇﾙｦﾜｶﾖﾀﾚｿﾂﾈﾅﾗﾑｳｲﾉｵｸﾔﾏｹﾌｺｴﾃｱｻｷﾕﾒﾐｼｴﾋﾓｾｽ',
                '０１２３４５６７８９！＂＃＄％＆＼＇（）－＝＾～＼',
                '｜［］｛｝：＊；＋＼＿／？．＞，＜',
                'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ',
                'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ',
                '右雨円王音下火学気九玉金空月見',
                '五口左子四糸字耳車手出女上人水',
                '正生青夕石赤千川早草足大男中天',
                '田土二日入年白八百文木本名目立',
                '力林',
            ]).join.dup
        end


    end#class
end#module
  