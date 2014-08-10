require 'helper'

describe Staffomatic::Client::Users do

  before(:each) do
    Staffomatic.reset!
    @client = oauth_client
  end

  describe ".all_users", :vcr do
    it "returns all Staffomatic users" do
      users = Staffomatic.all_users
      expect(users).to be_kind_of Array
    end
  end # .all_users

  describe ".user", :vcr do
    it "returns a user" do
      user = Staffomatic.client.user("sferik")
      expect(user.login).to eq('sferik')
    end
    it "returns the authenticated user" do
      user = @client.user
      expect(user.login).to eq(test_staffomatic_login)
    end
  end # .user

  describe ".validate_credentials", :vcr do
    it "validates username and password" do
      expect(Staffomatic.validate_credentials(:login => test_staffomatic_login, :password => test_staffomatic_password)).to be true
    end
  end # .validate_credentials

  describe ".update_user", :vcr do
    it "updates a user profile" do
      user = @client.update_user(:location => "San Francisco, CA", :hireable => false)
      expect(user.login).to eq(test_staffomatic_login)
      assert_requested :patch, staffomatic_url("/user")
    end
  end # .update_user

  describe ".followers", :vcr do
    it "returns followers for a user" do
      users = Staffomatic.followers("sferik")
      expect(users).to be_kind_of Array
      assert_requested :get, staffomatic_url("/users/sferik/followers")
    end
    it "returns the authenticated user's followers" do
      users = @client.followers
      expect(users).to be_kind_of Array
      assert_requested :get, staffomatic_url("/users/#{test_staffomatic_login}/followers")
    end
  end # .followers

  describe ".following", :vcr do
    it "returns following for a user" do
      users = Staffomatic.following("sferik")
      expect(users).to be_kind_of Array
      assert_requested :get, staffomatic_url("/users/sferik/following")
    end
    it "returns the authenticated user's following" do
      users = @client.following
      expect(users).to be_kind_of Array
      assert_requested :get, staffomatic_url("/users/#{test_staffomatic_login}/following")
    end
  end # .following

  describe ".follows?", :vcr do
    it "checks if the authenticated user follows another" do
      @client.follows?("sferik")
      assert_requested :get, staffomatic_url("/user/following/sferik")
    end

    it "checks if given user is following target user" do
      @client.follows?("sferik", "pengwynn")
      assert_requested :get, staffomatic_url("/users/sferik/following/pengwynn")
    end
  end # .follows?

  describe ".follow", :vcr do
    it "follows a user" do
      @client.follow("pengwynn")
      assert_requested :put, staffomatic_url("/user/following/pengwynn")
    end
  end # .follow

  describe ".unfollow", :vcr do
    it "unfollows a user" do
      @client.unfollow("pengwynn")
      assert_requested :delete, staffomatic_url("/user/following/pengwynn")
    end
  end # .unfollow

  describe ".starred", :vcr do
    context "not authenticated" do
      it "gets a user's starred repositories" do
        Staffomatic.starred("sferik")
        assert_requested :get, staffomatic_url("/users/sferik/starred")
      end
    end
    context "authenticated" do
      it "gets the authenticated user's starred repositories" do
        @client.starred
        assert_requested :get, staffomatic_url("/user/starred")
      end

      it "gets a user's starred repositories" do
        @client.starred("sferik")
        assert_requested :get, staffomatic_url("/users/sferik/starred")
      end
    end
  end # .starred

  describe ".keys", :vcr do
    it "returns public keys for the authenticated user" do
      public_keys = @client.keys
      expect(public_keys).to be_kind_of Array
      assert_requested :get, staffomatic_url("/user/keys")
    end
  end # .keys

  describe ".user_keys", :vcr do
    it "returns public keys for another user" do
      public_keys = Staffomatic.user_keys("pengwynn")
      expect(public_keys).to be_kind_of Array
      assert_requested :get, staffomatic_url("/users/pengwynn/keys")
    end
  end # .user_keys

  context "methods requiring an existing @public_key", :vcr do

    before(:each) do
      title, key = "wynning", "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN/h7Hf5TA6G4p19deF8YS9COfuBd133GPs49tO6AU/DKIt7tlitbnUnttT0VbNZM4fplyinPu5vJl60eusn/Ngq2vDfSHP5SfgHfA9H8cnHGPYG7w6F0CujFB3tjBhHa3L6Je50E3NC4+BGGhZMpUoTClEI5yEzx3qosRfpfJu/2MUp/V2aARCAiHUlUoj5eiB15zC25uDsY7SYxkh1JO0ecKSMISc/OCdg0kwi7it4t7S/qm8Wh9pVGuA5FmVk8w0hvL+hHWB9GT02WPqiesMaS9Sj3t0yuRwgwzLDaudQPKKTKYXi+SjwXxTJ/lei2bZTMC4QxYbqfqYQt66pQB wynn.netherland+api-padawan@gmail.com"
      @public_key = @client.add_key(title, key)
    end

    after(:each) do
      @client.remove_key(@public_key.id)
    end

    describe ".add_key" do
      it "adds a public key" do
        assert_requested :post, staffomatic_url("/user/keys")
      end
    end # .add_key

    describe ".key" do
      it "returns a public key" do
        @client.key @public_key.id
        assert_requested :get, staffomatic_url("/user/keys/#{@public_key.id}")
      end
    end

    describe ".update_key" do
      it "updates a public key" do
        expect { @client.update_key(@public_key.id, :title => 'Updated key') }.
          to raise_error(Staffomatic::MethodNotAllowed)
        assert_requested :patch, staffomatic_url("/user/keys/#{@public_key.id}")
      end
    end # .update_key

    describe ".remove_key" do
      it "removes a public key" do
        @client.remove_key(@public_key.id)
        assert_requested :delete, staffomatic_url("/user/keys/#{@public_key.id}")
      end
    end # .remove_key

  end # @public_key methods

  describe ".emails", :vcr do
    it "returns email addresses" do
      emails = @client.emails
      expect(emails).to be_kind_of Array
      assert_requested :get, staffomatic_url("/user/emails")
    end
  end # .emails

  describe ".add_email", :vcr do
    it "adds an email address" do
      @client.add_email("wynn.netherland+apitest@gmail.com")
      assert_requested :post, staffomatic_url("/user/emails")
    end
  end # .add_email

  describe ".remove_email", :vcr do
    it "removes an email address" do
      @client.remove_email("wynn.netherland+apitest@gmail.com")
      assert_requested :delete, staffomatic_url("/user/emails")
    end
  end # .remove_email

  describe ".subscriptions", :vcr do
    context "not authenticated" do
      it "returns the repositories a user watches for notifications" do
        Staffomatic.subscriptions("pengwynn")
        assert_requested :get, staffomatic_url("/users/pengwynn/subscriptions")
      end
    end

    context "authenticated" do
      it "returns the repositories the authenticated user watches for notifications" do
        @client.subscriptions
        assert_requested :get, staffomatic_url("/user/subscriptions")
      end

      it "returns the repositories a user watches for notifications" do
        @client.subscriptions("pengwynn")
        assert_requested :get, staffomatic_url("/users/pengwynn/subscriptions")
      end
    end
  end # .subscriptions

  describe ".exchange_code_for_token" do
    context "with application authenticated client" do
      it "returns the access_token" do
        client = Staffomatic::Client.new({client_id: '123', client_secret: '345'})
        request = stub_post("https://staffomatic.com/login/oauth/access_token?client_id=123&client_secret=345").
          with(:body => {:code=>"code", :client_id=>"123", :client_secret=>"345"}.to_json).
          to_return(json_response("web_flow_token.json"))
        response = client.exchange_code_for_token("code")
        expect(response.access_token).to eq "this_be_ye_token/use_it_wisely"
        assert_requested request
      end
    end # with application authenticated client

    context 'with credentials passed as parameters by unauthed client' do
      it 'returns the access_token' do
        client = Staffomatic::Client.new
        post = stub_request(:post, "https://staffomatic.com/login/oauth/access_token").
          with(:body => {:code=>"code", :client_id=>"id", :client_secret=>"secret"}.to_json).
          to_return(json_response("web_flow_token.json"))
        response = client.exchange_code_for_token('code', 'id', 'secret')
        expect(response.access_token).to eq 'this_be_ye_token/use_it_wisely'
        assert_requested post
      end
    end # with credentials passed as parameters
  end # .exchange_code_for_token
end