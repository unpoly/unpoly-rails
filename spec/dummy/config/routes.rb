Rails.application.routes.draw do
  [:get, :put].each do |method|
    [:eval, :text, :redirect0, :redirect1, :redirect2].each do |action|
      send(method, "/binding_test/#{action}", to: "binding_test##{action}")
    end
  end
end
