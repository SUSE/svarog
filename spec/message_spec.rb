require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Notification::Message do
  subject { Notification::Message }
  let(:instance) { subject.new(:sender => "test", :text => "test", :type => "info") }

  before(:each) do
    Notification::Message.destroy_all
  end

  it "initializes a new instance" do
    instance.id.wont_be_nil
    instance.type.wont_be_nil
    instance.sender.wont_be_nil
    instance.text.wont_be_nil
    instance.timestamp.must_be_nil

    instance.type.must_equal "info"
    instance.text.must_equal "test"
    instance.sender.must_equal "test"
  end

  it "returns a redis namespace" do
    subject.namespace.must_be_kind_of Redis::Namespace
  end

  it "finds an instance" do
    instance.save
    subject.all.count.must_equal 1

    message = subject.find(instance.id)
    message.type.must_equal instance.type
    message.sender.must_equal instance.sender
    message.text.must_equal instance.text
  end

  it "returns the first instance" do
    # save messages
    subject.new(:type => "first", :text => "test").save
    sleep(1) # sleep a second to get two different timestamps
    subject.new(:type => "last", :text => "test").save

    subject.all.count.must_equal 2
    subject.first.type.must_equal "first"
  end

  it "returns the last instance" do
    # save messages
    subject.new(:type => "first", :text => "test").save
    sleep(1) # sleep a second to get two different timestamps
    subject.new(:type => "last", :text => "test").save

    subject.all.count.must_equal 2
    subject.last.type.must_equal "last"
  end

  it "returns all instance" do
    subject.new(:type => "first", :text => "test").save
    subject.new(:type => "last", :text => "test").save

    subject.all.count.must_equal 2
  end

  it "destroys all instance" do
    subject.new(:type => "first", :text => "test").save
    subject.new(:type => "last", :text => "test").save

    subject.all.count.must_equal 2
    subject.destroy_all
    subject.all.count.must_equal 0
  end

  it "saves an instance" do
    subject.all.count.must_equal 0
    instance.save
    subject.all.count.must_equal 1
  end

  it "destroys an instance" do
    instance.save
    subject.all.count.must_equal 1
    instance.destroy
    subject.all.count.must_equal 0
  end

  it "converts a custom object into JSON" do
    json = instance.to_json
    json.must_be_kind_of String
    json.must_include instance.id
    json.must_include instance.type
    json.must_include instance.text
    json.must_include instance.sender
  end
end
