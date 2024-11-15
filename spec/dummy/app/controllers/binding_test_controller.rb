class BindingTestController < ApplicationController
  class_attribute :next_eval_proc

  def eval
    expression = self.class.next_eval_proc or raise "No eval expression given"
    self.eval_result = nil
    self.eval_error = nil
    self.class.next_eval_proc = nil
    begin
      self.eval_result = instance_exec(&expression)
    rescue RuntimeError => e
      self.eval_error = e
    end
    unless performed?
      # render nothing: true
      head :ok, content_type: "text/html"
    end
  end

  attr_accessor :eval_result, :eval_error

  def text
    render plain: 'text from controller'
  end

  def redirect0
    up.emit('event0')
    redirect_to action: :redirect1
  end

  def redirect1
    up.mode
    up.emit('event1')
    up.cache.expire
    redirect_to action: :redirect2
  end

  def redirect2
    up.fail_mode
    render plain: up.target
  end

  def change_target_and_redirect
    up.target = '.target-from-server'
    redirect_to action: :redirect2
  end

  private

  def content_security_policy_nonce
    'secret'
  end

end
