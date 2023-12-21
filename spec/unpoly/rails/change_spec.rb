describe Unpoly::Rails::Change do

  let :request do
    OpenStruct.new(
      original_url: 'https://www.example.com',
      headers: {},
    )
  end

  let :response do
    OpenStruct.new(
      headers: {},
    )
  end

  let :params do
    {}
  end

  let :controller do
    OpenStruct.new(request: request, response: response, params: params)
  end

  subject do
    described_class.new(controller)
  end

  describe "#request_url_without_up_params" do

    it "returns uri without _up_ params" do
      controller.request.original_url = "https://example.com/some/path?_up_target=the-target&param1=1"
      expect(subject.request_url_without_up_params).to eq("/some/path?param1=1")
    end

    it "returns original_url when no params match _up_" do
      controller.request.original_url = "https://example.com/some/path?param1=1"
      expect(subject.request_url_without_up_params).to eq(controller.request.original_url)
    end

    it "returns original_url when only the path matches _up_" do
      controller.request.original_url = "https://example.com/some_sign_up_path?param1=1"
      expect(subject.request_url_without_up_params).to eq(controller.request.original_url)
    end

    it "returns uri when when path and some params match _up_" do
      controller.request.original_url = "https://example.com/some_sign_up_path?_up_target=some-target&param1=1&param2=2"
      expect(subject.request_url_without_up_params).to eq("/some_sign_up_path?param1=1&param2=2")
    end
  end

  describe '#test_target' do

    it 'is fast' do
      allow(subject).to receive(:up?).and_return(true)
      expect { subject.send(:test_target, " " * 32_000 + "a,", "bar") }.to perform_under(1).ms
    end

  end

end
