require File.dirname(__FILE__) + '/../spec_helper'

basic_pdf_attribute={
  :size=>9380,
  :dirname=>'spec/test_dirs/indexed/basic',
  :basename=>'basic',
  :complete_path=>'spec/test_dirs/indexed/basic/basic.pdf',
  :extname=>'.pdf',
  :filename=>'basic.pdf'
}

describe Document do
  before(:each) do
    @valid_random_doc=Document.find(:random) rescue Document.new("spec/test_dirs/indexed/basic/basic.pdf")
  end
  
  it "should be an existing file" do
    lambda {Document.new("/patapouf.txt")}.should raise_error(Errno::ENOENT)
    lambda {@valid_random_doc}.should_not raise_error
    lambda {Document.new("spec/test_dirs/not_indexed/Rakefile")}.should_not raise_error(Errno::ENOENT)
  end
  
  it "should belong to an indexed directory" do
    lambda {@valid_random_doc}.should_not raise_error
    lambda {Document.new("spec/test_dirs/not_indexed/Rakefile")}.should raise_error(ArgumentError, "required document is not in indexed directory")
  end
  
#  it "should be able to pick a random valid document" do
#    lambda {Document.find(:random)}.should_not raise_error
#  end
  
  basic_pdf_attribute.each{|attribute,expected_value|
    it "should know its #{attribute}" do
      @valid_random_doc.should respond_to(attribute)
      @basic_pdf=Document.new('spec/test_dirs/indexed/basic/basic.pdf')
      @basic_pdf.send(attribute).should == expected_value
    end
  }
  
  it "should know which user it belongs to, if specified" do
    @valid_random_doc.should respond_to(:user)
    @valid_random_doc.user.should be_nil
    @valid_random_doc.user="eric"
    @valid_random_doc.user.should == "eric"
  end
  
  it "should know its content" do
    another_doc=Document.new("spec/test_dirs/indexed/basic/plain.txt")
    another_doc.content.should == "just a content test\nin a txt file"
  end
 
  it "should know its alias_path" do
    @valid_random_doc.should respond_to(:alias_path)
    @valid_random_doc.alias_path.starts_with?("//test_server/some_dirs").should be_true
  end
  
  it "should let finder specify its score" do
    @valid_random_doc.should respond_to(:score)
    @valid_random_doc.score.should be_nil
    @valid_random_doc.score=25
    @valid_random_doc.score.should == 25
  end
  
  it "should let finder specify its matching content" do
    @valid_random_doc.should respond_to(:matching_content)
    @valid_random_doc.matching_content.should be_nil
    @valid_random_doc.matching_content=["thermal cooling", "heat driven cooling"]
    @valid_random_doc.matching_content.should include("thermal cooling")
  end
end