RSpec.describe 'RegGen' do

  before do
    @tree = { :type=>:group, :items=>[
        { :type=>:item, :values=>[
            {:type=>:string, :value=>"a"},
            {:type=>:string, :value=>"b"},
            {:type=>:string, :value=>"c"},
        ]}
    ]}
  end

  it "has a version number" do
    expect(RegGen::VERSION).not_to be nil
  end

  describe 'class and options' do

    it "parser" do
      regexp  = /^abc$/
      tree = RegGen::Parser.new(regexp).tree
      expect(tree).to match(@tree)
    end
  
    it "generator" do
      regexp  = /^abc$/
      generator = RegGen::Generator.new()
      100.times do
        str = generator.gen @tree
        expect(str).to match(regexp)
      end
    end
  
    it "infinity_len" do
      regexp  = /.*/
      tree = RegGen::Parser.new(regexp).tree
      generator = RegGen::Generator.new({infinity_len: 10})
  
      100.times do
        str = generator.gen tree
        expect(str.length).to be <= 10
      end
    end
  
    it "multiline=false(default)" do
      regexp  = /.{10,}/
      tree = RegGen::Parser.new(regexp).tree
      generator = RegGen::Generator.new({multiline: false})
      f = false
  
      100.times do
        str = generator.gen tree
        f ||= !!str.match(/\n/)
      end
      expect(f).to eq false
    end
  
    it "multiline=true" do
      regexp  = /.{10,}/
      tree = RegGen::Parser.new(regexp).tree
      generator = RegGen::Generator.new({multiline: true})
      f = false
  
      100.times do
        str = generator.gen tree
        f ||= !!str.match(/\n/)
      end
      expect(f).to eq true
    end
  
  end

  describe 'regexp patterns' do

    context 'chars' do

      it "static char" do
        regexp  = /^abc$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "any char" do
        regexp  = /^.*$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end    

    end

    context 'group' do

      it "root group" do
        regexp  = /a|b|c/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
    
      it "group" do
        regexp  = /(a|b|c)/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
    
      it "group with escaped pipe" do
        regexp  = /(a\|b|c)/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
        
    end

    context 'class' do

      it "static class" do
        regexp  = /^[abcd]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
        
      it "class with range" do
        regexp  = /^[0-9a-f]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
        
      it "exclude class" do
        regexp  = /^[^0-9a-f]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
        
      it "class with meta char" do
        regexp  = /^[\d]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
        
      it "class with escaped char" do
        regexp  = /^[\-\[\]]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "class in class" do
        regexp  = /^[[a-z][0-9]]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
      
      it "class in class with exclude" do
        #I do not really understand this specification..
        regexp  = /^[[^a-z][^0-9]]$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end
      
    end

    context 'repeat' do

      it "repeat static char with ?*+" do
        regexp  = /^a?b*c+$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "repeat static char with {}" do
        regexp  = /a{1}b{2,}c{,3}d{4,5}/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "repeat block" do
        regexp  = /(a|b|c){5}/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "repeat class" do
        regexp  = /[0-9a-f]{4}/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

    end

    context 'mixed' do

      it "cell phone" do
        regexp  = /0[7-9]0(-\d{4}){2}/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "mail address" do
        regexp  = /^\w+([\w\.\-])*@([\w\-])+([\w\.\-]+)+$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

      it "url" do
        regexp  = /^https?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+$/
        tree = RegGen::Parser.new(regexp).tree
        generator = RegGen::Generator.new
    
        100.times do
          str = generator.gen tree
          expect(str).to match(regexp)
        end
      end

    end
  end

end
