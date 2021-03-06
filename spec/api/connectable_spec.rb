require 'spec_helper'

describe "RSolr::Connectable" do
  
  def connectable
    Object.new.extend RSolr::Connectable
  end
  
  context "adapt_response" do
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{:time=>"NOW"}'
      result = connectable.adapt_response({:params=>{}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = connectable.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged" do
      lambda {
        connectable.adapt_response({:params=>{:wt => :ruby}}, {:status => 200, :body => "<woops/>", :headers => {}})
      }.should raise_error RSolr::Error::InvalidRubyResponse
    end
  
  end

  context "build_request" do
    
    it 'should return a request context array' do
      result = connectable.build_request 'select', :method => :post, :params => {:q=>'test', :fq=>[0,1]}, :data => "data", :headers => {}
      [/fq=0/, /fq=1/, /q=test/, /wt=ruby/].each do |pattern|
        result[:query].should match pattern
      end
      result[:data].should == "data"
      result[:headers].should == {}
    end
    
    it "should set the Content-Type header to application/x-www-form-urlencoded if a hash is passed in to the data arg" do
      result = connectable.build_request 'select', :method => :post, :data => {:q=>'test', :fq=>[0,1]}, :headers => {}
      result[:query].should == "wt=ruby"
      [/fq=0/, /fq=1/, /q=test/].each do |pattern|
        result[:data].should match pattern
      end
      result[:data].should_not match /wt=ruby/
      result[:headers].should == {"Content-Type" => "application/x-www-form-urlencoded"}
    end
    
  end
  
end