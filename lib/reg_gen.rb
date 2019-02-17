require File.expand_path("../reg_gen/version.rb", __FILE__)
require File.expand_path("../reg_gen/parser.rb", __FILE__)
require File.expand_path("../reg_gen/generator.rb", __FILE__)
# require 'reg_gen/version'
# require 'reg_gen/parser'
# require 'reg_gen/generator'

module RegGen

    def self.parse pattern
        self::Parser.new(pattern).tree
    end

    def self.generate tree, opt
        self::Generator.new(opt).gen(tree)
    end

    def self.get pattern, opt={}
        self.generate(self.parse(pattern), opt)
    end

end

__END__

# :group ( ) グループ
# :class [ ] 文字クラス(character class) とは角括弧 [ と ] で囲まれ、1個以上の文字を列挙したもので、 いずれかの1文字にマッチします。 
# :repeat { } 繰り返し {n} ちょうどn回(nは数字)　{n,} n回以上(nは数字)　{,m} m回以下(mは数字)　{n,m} n回以上m回以下(n,mは数字)
# :loop_single
# :loop_ques ? 繰り返し ? 0回もしくは1回　　最小量指定子(reluctant quantifier)
# :loop_plus + 繰り返し + 1回以上
# :loop_aste * 繰り返し * 0回以上


# :loop_dot . 繰り返し
# |

# :escape \
# :meta
# :meta_tab  \t 
# :meta_nl   \n 
# :meta_cr   \r 
# :meta_word      \w 単語構成文字 [a-zA-Z0-9_]
# :meta_un_word   \W 非単語構成文字 [^a-zA-Z0-9_]
# :meta_space     \s 空白文字 [ \t\r\n\f\v]
# :meta_un_space  \S 非空白文字 [^ \t\r\n\f\v]
# :meta_number    \d 10進数字 [0-9]
# :meta_un_number \D 非10進数字 [^0-9]
# :meta_hex       \h 16進数字 [0-9a-fA-F]
# :meta_un_hex    \H 非16進数字 [^0-9a-fA-F]
