describe Unpoly::Rails::Change do
  describe "request_url_without_up_params" do
    let :controller do
      Struct.new(:request).new(Struct.new(:original_url).new("https://example.com/"))
    end

    it "returns uri without _up_ params" do
      controller.request.original_url = "https://example.com/some/path?_up_target=the-target&param1=1"
      change = Unpoly::Rails::Change.new(controller)
      expect(change.request_url_without_up_params).to eq("/some/path?param1=1")
    end

    it "returns original_url when no params match _up_" do
      controller.request.original_url = "https://example.com/some/path?param1=1"
      change = Unpoly::Rails::Change.new(controller)
      expect(change.request_url_without_up_params).to eq(controller.request.original_url)
    end

    it "returns original_url when only the path matches _up_" do
      controller.request.original_url = "https://example.com/some_sign_up_path?param1=1"
      change = Unpoly::Rails::Change.new(controller)
      expect(change.request_url_without_up_params).to eq(controller.request.original_url)
    end

    it "returns uri when when path and some params match _up_" do
      controller.request.original_url = "https://example.com/some_sign_up_path?_up_target=some-target&param1=1&param2=2"
      change = Unpoly::Rails::Change.new(controller)
      expect(change.request_url_without_up_params).to eq("/some_sign_up_path?param1=1&param2=2")
    end
  end
end
