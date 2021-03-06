require File.dirname(__FILE__) + '/../spec_helper'

basic_pdf_attribute={
  :dirname=>File.join(RAILS_ROOT, 'spec/test_dirs/indexed/basic'),
  :basename=>'basic',
  :complete_path=>File.join(RAILS_ROOT, '/spec/test_dirs/indexed/basic/basic.pdf'),
  :extname=>'.pdf',
  :ext_as_sym => :pdf,
  :filename=>'basic.pdf',
  :size => 9380
}

describe Document do
  before(:all) do
    # To be sure this file has the right content
    revert_changes!("spec/test_dirs/indexed/others/placeholder.txt","Absorption and Adsorption cooling machines!!!")
  end
  
  before(:each) do
    @valid_document=Document.new("spec/test_dirs/indexed/basic/basic.pdf")
  end

  it "should be an existing file" do
    lambda {Document.new("/patapouf.txt")}.should raise_error(Errno::ENOENT)
    lambda {@valid_document}.should_not raise_error
    lambda {Document.new("spec/test_dirs/not_indexed/Rakefile")}.should_not raise_error(Errno::ENOENT)
  end

  it "should belong to an indexed directory" do
    lambda {@valid_document}.should_not raise_error
    lambda {Document.new("spec/test_dirs/not_indexed/Rakefile")}.should raise_error(ArgumentError, "required document is not in indexed directory")
  end

  basic_pdf_attribute.each{|attribute,expected_value|
    it "should know its #{attribute}" do
      @valid_document.should respond_to(attribute)
      @basic_pdf=Document.new('spec/test_dirs/indexed/basic/basic.pdf')
      @basic_pdf.send(attribute).should == expected_value
    end
  }

  it "should know its content" do
    another_doc=Document.new("spec/test_dirs/indexed/basic/plain.txt")
    another_doc.content.should == "just a content test\nin a txt file"
  end
  
  #FIXME: Check if content has been cached before trying to display cached content. extension check is not enough
  #(e.g. unreadable pdf file)
  it "should know its cached content" do
    another_doc=Document.new("spec/test_dirs/indexed/basic/plain.txt")
    another_doc.cached.should == "just a content test\nin a txt file"
  end

  it "should keep content cached" do
    filename = "spec/test_dirs/indexed/others/placeholder.txt"
    content_before = "Absorption and Adsorption cooling machines!!!"
    some_doc=Document.new(filename)
    some_doc.content.should == content_before
    File.open(filename,'a'){|doc|
      doc.write("This line should not be indexed. It shouldn't be found in cache")
      }
    some_doc.content.should_not == content_before
    some_doc.cached.should == content_before
  end

  it "should know its highlighted cached content for a given query" do
    another_doc=Document.new("spec/test_dirs/indexed/basic/plain.txt")
    another_doc.highlighted_cache('a content test').should == "just a <<content>> <<test>>\nin a txt file"
  end

  it "should know its alias_path" do
    @valid_document.should respond_to(:alias_path)
    @valid_document.alias_path.starts_with?("http://picolena.devjavu.com/browser/trunk/lib/picolena/templates/spec/test_dirs/indexed").should be_true
  end
  
  it "should know its probably_unique_id" do
    @valid_document.should respond_to(:probably_unique_id)
    @valid_document.probably_unique_id.should =~/^[a-z]+$/
    @valid_document.probably_unique_id.size.should == Picolena::HashLength
  end
  
  it "should know its modification date" do
    @valid_document.pretty_date.class.should == String
    @valid_document.pretty_date.should =~/^\d{4}\-\d{2}\-\d{2}$/
  end
  
  it "should know its modification time and returns it in a pretty way" do
    @valid_document.should respond_to(:mtime)
    @valid_document.mtime.should be_kind_of(Integer)
    @valid_document.should respond_to(:pretty_mtime)
    @valid_document.pretty_mtime.class.should == String
    @valid_document.pretty_mtime.should =~/^\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}$/
  end
  
  it "should know if its content can be extracted" do
    @valid_document.should respond_to(:supported?)
    @valid_document.should be_supported
    Document.new("spec/test_dirs/indexed/others/ghjopdfg.xyz").should_not be_supported
  end

  it "should not be considered supported if binary" do
    Document.new("spec/test_dirs/indexed/others/BIN_FILE_WITHOUT_EXTENSION").should_not be_supported
  end


  
  it "should know its language when enough content is available" do
    Document.new("spec/test_dirs/indexed/lang/goethe").language.should == "de"
    Document.new("spec/test_dirs/indexed/lang/shakespeare").language.should == "en"
    Document.new("spec/test_dirs/indexed/lang/lorca").language.should == "es"
    Document.new("spec/test_dirs/indexed/lang/hugo").language.should == "fr"
  end if Picolena::UseLanguageRecognition

  it "should not try to guess language when file is too small" do
    Document.new("spec/test_dirs/indexed/basic/hello.rb").language.should be_nil
    Document.new("spec/test_dirs/indexed/README").language.should be_nil
  end if Picolena::UseLanguageRecognition

  it "should let finder specify its score" do
    @valid_document.should respond_to(:score)
    @valid_document.score.should be_nil
    @valid_document.score=25
    @valid_document.score.should == 25
  end

  it "should let finder specify its matching content" do
    @valid_document.should respond_to(:matching_content)
    @valid_document.matching_content.should be_nil
    @valid_document.matching_content=["thermal cooling", "heat driven cooling"]
    @valid_document.matching_content.should include("thermal cooling")
  end

  after(:all) do
    revert_changes!("spec/test_dirs/indexed/others/placeholder.txt","Absorption and Adsorption cooling machines!!!")
  end
end
