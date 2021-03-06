require 'helper'

describe Staffomatic::User do
  describe ".path" do
    context "with no user passed" do
      it "returns default path" do
        path = Staffomatic::User.path nil
        expect(path).to eq 'user'
      end
    end

    context "with login" do
      it "returns login api path" do
        path = Staffomatic::User.path 493
        expect(path).to eq 'users/493'
      end
    end # with login

    context "with id" do
      it "returns id api path" do
        path = Staffomatic::User.path 865
        expect(path).to eq 'users/865'
      end
    end # with id
  end # .path
end # Staffomatic::User
