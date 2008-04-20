require File.dirname(__FILE__) + '/../spec_helper'

describe Query do
  it "should return a BooleanQuery" do
    Query.extract_from("whatever").class.should == Ferret::Search::BooleanQuery
  end

  it "should translate LIKE, NOT, OR and AND boolean ops to English" do
    language_and_keywords={
      :de=>["WIE", "NICHT", "ODER", "UND"],
      :es=>["COMO", "NO", "O", "Y"],
      :fr=>["COMME","NON","OU","ET"]
    }
    
    english_query_with_like_and_not=Query.extract_from("LIKE something NOT something")
    english_query_with_or=Query.extract_from("test OR another")
    english_query_with_and=Query.extract_from("test AND another")
    
    language_and_keywords.each_pair{|ln,keywords|
      Globalite.language = ln
      like_bool, not_bool, or_bool, and_bool = keywords
      raw_query_in_some_language_with_like_and_not="#{like_bool} something #{not_bool} something"
      raw_query_in_some_language_with_or="#test #{or_bool} another"
      raw_query_in_some_language_with_and="#test #{and_bool} another"
      Query.extract_from(raw_query_in_some_language_with_like_and_not).should == english_query_with_like_and_not
      Query.extract_from(raw_query_in_some_language_with_or).should == english_query_with_or
      Query.extract_from(raw_query_in_some_language_with_and).should == english_query_with_and
    }
  end
  
  it "should accept field terms in different languages"
  
  it "should use AND as default boolean ops" do
    query_without_and = Query.extract_from("one AND two")
    query_with_and    = Query.extract_from("one two")
    query_with_and.should == query_without_and
  end
  
  it "should convert foreign keywords to boolean operators only as whole-word" do
    Globalite.language = :en
      english_query_with_french_words = Query.extract_from("CETTE AND MIETTE")
      english_query_with_german_words = Query.extract_from("STRALSUND AND BRODERBUND")
    Globalite.language = :de
      Query.extract_from("STRALSUND UND BRODERBUND").should == english_query_with_german_words
      Query.extract_from("CETTE ET MIETTE").should_not == english_query_with_french_words
    Globalite.language = :fr
      Query.extract_from("CETTE ET MIETTE").should == english_query_with_french_words
      Query.extract_from("STRALSUND UND BRODERBUND").should_not == english_query_with_german_words
  end
  
  it "should not be case sensitive" do
    Query.extract_from("test").should == Query.extract_from("TEst")
    Query.extract_from("test").should == Query.extract_from("tesT")
    Query.extract_from("test").should_not == Query.extract_from("tesTe")    
  end
end