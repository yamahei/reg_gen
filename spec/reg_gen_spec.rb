RSpec.describe RegGen do
  it "has a version number" do
    expect(RegGen::VERSION).not_to be nil
  end

  it "static char" do
    #TODO: / escape
    pattern = "abc"
    regexp  = /^abc$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "block" do
    #TODO: / escape
    pattern = "(abc|def|ghi)"
    regexp  = /^(abc|def|ghi)$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end
  
  it "static list" do
    #TODO: / escape
    pattern = "[abcd]"
    regexp  = /^[abcd]$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end
  
  it "range list" do
    #TODO: / escape
    pattern = "[a-z]"
    regexp  = /^[a-z]$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "mixed list with escape" do
    #TODO: / escape
    pattern = "[.@_\\-0-9a-z]"
    regexp  = /^[.@_\-0-9a-z]$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "repeat fixed" do
    #TODO: / escape
    pattern = "A{3}"
    regexp  = /^A{3}$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "repeat range" do
    #TODO: / escape
    pattern = "B{3,6}"
    regexp  = /^B{3,6}$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "mixed" do
    #TODO: / escape
    pattern = "(Go{2,8}gle|[NMBC]intendo), (inc|ltd)."
    regexp  = /^(Go{2,8}gle|[NMBC]intendo), (inc|ltd)\.$/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  end

  it "ex: mail address" do
    #TODO: / escape
    pattern = "[a-z][._a-z0-9]{5,8}[a-z0-9]@(hoge|fuga).(co.jp|jp|com)"
    regexp  = /[a-z][._a-z0-9]{5,8}[a-z0-9]@(hoge|fuga)\.(co\.jp|jp|com)/
    g = RegGen.new pattern; p g.tree
    100.times do
      str = g.gen
      expect(str).to match(regexp)
    end
  
  end
end
